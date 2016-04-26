
#
# This state should be run on all hosts.
#
# You can get more plugins from https://github.com/sensu-plugins
# or write your own based on http://sensuapp.org/docs/latest/checks
#

{% set plugin_list = [ 'disk-checks', 'aws', 'filesystem-checks', 'load-checks', 
  'redis', 'influxdb', 'slack', 'pagerduty', 'graphite', 'http', 'logs', 'process-checks', 
  'nginx', 'vmstats', 'supervisor' ] %}

gem-pkgs:
  pkg:
    - installed
    - pkgs:
      - gcc
      - patch
{% if grains["os_family"] == "RedHat" %}
      - zlib-devel
{% elif grains["os_family"] == "Debian" %}
      - zlib1g-dev
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
