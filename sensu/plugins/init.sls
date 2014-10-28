
/etc/sensu/plugins:
  file:
    - directory
    - makedirs: true
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - source: salt://sensu/etc/sensu/plugins

