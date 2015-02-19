
#
# This state should be run on the monitor host
#
# You can get more mutators from https://github.com/sensu/sensu-community-plugins/tree/master/mutators
# or write your own based on http://sensuapp.org/docs/latest/mutators
#

/etc/sensu/mutators:
  file:
    - recurse
    - makedirs: true
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - recurse: true
    - source: salt://monitor/etc/sensu/mutators
    - template: jinja
    - require:
      - pkg: sensu-server-pkg
    - require_in:
      - service: sensu-server

/etc/sensu/conf.d/mutators.json:
  file:
    - managed
    - makedirs: true
    - source: salt://monitor/etc/sensu/conf.d/mutators.json
    - template: jinja
    - require:
      - pkg: sensu-server-pkg
    - require_in:
      - service: sensu-server

