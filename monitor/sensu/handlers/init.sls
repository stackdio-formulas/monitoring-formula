
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

