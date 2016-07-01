{%- es_host = salt['pillar.get']('monitor:es:host') -%}
# repo topbeat
beat-repo:
  pkgrepo:
    - managed
{% if grains["os_family"] == "Debian" %}
    - key_url: https://packages.elasticsearch.org/GPG-KEY-elasticsearch
    - name: deb https://packages.elastic.co/beats/apt stable main
    - refresh_db: true
{% elif grains["os_family"] == "RedHat" %}
    - humanname: beats
    - name: beats
    - baseurl: https://packages.elastic.co/beats/yum/el/$basearch
    - gpgcheck: 1
    - gpgkey: https://packages.elastic.co/GPG-KEY-elasticsearch
    - enabled: 1
{% endif %}

# install topbeat
topbeat-pkg:
  pkg:
    - installed
    - name: topbeat
    - require:
      - pkgrepo: beat-repo

# place cfg file
/etc/topbeat/topbeat.yml:
  file:
    - managed
    - makedirs: true
    - source: salt://monitor/etc/beats/topbeat/topbeat.yml
    - template: jinja
    - require:
      - pkg: topbeat-pkg

# load templats into ES
topbeats_template:
  cmd:
    - run
    - name: "curl -XPUT 'http://{{es_host}}:9200/_template/topbeat' -d@/etc/topbeat/topbeat.template.json"

# load kib templates into ES

kibana_templats_get:
  cmd:
    - run
    - name: 'wget -c http://download.elastic.co/beats/dashboards/beats-dashboards-1.2.3.zip -O /tmp/beats-dashboards-1.2.3.zip'
    - unless: test -f /tmp/beats-dashboards-1.2.3.zip

kibana_templates_unzip:
  cmd:
    - run
    - name: unzip /tmp/beats-dashboards-1.2.3.zip
    - cwd: /tmp/
    - unless: test -d /tmp/beats-dashboards-1.2.3

kibana_templates_load:
  cmd:
    - run
    - name: ./load.sh -url http://{{ es_host }}:9200
    - cwd: /tmp/beats-dashboards-1.2.3
#
# start topbeat
topbeats_service:
  service:
    - running
    - name: topbeats
    - enabled: true
    - require:
      - cmd: kibana_templates_load
#
# 
# IF WEBSERVER
#
#
#

# place nginx beat 
nginxbeat_bin:
  file:
    - managed
    - name: /opt/nginxbeat/nginxbeat
    - source: salt://monitor/etc/beats/nginxbeat/nginxbeat
    - makedirs: true

# place cfg
nginxbeat_cfg:
  file:
    - managed
    - name: /etc/nginxbeat/nginxbeat.yml
    - source: salt://monitor/etc/beats/nginxbeat/nginxbeat.yml
    - makedirs: true

# place start script
nginxbeat_init:
  file:
    - managed
    - name: /etc/init.d/nginxbeat
    - source: salt://monitor/etc/beats/nginxbeat/nginxbeat.init

# load templat into ES
nginxbeat_template_get:
  file:
    - managed
    - name: /tmp/nginxbeat.template.json
    - source: salt://monitor/etc/beats/nginxbeat/nginxbeat.template.json

topbeats_template:
  cmd:
    - run
    - name: "curl -XPUT 'http://{{es_host}}:9200/_template/nginxbeat' -d@/tmp/nginxbeat.template.json"
    - require:
      - file: nginxbeat_template_get

# start nginx beat
nginxbeat_service:
  service:
    - running
    - name: nginxbeat
    - enabled: true
    - require:
      - file: nginxbeat_bin
      - cmd: topbeats_template
