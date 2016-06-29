{%- set sensu_version = pillar.monitor.sensu.version -%}
#
# This installs the Sensu client and all of it's dependencies.
#

include:
  - monitor.sensu.repo
  - monitor.sensu.plugins

# Sensu packages both the client and server portions into the same package, but
# we include it in both the server and client state so each one can stand on
# it's own.
sensu-client-pkg:
  pkg:
    - installed
    - name: sensu
    - version: {{ sensu_version }}-1
    - allow_updates: true
    - normalize: false
    - pkg_verify: true
    - require:
      - pkgrepo: sensu-repo

/etc/sensu/ssl/cert.pem:
  file:
    - managed
    - contents_pillar: monitor:sensu:ssl:client_cert
    - makedirs: true
    - require:
      - pkg: sensu-client-pkg

/etc/sensu/ssl/key.pem:
  file:
    - managed
    - contents_pillar: monitor:sensu:ssl:client_key
    - makedirs: true
    - require:
      - pkg: sensu-client-pkg

/etc/sensu/conf.d/rabbitmq.json:
  file:
    - managed
    - source: salt://monitor/etc/sensu/conf.d/rabbitmq.json
    - makedirs: true
    - template: jinja
    - require:
      - pkg: sensu-client-pkg

/etc/sensu/conf.d/client.json:
  file:
    - managed
    - source: salt://monitor/etc/sensu/conf.d/client.json
    - makedirs: true
    - template: jinja
    - require:
      - pkg: sensu-client-pkg

/etc/default/sensu:
  file:
    - managed
    - contents: "EMBEDDED_RUBY=true"
    - require:
      - pkg: sensu-client-pkg

sensu-client:
  service:
    - running
    - name: sensu-client
    - enable: true
    - require:
      - pkg: sensu-client-pkg
      - file: /etc/sensu/ssl/cert.pem
      - file: /etc/sensu/ssl/key.pem
      - file: /etc/sensu/conf.d/rabbitmq.json
      - file: /etc/sensu/conf.d/client.json
      - file: /etc/default/sensu

{% if grains['os_family'] == 'Debian' %}
/etc/default/sensu-client:
  file:
    - managed
    - source: salt://monitor/etc/default/sensu-client
    - template: jinja
{% endif %}

{% if 'monitor.sensu.server' in grains['roles'] %}
restart_sensu:
  cmd:
    - run
    - name: /usr/share/sensu/restart_sensu.sh
    - require:
      - service: sensu-client
{% endif %}
