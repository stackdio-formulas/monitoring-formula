
#
# This installs the Sensu client and all of it's dependencies.
#

include:
  - sensu.repo

sensu-pkg:
  pkg:
    - installed
    - name: sensu

/etc/sensu/ssl/cert.pem:
  file:
    - managed
    - contents_pillar: monitor.sensu.ssl.cert
    - require:
      - pkg: sensu-pkg

/etc/sensu/ssl/key.pem:
  file:
    - managed
    - contents_pillar: monitor.sensu.ssl.cert
    - require:
      - pkg: sensu-pkg

/etc/sensu/conf.d/rabbitmq.json:
  file:
    - managed
    - source: salt://monitor/etc/sensu/conf.d/rabbitmq.json
    - template: jinja
    - require:
      - pkg: sensu-pkg

/etc/sensu/conf.d/client.json:
  file:
    - managed
    - source: salt://monitor/etc/sensu/conf.d/client.json
    - template: jinja
    - require:
      - pkg: sensu-pkg

sensu-client:
  service:
    - running
    - name: sensu-client
    - require:
      - pkg: sensu-pkg
      - file: /etc/sensu/ssl/cert.pem
      - file: /etc/sensu/ssl/key.pem
      - file: /etc/sensu/conf.d/rabbitmq.json
      - file: /etc/sensu/conf.d/client.json

