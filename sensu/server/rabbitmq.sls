
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

rabbitmq-repo:
  pkgrepo:
    - managed
    - key_url: http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
    - name: deb http://www.rabbitmq.com/debian/ testing main
    - refresh_db

rabbitmq-server:
  pkg:
    - installed
  service:
    - running
    - enable: true

{% endif %}

/etc/rabbitmq/ssl:
  file:
    - directory
    - makedirs: true

{% for cert in ["sensu_ca/cacert.pem", "server/cert.pem", "server/key.pem" ] %}
copy_{{cert}}:
  file:
    - copy
    - makedirs: true
    - name: /etc/rabbitmq/ssl
    - source: /mnt/sensu/ssl_certs/{{cert}}
{% end for %}

/etc/rabbitmq/rabbitmq.config:
  file:
    - managed
    - source: salt://sensu/etc/rabbitmq/rabbitmq.config

create_vhost:
  cmd:
    - name: "rabbitmqctl add_vhost /sensu"

rabbit_permissions:
  cmd:
    - name: 'rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"'

rabbit_web_console:
  cmd:
    - name: "rabbitmq-plugins enable rabbitmq_management"

