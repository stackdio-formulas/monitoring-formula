## monitoring-formula

Monitoring Formula for stackd.io.  Provisions a number of system monitoring
utilities:

- [Sensu](http://sensuapp.org): monitoring of things
- [Graphite](http://graphite.wikidot.com): collection and graphing of things
- [Grafana](http://grafana.org): nicer graphing of things

Also includes various prereqs for each component.  Usage should be something
like:

- Your main monitoring host (in this order):
    - `monitor.sensu.server`: the main Sensu server
    - `monitor.sensu.client`: Sensu client
    - `monitor.sensu.uchiwa`: web UI for Sensu
    - `monitor.graphite`: Graphite database
    - `monitor.grafana`: Grafana UI for Graphite
    - The `monitor.sensu.server` state also includes these states:
        - `monitor.sensu.plugins`: plugins to monitor specific services
        - `monitor.sensu.mutators`: mutators for transforming Sensu results
        - `monitor.sensu.handlers`: handlers for processing/routing Sensu results
        - `monitor.sensu.extensions`: extensions for extending Sensu capabilities

- All clients:
    - `monitor.sensu.client`: Sensu client
    - `monitor.sensu.plugins`: plugins to monitor specific services

You will need to create some SSL certs as instructed by 
[Sensu docs](http://sensuapp.org/docs/latest/certificates). The 
`server/client.pem`, `server/key.pem`, and `sensu_ca/cacert.pem` files that are
generated with that script need to be provided as pillar data via 
`monitor.sensu.ssl`.  The `cacert.pem` is only used on the main monitoring host, but
the `client.pem` and `key.pem` are used by the main monitoring host and all
clients.

After successfully provisioning, you should be able to browse to
`http://HOSTNAME` of the main monitoring host and see a landing page with 
links to various UIs.  


## pillar data

- **REQUIRED**: As mentioned above, you need to provide the SSL certs in order for things to
  talk to each other (`monitor.senus.ssl.*`)
- **OPTIONAL** *(but highly recommended)*: There are a number of properties that
  default to the value `CHANGEME` (e.g. passwords), you should change them.
- **OPTIONAL** *(but highly recommended)*: You need to specify 
  `monitor.sensu.client.subscriptions` for each host to specify what 
  checks/metrics they should subscribe to.  By default the `SPECFILE` will 
  subscribe hosts to the `all` channel, which will let you easily get up and 
  running, but is most likely overkill.
- **OPTIONAL**: `monitor.sensu.check_system` includes a basic set of system
  checks, and defaults to `true`. If you'd like to exclude it for any reason 
  you can set this to `false`.
- **OPTIONAL**: `monitor.graphite.storage_dir` is set to the default value for
  graphite on the root partition, but you may want to move it to a volume with
  more storage.

## checks and metrics

You will need to provide the appropriate checks and metrics that you want to
monitor in your environment.  By default the `monitor.sensu.server` state 
includes a very basic set of system checks for the `all` subscribers that you 
can use to validate things are working (`/etc/sensu/conf.d/check_system.json`), 
but you will most likely want to specify your own checks and metrics.  The 
recommended path forward is to manage those checks and metrics with another 
formula.  That formula simply needs to manage a number of files in 
`/etc/sensu/conf.d` like:

- `/etc/sensu/conf.d/check_foo.json`
- `/etc/sensu/conf.d/metric_bar.json`

You can provision multiple checks and metrics as long as they don't
collide with other checks and metrics.  


## caveats

The main monitoring host components are only written for and tested on Ubuntu.
The client and plugins will work on both Ubuntu and RHEL systems.


