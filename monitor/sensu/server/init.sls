
#
# This installs the Sensu server and all of it's dependencies.
#


include:
  - sensu.server.rabbitmq
  - sensu.server.redis

{% if pillar.monitor.sensu.check_system %}
/etc/sensu/conf.d/check_system.json:
  file:
    - managed
    - makedirs: true
    - source: salt://monitor/etc/sensu/conf.d/check_system.json
    - template: jinja
{% endif %}

sensu-server:
  service:
    - running

sensu-api:
  service:
    - running

