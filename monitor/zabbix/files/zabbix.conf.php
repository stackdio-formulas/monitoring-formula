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

