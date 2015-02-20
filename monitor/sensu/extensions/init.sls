
#
# This state should be run on the monitor host
#
# You can get more extensions from https://github.com/sensu/sensu-community-plugins/tree/master/extensions
# or write your own based on http://sensuapp.org/docs/latest/extensions
#

/etc/sensu/extensions:
  file:
    - recurse
    - makedirs: true
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - recurse: true
    - source: salt://monitor/etc/sensu/extensions
    - template: jinja
    - require:
      - pkg: sensu-server-pkg
    - require_in:
      - service: sensu-server

