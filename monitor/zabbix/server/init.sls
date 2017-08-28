{%- set zabbix_db_user = pillar.monitor.zabbix.db_user -%}
{%- set zabbix_db_host = pillar.monitor.zabbix.db_host -%}
{%- set zabbix_db_pass = pillar.monitor.zabbix.db_pass -%}

zabbix-server-pkg:
  pkg:
    - installed
    - skip_verify: True
    - pkgs:
      - zabbix-server-mysql
      - zabbix-web-mysql
      - mariadb 

#needs a pre-exisiting DB zabbix and user 
# create database zabbix character set utf8 collate utf8_bin;

zabbix-table-create:
  cmd.run:
    - name: zcat /usr/share/doc/zabbix-server-mysql-3*/create.sql.gz | mysql -u{{zabbix_db_user}} -p{{zabbix_db_pass}} -h{{zabbix_db_host}} --database=zabbix
    - unless: mysql -u{{zabbix_db_user}} -p{{zabbix_db_pass}} -h{{zabbix_db_host}} --database=zabbix -e "select count(*) from users;"
    - require:
      - pkg: zabbix-server-pkg

zabbix-conf-file:
  file.managed:
    - name: /etc/zabbix/zabbix_server.conf
    - source: salt://monitor/zabbix/files/zabbix_server.conf
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

zabbix-tz_set:
  file.managed:
    - name: /etc/httpd/conf.d/zabbix.conf
    - source: salt://monitor/zabbix/files/zabbix.conf
    - user: root
    - group: root
    - require:
      - service: zabbix-server

zabbix-conf-php:
  file.managed:
    - name: /etc/zabbix/web/zabbix.conf.php
    - source: salt://monitor/zabbix/files/zabbix.conf.php
    - template: jinja
    - user: root
    - group: root
    - require:
      - service: zabbix-server

httpd:
  service:
    - running
    - enable: true
    - require:
      - file: zabbix-conf-php
    
