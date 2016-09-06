{%- set es_host = salt['pillar.get']('monitor:beats:es_host') -%}
{%- set beats_dashboards = salt['pillar.get']('monitor:beats:beats_dashboards') -%}
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

{% if pillar.monitor.beats.install_templates %}
# load templats into ES
topbeats_template:
  cmd:
    - run
    - name: "curl -XPUT 'http://{{es_host}}:9200/_template/topbeat' -d@/etc/topbeat/topbeat.template.json"
    - unless: curl -f 'http://{{es_host}}:9200/_template/topbeat'

# load kib templates into ES
kibana_templates_get:
  cmd:
    - run
    - name: 'wget -c http://download.elastic.co/beats/dashboards/beats-dashboards-{{beats_dashboards}}.zip -O /tmp/beats-dashboards-{{beats_dashboards}}.zip'
    - unless: test -f /tmp/beats-dashboards-{{beats_dashboards}}.zip

kibana_templates_unzip:
  cmd:
    - run
    - name: unzip /tmp/beats-dashboards-{{beats_dashboards}}.zip
    - cwd: /tmp/
    - unless: test -d /tmp/beats-dashboards-{{beats_dashboards}}

kibana_templates_load:
  cmd:
    - run
    - name: ./load.sh -url http://{{ es_host }}:9200
    - cwd: /tmp/beats-dashboards-{{beats_dashboards}}

{% endif %}
#
# start topbeat
topbeats_service:
  service:
    - running
    - name: topbeat
    - enable: true
    - require:
      - file: /etc/topbeat/topbeat.yml
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

{% if pillar.monitor.beats.install_templates %}
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

{% endif %}
# start nginx beat
nginxbeat_service:
  service:
    - running
    - name: nginxbeat
    - enable: true
    - require:
      - file: nginxbeat_bin
      - file: nginxbeat_cfg

{% endif %}

{% if pillar.monitor.beats.monitor_es_server %}
elasticbeat_bin:
  file:
    - managed
    - name: /opt/elasticbeat/elasticbeat
    - source: salt://monitor/etc/beats/elasticbeat/elasticbeat
    - makedirs: true
    - mode: 755

elasticbeat_cfg:
  file:
    - managed
    - name: /etc/elasticbeat/elasticbeat.yml
    - source: salt://monitor/etc/beats/elasticbeat/elasticbeat.yml
    - template: jinja
    - makedirs: true
    
{% if pillar.monitor.beats.install_templates %}
elasticbeat_template_get:
  file:
    - managed
    - name: /tmp/elasticbeat.template.json
    - source: salt://monitor/etc/beats/elasticbeat/elasticbeat.template.json

elasticbeat_template:
  cmd:
    - run
    - name: "curl -XPUT 'http://{{es_host}}:9200/_template/elasticbeat' -d@/tmp/elasticbeat.template.json"
    - unless: curl -f 'http://{{es_host}}:9200/_template/elasticbeat'
    - require:
      - file: elasticbeat_template_get

{% endif %}

elasticbeat_init:
  file:
    - managed
    - name: /etc/init.d/elasticbeat
    - source: salt://monitor/etc/beats/elasticbeat/elasticbeat.init
    - mode: 755

elasticbeat_service:
  service:
    - running
    - name: elasticbeat
    - enable: true
    - require:
      - file: elasticbeat_bin
      - file: elasticbeat_cfg
{% endif %}
