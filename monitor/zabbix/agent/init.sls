
include:
  - monitor.zabbix.repo

zabbix-agent-pkg:
  pkg:
    - installed
    - name: zabbix-agent

/etc/zabbix/zabbix_agentd.conf:
  file.managed:
    - source: salt://monitor/zabbix/files/zabbix_agentd.conf
    - template: jinja
    - user: root
    - group: zabbix
    - require:
      - pkg: zabbix-agent-pkg

zabbix-agent:
  service:
    - running
    - enable: true
    - require:
      - pkg: zabbix-agent-pkg
      - file: /etc/zabbix/zabbix_agentd.conf

