{%- set db_password = salt['pillar.get']('monitor:graphite:db_password', 'default') -%}
{%- set graphite_password = salt['pillar.get']('monitor:graphite:password') -%}
{%- set storage_dir = salt['pillar.get']('monitor:graphite:storage_dir') -%}

# lump all of the dependencies into a single package state
all-packages:
  pkg:
    - installed
    - pkgs:
      - graphite-web
      - graphite-carbon
      - postgresql 
      - libpq-dev 
      - python-psycopg2 
      - apache2 
      - libapache2-mod-wsgi

# Kill apache in case it was already running (like from the landing page) - then start it again
#   later after we have changed the conf files
apache2-svc-kill:
  service:
    - dead
    - require:
      - pkg: all-packages

postgresql:
  service:
    - running
  require:
    - pkg: all-packages

create_db_user:
  postgres_user:
    - present
    - name: graphite
    - password: {{ db_password }}
  require:
    - service: postgresql

{{ storage_dir }}:
  file:
    - directory
    - makedirs: true
    - user: _graphite
    - group: _graphite
    - require:
      - pkg: all-packages

create_db:
  postgres_database:
    - present
    - name: graphite
    - owner: graphite
  require:
    - service: postgresql

/etc/graphite/:
  file:
    - recurse
    - source: salt://monitor/etc/graphite/
    - template: jinja
    - makedirs: true
    - require:
      - pkg: all-packages

update_superuser_password:
  cmd:
    - run
    - name: 'DJANGO_SETTINGS_MODULE=graphite.settings python /etc/graphite/make_password.py /etc/graphite/superuser.json "{{graphite_password}}"'
    - require:
      - postgres_database: create_db

graphite_syncdb:
  cmd:
    - run
    - name: /usr/bin/graphite-manage syncdb --noinput
    - require:
      - postgres_database: create_db

graphite_create_superuser:
  cmd:
    - run
    - name: "/usr/bin/graphite-manage loaddata /etc/graphite/superuser.json"
    - require:
      - file: /etc/graphite/
      - cmd: update_superuser_password
      - cmd: graphite_syncdb

/etc/default/graphite-carbon:
  file:
    - managed
    - contents: "CARBON_CACHE_ENABLED=true"
    - require:
      - pkg: all-packages

/etc/carbon/:
  file:
    - recurse
    - source: salt://monitor/etc/carbon/
    - template: jinja
    - require:
      - pkg: all-packages

/etc/apache2/sites-enabled/graphite.conf:
  file:
    - symlink
    - target: /etc/apache2/sites-available/graphite.conf
    - unless: /etc/apache2/sites-enabled/graphite.conf
    - require:
      - pkg: all-packages

carbon-cache:
  service:
    - running
    - enable: true
    - require:
      - file: /etc/default/graphite-carbon
      - file: /etc/carbon/
      - cmd: graphite_create_superuser

apache2-add-headers:
  cmd:
    - run
    - name: a2enmod headers
    - user: root
    - require:
      - pkg: all-packages

apache2-graphite-svc:
  service:
    - running
    - name: apache2
    - require:
      - cmd: apache2-add-headers
      - service: apache2-svc-kill
      - file: /etc/apache2/sites-enabled/graphite.conf
    - watch: 
      - file: /etc/apache2/sites-enabled/graphite.conf

