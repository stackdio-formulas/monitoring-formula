
#
# Add the appropriate repo based on Debian/RH
#

sensu-repo:
  pkgrepo:
    - managed
{% if grains["os_family"] == "Debian" %}
    - key_url: http://repositories.sensuapp.org/apt/pubkey.gpg 
    - name: deb http://repositories.sensuapp.org/apt sensu main
    - refresh_db: true
{% elif grains["os_family"] == "RedHat" %}
    - humanname: sensu
    - name: sensu
    - baseurl: http://repositories.sensuapp.org/yum/$basearch/
    - gpgcheck: 0
    - enabled: 1
{% endif %}

