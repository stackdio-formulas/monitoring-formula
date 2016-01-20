
#
# This installs the Sensu server and all of it's dependencies.
#

include:
  - monitor.sensu.repo
  - monitor.sensu.server.rabbitmq
  - monitor.sensu.server.redis
  - monitor.sensu.handlers
  - monitor.sensu.mutators
  - monitor.sensu.extensions
{% if salt['pillar.get']('monitor:web:webserver') == 'apache2' %}
  - monitor.webserver.apache2_landing_page
{% else %}
  - monitor.webserver.nginx_landing_page
{% endif %}

# Sensu packages both the client and server portions into the same package, but
# we include it in both the server and client state so each one can stand on
# it's own.
sensu-server-pkg:
  pkg:
    - installed
    - name: sensu
    - require:
      - pkgrepo: sensu-repo
    - require_in:
      - file: /etc/sensu/plugins

{% if salt['pillar.get']('monitor:sensu:check_system') %}
/etc/sensu/conf.d/check_system.json:
  file:
    - managed
    - makedirs: true
    - source: salt://monitor/etc/sensu/conf.d/check_system.json
    - template: jinja
    - require:
      - pkg: sensu-server-pkg
    - require_in:
      - service: sensu-server
    - watch_in:
      - service: sensu-server
      - service: sensu-api
{% endif %}

/etc/sensu/ssl/cert.pem:
  file:
    - managed
    - contents_pillar: monitor:sensu:ssl:client_cert
    - makedirs: true
    - require:
      - pkg: sensu-server-pkg

/etc/sensu/ssl/key.pem:
  file:
    - managed
    - contents_pillar: monitor:sensu:ssl:client_key
    - makedirs: true
    - require:
      - pkg: sensu-server-pkg

/etc/sensu/conf.d/config.json:
  file:
    - managed
    - makedirs: true
    - source: salt://monitor/etc/sensu/conf.d/config.json
    - template: jinja
    - require:
      - pkg: sensu-server-pkg

sensu-server:
  service:
    - running
    - enable: true
    - require:
      - file: /etc/sensu/plugins
      - file: /etc/sensu/ssl/cert.pem
      - file: /etc/sensu/ssl/key.pem
      - file: /etc/sensu/conf.d/config.json
      - service: rabbitmq-server-svc
      - service: redis-server
    - watch:
      - file: /etc/sensu/ssl/cert.pem
      - file: /etc/sensu/ssl/key.pem
      - file: /etc/sensu/conf.d/config.json

sensu-api:
  service:
    - running
    - enable: true
    - require:
      - service: sensu-server
    - watch:
      - file: /etc/sensu/ssl/cert.pem
      - file: /etc/sensu/ssl/key.pem
      - file: /etc/sensu/conf.d/config.json

/usr/share/sensu/restart_sensu.sh:
  file:
    - managed
    - source: salt://monitor/usr/share/sensu/restart_sensu.sh
    - mode: 755
    - require:
      - pkg: sensu-server-pkg

