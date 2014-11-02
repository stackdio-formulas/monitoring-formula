
#
# Add the appropriate repo based on Debian/RH
#

sensu-repo:
  pkgrepo:
    - managed
{% if grains["os_family"] == "Debian" %}
    - key_url: http://repos.sensuapp.org/apt/pubkey.gpg
    - name: deb http://repos.sensuapp.org/apt sensu main
    - refresh_db: true
{% elif grains["os_family"] == "RedHat" %}
    - humanname: sensu-main
    - baseurl: http://repos.sensuapp.org/yum/el/$releasever/$basearch/
    - gpgcheck: 0
{% endif %}

