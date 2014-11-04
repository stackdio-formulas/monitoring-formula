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

postgresql:
  service:
    - running  

create_db_user:
  postgres_user:
    - present
    - name: graphite
    - password: {{ db_password }}

{{ storage_dir }}:
  file:
    - directory
    - makedirs: true
    - user: _graphite
    - group: _graphite

create_db:
  postgres_database:
    - present
    - name: graphite
    - owner: graphite

/etc/graphite/:
  file:
    - recurse
    - source: salt://monitor/etc/graphite/
    - template: jinja
    - makedirs: true

update_superuser_password:
  cmd:
    - run
    - name: 'DJANGO_SETTINGS_MODULE=graphite.settings python /etc/graphite/make_password.py /etc/graphite/superuser.json "{{graphite_password}}"'

graphite_syncdb:
  cmd:
    - run
    - name: /usr/bin/graphite-manage syncdb --noinput

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

/etc/carbon/:
  file:
    - recurse
    - source: salt://monitor/etc/carbon/
    - template: jinja

/etc/apache2/sites-enabled/graphite.conf:
  file:
    - symlink
    - target: /etc/apache2/sites-available/graphite.conf
    - unless: /etc/apache2/sites-enabled/graphite.conf

carbon-cache:
  service:
    - running
    - enable: true

apache2-graphite-svc:
  service:
    - running
    - name: apache2
    - watch: 
      - file: /etc/apache2/sites-enabled/graphite.conf

