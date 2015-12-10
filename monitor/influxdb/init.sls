{%- set username = salt['pillar.get']('monitor:influxdb:username') -%}
{%- set password = salt['pillar.get']('monitor:influxdb:password') -%}
#
# Install and configure influxDB
#


influxdb_pkg:
  pkg.installed:
    - sources:
      - influxdb: http://influxdb.s3.amazonaws.com/influxdb_0.9.4.2_amd64.deb

/etc/opt/influxdb/influxdb.conf:
  file:
    - managed
    - source: salt://monitor/etc/influxdb/influxdb.conf
    - template: jinja
    - makedirs: true
    - require:
      - pkg: influxdb_pkg

{{ pillar.monitor.influxdb.storage_dir }}/data:
  file:
    - directory
    - makedirs: true
    - user: root
    - group: root
    - require:
      - pkg: influxdb_pkg
    

influxdb:
  service:
    - running
    - enable: true
    - require:
      - pkg: influxdb_pkg

influxdb_user:
    cmd:
      - run
    - name: "/bin/sleep 5 ;/opt/influxdb/influx -execute \"CREATE USER {{ username }} WITH PASSWORD '{{ password }}' WITH ALL PRIVILEGES\""
  - require:
        - service: influxdb


