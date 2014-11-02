
#
# This installs the Sensu server and all of it's dependencies.
#

include:
  - monitor.sensu.server.rabbitmq
  - monitor.sensu.server.redis
  - monitor.sensu.server.landing_page
  - monitor.sensu.plugins
  - monitor.sensu.handlers
  - monitor.sensu.mutators
  - monitor.sensu.extensions

# Sensu packages both the client and server portions into the same package, but
# we include it in both the server and client state so each one can stand on
# it's own.
sensu-server-pkg:
  pkg:
    - installed
    - name: sensu

{% if salt['pillar.get']('monitor:sensu:check_system') %}
/etc/sensu/conf.d/check_system.json:
  file:
    - managed
    - makedirs: true
    - source: salt://monitor/etc/sensu/conf.d/check_system.json
    - template: jinja
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

sensu-server:
  service:
    - running
    - enable: true
    - watch:
      - file: /etc/sensu/ssl/cert.pem
      - file: /etc/sensu/ssl/key.pem
      - file: /etc/sensu/conf.d/config.json
      {% if salt['pillar.get']('monitor:sensu:check_system') %}
      - file: /etc/sensu/conf.d/check_system.json
      {% endif %}

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
      {% if salt['pillar.get']('monitor:sensu:check_system') %}
      - file: /etc/sensu/conf.d/check_system.json
      {% endif %}


