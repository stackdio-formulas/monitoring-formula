
#
# Setup a simple landing page
#

apache2-landing-pkg:
  pkg:
    - installed
    - name: apache2

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

apache2-svc:
  service:
    - running
    - name: apache2
    - watch: 
      - file: /etc/apache2/sites-available
      - file: /etc/apache2/ports.conf
      - file: /etc/apache2/sites-enabled/default.conf

