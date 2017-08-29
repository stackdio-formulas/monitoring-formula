
include:
  - monitor.zabbix.repo

zabbix-agent-pkg:
  pkg:
    - installed
    - name: zabbix-agent

zabbix-agent:
  service:
    - running
    - enable: true
    - require:
      - pkg: zabbix-agent-pkg

