
#
# install and configure Graphana
#

#
# add the repo
#
grafana-repo:
  pkgrepo:
    - managed
{% if grains["os_family"] == "Debian" %}
    - key_url: https://packagecloud.io/gpg.key
    - name: deb https://packagecloud.io/grafana/stable/debian/ wheezy main
    - refresh_db: true
{% elif grains["os_family"] == "RedHat" %}
    - humanname: grafana
    - baseurl: http://repos.sensuapp.org/yum/el/$releasever/$basearch/
    - gpgcheck: 0
{% endif %}

#
# Install the pkg
#
grafana-pkg:
  pkg:
    - installed
    - name: grafana
    - require:
      - pkgrepo: grafana-repo

#
# Insert config file stuff here
# 
/etc/grafana/grafana.ini:
  file:
    - managed
    - makedirs: true
    - user: grafana
    - group: grafana
    - source: salt://monitor/etc/grafana/grafana.ini
    - template: jinja
    - require:
      - pkg: grafana-pkg

#
# Make /mnt/grafana
# 
/mnt/grafana:
  - user: grafana
  - group: grafana
  - mode: 755
  - makedirs: True

#
# start service
#

grafana-server:
  service:
    - running
    - enable: true
    - require:
      - pkg: grafana-pkg
