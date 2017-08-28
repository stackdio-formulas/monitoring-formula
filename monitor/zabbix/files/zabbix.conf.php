{%- set zabbix_db_user = pillar.monitor.zabbix.db_user -%}
{%- set zabbix_db_host = pillar.monitor.zabbix.db_host -%}
{%- set zabbix_db_pass = pillar.monitor.zabbix.db_pass -%}
<?php
// Zabbix GUI configuration file.
global $DB;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = '{{zabbix_db_host}}';
$DB['PORT']     = '0';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = '{{zabbix_db_user}}';
$DB['PASSWORD'] = '{{zabbix_db_pass}}';

// Schema name. Used for IBM DB2 and PostgreSQL.
$DB['SCHEMA'] = '';

$ZBX_SERVER      = '{{ grains.fqdn }}';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = 'first try';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;

