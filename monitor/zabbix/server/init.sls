
zabbix-server-pkg:
  pkg:
    - installed
    - skip_verify: True
    - pkgs:
      - zabbix-server-mysql
      - zabbix-web-mysql
      - mysql

#needs a pre-exisiting DB zabbix and user 
# create database zabbix character set utf8 collate utf8_bin;

zabbix-table-create:
  cmd.run:
    - name: zcat /usr/share/doc/zabbix-server-mysql-3*/create.sql.gz | mysql -u{zabbix.db.user} -p{zabbix.db.password} -h{zabbix.db.host} --database=zabbix
    - unless: mysql -u{zabbix.db.user} -p{zabbix.db.password} -h{zabbix.db.host} --database=zabbix -e "select count(*) from users;"
    - require:
      - pkg: zabbix-server-pkg

zabbix-conf-file:
  file.managed:
    - name: /etc/zabbix/zabbix_server.conf
    - source: salt://monitor/zabbix/file/zabbix_server.conf
    - template: jinja
    - user: root
    - group: zabbix
    - require:
      - pkg: zabbix-server-pkg

zabbix-server:
  service:
    - running
    - enable: true
    - require:
      - pkg: zabbix-server-pkg
      - file: zabbix-conf-file
      - cmd: zabbix-table-create

/etc/http/conf.d/zabbix....
Configuration file "/etc/zabbix/web/zabbix.conf.php" created.

[root@jds-zab web]# more zabbix.conf.php
<?php
// Zabbix GUI configuration file.
global $DB;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = 'test-wp-db.cjjcv8pft9v8.us-west-2.rds.amazonaws.com';
$DB['PORT']     = '0';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = 'fred';
$DB['PASSWORD'] = 'xPWYj999dwHQUaKk5BWc';

// Schema name. Used for IBM DB2 and PostgreSQL.
$DB['SCHEMA'] = '';

$ZBX_SERVER      = 'jds-zab.spotlight-dev.htspotlight.com';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = 'first try';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
[root@jds-zab web]#
