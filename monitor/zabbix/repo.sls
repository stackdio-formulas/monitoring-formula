

zabbix-repo:
 cmd.run:
   - name: rpm -ivh http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
   - unless: ls /etc/yum.repos.d/zabbix.repo
  
