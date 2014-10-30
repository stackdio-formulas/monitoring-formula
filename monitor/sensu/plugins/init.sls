
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

