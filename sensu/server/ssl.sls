


openssl:
  pkg:
    - installed

/mnt/sensu/ssl_certs:
  archive:
    - extracted
    - source: http://sensuapp.org/docs/0.14/tools/ssl_certs.tar
    - source_hash: md5=c53d57caba7b199495bed984dd6e7003
    - archive_format: tar
    - require:
      - pkg: openssl

generate_certs:
  cmd:
    - run
    - name: "ssl_certs.sh generate"
    - cwd: /mnt/sensu/ssl_certs
    - require:
      - archive: /mnt/sensu/ssl_certs


