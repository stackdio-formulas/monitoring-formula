
elasticsearch-repo:
  pkgrepo:
    - managed
    - key_url: http://packages.elasticsearch.org/GPG-KEY-elasticsearch
    - name: deb http://packages.elasticsearch.org/elasticsearch/1.0/debian stable main
    - refresh_db: true

elasticsearch-pkgs:
  pkg:
    - installed
    - pkgs:
      - elasticsearch
      - openjdk-7-jre-headless
    - require:
      - pkgrepo: elasticsearch-repo

elasticsearch-svc:
  service:
    - running
    - name: elasticsearch
    - require:
      - pkg: elasticsearch-pkgs

# Kill apache first - so we can restart it later after we update the grafana conf file
apache2-grafana-svc-kill:
  service:
    - dead

grafana-tgz:
  archive:
    - extracted
    - name: /usr/share
    - source: http://grafanarel.s3.amazonaws.com/grafana-1.5.3.tar.gz
    - source_hash: md5=fef11092897935fe5d1e11faae0d7507
    - tar_options: z
    - archive_format: tar
    - if_missing: /usr/share/grafana-1.5.3

/usr/share/grafana:
  file:
    - symlink
    - target: /usr/share/grafana-1.5.3
    - require:
      - archive: grafana-tgz

/usr/share/grafana/config.js:
  file:
    - managed
    - source: salt://monitor/usr/share/grafana/config.js
    - template: jinja
    - require:
      - file: /usr/share/grafana

/etc/apache2/sites-enabled/grafana.conf:
  file:
    - managed
    - contents: "alias /grafana /usr/share/grafana"

apache2-grafana-svc:
  service:
    - running
    - name: apache2
    - require:
      - service: apache2-grafana-svc-kill
      - file: /usr/share/grafana/config.js
      - file: /etc/apache2/sites-enabled/grafana.conf
    - watch: 
      - file: /etc/apache2/sites-enabled/grafana.conf

