{%- set rabbit_username = salt['pillar.get']('monitor:sensu:rabbitmq:username') -%}
{%- set rabbit_password = salt['pillar.get']('monitor:sensu:rabbitmq:password') -%}
{%- set rabbit_vhost = salt['pillar.get']('monitor:sensu:rabbitmq:vhost') -%}

erlang:
  pkg:
    - installed
    {% if grains['os_family'] == 'Debian' %}
    - name: erlang-nox
    {% elif grains['os_family'] == 'RedHat' %}
    # must have EPEL
    - name: erlang
    {% endif %}

# Ubuntu only for now
{% if grains['os_family'] == 'Debian' %}

{# this should work on a newer version salt
rabbitmq-repo:
  pkgrepo:
    - managed
    - key_url: http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
    - name: deb http://www.rabbitmq.com/debian/ testing main
    - refresh_db
#}

/etc/apt/sources.list.d/rabbitmq.list:
  file:
    - managed
    - content: "deb     http://www.rabbitmq.com/debian/ testing main"

rabbitmq-repo-key:
  cmd:
    - run
    - name: "curl http://www.rabbitmq.com/rabbitmq-signing-key-public.asc | apt-key add -"
    - unless: 'apt-key list | grep "RabbitMQ Release Signing Key"'

rabbitmq-server-pkg:
  pkg:
    - installed
    - name: rabbitmq-server
    - require:
#      - pkgrepo: rabbitmq-repo
      - file: /etc/apt/sources.list.d/rabbitmq.list
      - cmd: rabbitmq-repo-key

{% endif %}

/etc/rabbitmq/ssl/cacert.pem:
  file:
    - managed
    - contents_pillar: monitor:sensu:ssl:server_cacert
    - makedirs: true
    - require:
      - pkg: rabbitmq-server-pkg

/etc/rabbitmq/ssl/cert.pem:
  file:
    - managed
    - contents_pillar: monitor:sensu:ssl:server_cert
    - makedirs: true
    - require:
      - pkg: rabbitmq-server-pkg

/etc/rabbitmq/ssl/key.pem:
  file:
    - managed
    - contents_pillar: monitor:sensu:ssl:server_key
    - makedirs: true
    - require:
      - pkg: rabbitmq-server-pkg

/etc/rabbitmq/rabbitmq.config:
  file:
    - managed
    - source: salt://monitor/etc/rabbitmq/rabbitmq.config
    - makedirs: true
    - require:
      - pkg: rabbitmq-server-pkg

create_vhost:
  cmd:
    - run
    - name: "rabbitmqctl add_vhost {{ rabbit_vhost }}"
    - unless: 'rabbitmqctl list_vhosts | grep "{{ rabbit_vhost }}"'
    - require:
      - file: /etc/rabbitmq/ssl/cacert.pem
      - file: /etc/rabbitmq/ssl/cert.pem
      - file: /etc/rabbitmq/ssl/key.pem
      - file: /etc/rabbitmq/rabbitmq.config

rabbit_user:
  cmd:
    - run
    - name: 'rabbitmqctl add_user {{ rabbit_username }} {{ rabbit_password }}'
    - unless: 'rabbitmqctl list_users | grep {{ rabbit_username }}'
    - require:
      - cmd: create_vhost

rabbit_permissions:
  cmd:
    - run
    - name: 'rabbitmqctl set_permissions -p {{ rabbit_vhost }} {{ rabbit_username }} ".*" ".*" ".*"'
    - unless: 'rabbitmqctl list_permissions -p {{ rabbit_vhost }} | grep -v "{{ rabbit_vhost }}" | grep {{rabbit_username}}'
    - require:
      - cmd: rabbit_user

#rabbit_web_console:
#  cmd:
#    - run
#    - name: "rabbitmq-plugins enable rabbitmq_management"
#    - unless: "rabbitmq-plugins list rabbitmq_management"
#    - env:
#      - HOME: /var/lib/rabbitmq

rabbitmq-server-svc:
  service:
    - running
    - name: rabbitmq-server
    - enable: true
    - require:
      - cmd: rabbit_permissions
    - watch:
      - file: /etc/rabbitmq/rabbitmq.config
      - file: /etc/rabbitmq/ssl/cacert.pem
      - file: /etc/rabbitmq/ssl/cert.pem
      - file: /etc/rabbitmq/ssl/key.pem

