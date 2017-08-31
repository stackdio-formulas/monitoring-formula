
include:
  - monitor.zabbix.repo

zabbix-agent-pkg:
  pkg:
    - installed
    - name: zabbix-agent

/etc/zabbix/zabbix_agent.conf:
  file.managed:
    XXX

zabbix-agent:
  service:
    - running
    - enable: true
    - require:
      - pkg: zabbix-agent-pkg

