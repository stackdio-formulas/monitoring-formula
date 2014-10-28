
#
# This installs the Sensu server and all of it's dependencies.
#


include:
  - sensu.server.ssl
  - sensu.server.rabbitmq
  - sensu.server.redis


