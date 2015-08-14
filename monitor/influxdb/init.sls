
#
# Install and configure influxDB
#


influxdb:
  pkg.installed:
    - sources:
      - influxdb_0.9.2_amd64: http://influxdb.s3.amazonaws.com/influxdb_0.9.2_amd64.deb
