{%- set es_host = salt['pillar.get']('monitor:beats:es_host') -%}
{%- set beats-dashboards = salt['pillar.get']('monitor:beats:beats-dashboards') -%}
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
    - unless: curl -f 'http://{{es_host}}:9200/_template/topbeat'

# load kib templates into ES
{% if pillar.monitor.beats.install_templates %}
kibana_templates_get:
  cmd:
    - run
    - name: 'wget -c http://download.elastic.co/beats/dashboards/beats-dashboards-{{beats-dashboards}}.zip -O /tmp/beats-dashboards-{{beats-dashboards}}.zip'
    - unless: test -f /tmp/beats-dashboards-{{beats-dashboards}}.zip

kibana_templates_unzip:
  cmd:
    - run
    - name: unzip /tmp/beats-dashboards-{{beats-dashboards}}.zip
    - cwd: /tmp/
    - unless: test -d /tmp/beats-dashboards-{{beats-dashboards}}

kibana_templates_load:
  cmd:
    - run
    - name: ./load.sh -url http://{{ es_host }}:9200
    - cwd: /tmp/beats-dashboards-{{beats-dashboards}}

{% endif %}
#
# start topbeat
topbeats_service:
  service:
    - running
    - name: topbeat
    - enable: true
    - require:
      - cmd: topbeats_template
#
# 
{% if pillar.monitor.beats.monitor_webserver %}

# place nginx beat 
nginxbeat_bin:
  file:
    - managed
    - name: /opt/nginxbeat/nginxbeat
    - source: salt://monitor/etc/beats/nginxbeat/nginxbeat
    - makedirs: true
    - mode: 755

# place cfg
nginxbeat_cfg:
  file:
    - managed
    - name: /etc/nginxbeat/nginxbeat.yml
    - source: salt://monitor/etc/beats/nginxbeat/nginxbeat.yml
    - template: jinja
    - makedirs: true

# place start script
nginxbeat_init:
  file:
    - managed
    - name: /etc/init.d/nginxbeat
    - source: salt://monitor/etc/beats/nginxbeat/nginxbeat.init
    - mode: 755

# load templat into ES
nginxbeat_template_get:
  file:
    - managed
    - name: /tmp/nginxbeat.template.json
    - source: salt://monitor/etc/beats/nginxbeat/nginxbeat.template.json

nginxbeat_template:
  cmd:
    - run
    - name: "curl -XPUT 'http://{{es_host}}:9200/_template/nginxbeat' -d@/tmp/nginxbeat.template.json"
    - unless: curl -f 'http://{{es_host}}:9200/_template/nginxbeat'
    - require:
      - file: nginxbeat_template_get

# start nginx beat
nginxbeat_service:
  service:
    - running
    - name: nginxbeat
    - enable: true
    - require:
      - file: nginxbeat_bin
      - cmd: nginxbeat_template

{% endif %}
