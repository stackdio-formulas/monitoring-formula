
elasticsearch-repo:
  pkgrepo:
    - managed
    - key_url: http://packages.elasticsearch.org/GPG-KEY-elasticsearch
    - name: deb http://packages.elasticsearch.org/elasticsearch/1.0/debian stable main
    - refresh_db

elasticsearch-pkgs:
  pkg:
    - installed
    - pkgs:
      - elasticsearch
      - openjdk-7-jre-headless

elasticsearch-svc:
  service:
    - running
    - name: elasticsearch

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

/etc/apache2/sites-enabled/grafana.conf:
  file:
    - managed
    - contents: "alias /grafana /usr/share/grafana"

