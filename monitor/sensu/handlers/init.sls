
#
# This state should be run on the monitor host
#
# You can get more handlers from https://github.com/sensu/sensu-community-plugins/tree/master/handlers
# or write your own based on http://sensuapp.org/docs/latest/handlers
#

/etc/sensu/handlers:
  file:
    - recurse
    - makedirs: true
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - recurse: true
    - source: salt://monitor/etc/sensu/handlers
    - template: jinja
    - require:
      - pkg: sensu-server-pkg
    - require_in:
      - service: sensu-server

/etc/sensu/conf.d/handlers.json:
  file:
    - managed
    - makedirs: true
    - source: salt://monitor/etc/sensu/conf.d/handlers.json
    - template: jinja
    - require:
      - pkg: sensu-server-pkg
    - require_in:
      - service: sensu-server

# The following is a list of dependencies for any of the handlers. Because
# we're using the embedded ruby included with Sensu, we need to use cmd.run to
# manipulate the GEM_PATH (vs the more salty gem.installed).
{% for gem in [ 'timeout', 'aws-ses', ] %}
{{gem}}-gem:
  cmd.run:
    - name: /opt/sensu/embedded/bin/gem install {{gem}}
    - unless: /opt/sensu/embedded/bin/gem list --local | grep {{gem}}
    - env:
        - PLUGINS_DIR: /etc/sensu/plugins
        - HANDLERS_DIR: /etc/sensu/handlers
        - PATH: /opt/sensu/embedded/bin:$PATH:$PLUGINS_DIR:$HANDLERS_DIR
        - GEM_PATH: /opt/sensu/embedded/lib/ruby/gems/2.0.0:$GEM_PATH
    - require:
        - pkg: sensu-server-pkg
    - require_in:
        - service: sensu-server
{% endfor %}
