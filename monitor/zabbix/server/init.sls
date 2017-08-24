
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
    - name:  zcat /usr/share/doc/zabbix-server-mysql-3*/create.sql.gz | mysql -u{zabbix.db.user} -p{zabbix.db.password} -h{zabbix.db.host} --database=zabbix

