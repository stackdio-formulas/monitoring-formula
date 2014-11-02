
#
# Setup a simple landing page
#

/var/www/html:
  file:
    - recurse
    - source: salt://monitor/var/www/html
    - template: jinja
    - makedirs: true

/etc/apache2/sites-enabled/000-default.conf:
  file:
    - absent 

/etc/apache2/sites-available:
  file:
    - recurse
    - source: salt://monitor/etc/apache2/sites-available/
    - template: jinja
    - clean: true
    - makedirs: true

/etc/apache2/ports.conf:
  file:
    - managed
    - source: salt://monitor/etc/apache2/ports.conf
    - template: jinja

/etc/apache2/sites-enabled/default.conf:
  file:
    - symlink
    - target: /etc/apache2/sites-available/default.conf
    - unless: ls /etc/apache2/sites-enabled/default.conf

/etc/apache2/sites-enabled/graphite.conf:
  file:
    - symlink
    - target: /etc/apache2/sites-available/graphite.conf
    - unless: /etc/apache2/sites-enabled/graphite.conf

/etc/apache2/sites-enabled/grafana.conf:
  file:
    - managed
    - contents: "alias /grafana /usr/share/grafana"

apache2-svc:
  service:
    - running
    - name: apache2
    - watch: 
      - file: /etc/apache2/sites-available
      - file: /etc/apache2/ports.conf
      - file: /etc/apache2/sites-enabled/default.conf
      - file: /etc/apache2/sites-enabled/graphite.conf
      - file: /etc/apache2/sites-enabled/grafana.conf

