{%- set username = salt['pillar.get']('monitor:influxdb:username') -%}
{%- set password = salt['pillar.get']('monitor:influxdb:password') -%}
{%- set influx_ver = salt['pillar.get']('monitor:influxdb:version') -%}
#
# Install and configure influxDB
#

{% if grains["os_family"] == "Debian" %}
influxdb_pkg:
  pkg.installed:
    - sources:
      - influxdb: http://influxdb.s3.amazonaws.com/influxdb_{{influx_ver}}_amd64.deb
{% elif grains["os_family"] == "RedHat" %}
influxdb_pkg:
  pkg.installed:
    - sources:
      - influxdb: http://influxdb.s3.amazonaws.com/influxdb_{{influx_ver}}.x86_64.rpm
{% endif %}

/etc/influxdb/influxdb.conf:
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
    - user: influxdb
    - group: influxdb
    - require:
      - pkg: influxdb_pkg
    

influxdb:
  service:
    - running
    - enable: true
    - require:
      - pkg: influxdb_pkg

