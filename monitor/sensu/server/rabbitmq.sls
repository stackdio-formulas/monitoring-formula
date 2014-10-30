
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

/etc/rabbitmq/ssl/cacert.pem:
  file:
    - managed
    - contents_pillar: monitor.sensu.ssl.cacert

/etc/rabbitmq/ssl/cert.pem:
  file:
    - managed
    - contents_pillar: monitor.sensu.ssl.cert

/etc/rabbitmq/ssl/key.pem:
  file:
    - managed
    - contents_pillar: monitor.sensu.ssl.key

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

