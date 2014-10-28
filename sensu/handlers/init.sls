
/etc/sensu/handlers:
  file:
    - recurse
    - makedirs: true
    - clean: true
    - file_mode: 755
    - dir_mode: 755
    - recurse: true
    - source: salt://sensu/etc/sensu/handlers
    - template: jinja


