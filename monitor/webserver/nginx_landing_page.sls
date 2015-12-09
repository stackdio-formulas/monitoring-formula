
nginx:
  pkg:
    - installed

openssl:
  pkg:
    - installed

/var/www/html/errors:
  file:
    - recurse
    - makedirs: true
    - template: jinja
    - clean: true
    - source: salt://thorn/var/www/html/errors
    - require:
      - pkg: nginx

/var/www/html/id:
  file:
    - managed
    - makedirs: true
    - contents: '{{ grains.id }}'
    - require:
      - pkg: nginx

/etc/nginx/conf.d/:
  file:
    - recurse
    - makedirs: true
    - template: jinja
    - clean: true
    - source: salt://thorn/etc/nginx/sites-enabled
    - require:
      - file: /var/www/html/errors
      - file: /var/www/html/id

{% if pillar.thorn.web.gen_ssl %}
#
# generate a self signed cert - for development use only!!
#
generate_ssl_certs:
  cmd:
    - script
    - template: jinja
    - cwd: /home/{{pillar.__stackdio__.username}}/
    - source: salt://thorn/web/generate_ssl.sh
    - require:
      - pkg: openssl
    - require_in:
      - service: nginx-svc
{% endif %}

nginx-svc:
  service:
    - running
    - name: nginx
    - watch:
      - file: /var/www/html/errors
      - file: /var/www/html/id
      - file: /etc/nginx/conf.d/
    - require:
      - pkg: nginx

/var/log/nginx:
  file.directory:
    - mode: 755
    - require:
      - pkg: nginx

