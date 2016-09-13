
#
# This state should be run on all hosts.
#
# You can get more plugins from https://github.com/sensu-plugins
# or write your own based on http://sensuapp.org/docs/latest/checks
#

{% set plugin_list = [ 'disk-checks', 'aws', 'filesystem-checks', 'load-checks', 
  'redis',  'slack', 'pagerduty', 'http', 'logs', 'process-checks', 
  'nginx', 'vmstats', 'supervisor', 'memory-checks', 'sensu', 'elasticsearch' ] %}

gem-pkgs:
  pkg:
    - installed
    - pkgs:
      - gcc
      - patch
{% if grains["os_family"] == "RedHat" %}
      - zlib-devel
      - libxml2-devel
      - gcc-c++
{% elif grains["os_family"] == "Debian" %}
      - zlib1g-dev
      - libxml2-dev
      - g++
{% endif %}


{% for plugin in plugin_list %}
{{plugin}}-install:
  cmd.run:
    - name: /usr/bin/sensu-install -p {{plugin}}
    - require:
        - pkg: gem-pkgs
        - pkg: sensu-client-pkg
        - file: /etc/default/sensu
    - require_in:
        - service: sensu-client
{% endfor %}

/etc/sensu/plugins/check-log.rb:
  file.managed
    - source: salt://monitor/etc/sensu/plugins/check-log.rb
