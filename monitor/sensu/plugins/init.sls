
#
# This state should be run on all hosts.
#
# You can get more plugins from https://github.com/sensu/sensu-community-plugins/tree/master/plugins 
# or write your own based on http://sensuapp.org/docs/latest/checks
#

/etc/sensu/plugins:
  file:
    - recurse
    - makedirs: true
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - recurse: true
    - source: salt://monitor/etc/sensu/plugins
    - template: jinja
    - require:
      - pkg: sensu-client-pkg

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

# The following is a list of dependencies for any of the handlers. Because
# we're using the embedded ruby included with Sensu, we need to use cmd.run to
# manipulate the GEM_PATH (vs the more salty gem.installed).
{% for gem in [ 'aws-sdk-v1', 'sensu-plugins-disk-checks', 'sys-filesystem', 'sensu-plugins-influxdb', 'redphone', 'sensu-plugins-redis', ] %}
{{gem}}-gem:
  cmd.run:
    - name: /opt/sensu/embedded/bin/gem install {{gem}}
    - unless: /opt/sensu/embedded/bin/gem list --local | grep {{gem}}
    - env:
        - PLUGINS_DIR: /etc/sensu/plugins
        - HANDLERS_DIR: /etc/sensu/handlers
        - GEM_PATH: /opt/sensu/embedded/lib/ruby/gems/2.0.0
    - require:
        - file: /etc/sensu/plugins
        - pkg: gem-pkgs
        - pkg: sensu-client-pkg
        - file: /etc/default/sensu
    - require_in:
        - service: sensu-client
{% endfor %}
