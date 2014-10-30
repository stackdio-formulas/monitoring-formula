

# lump all of the dependencies into a single package state
all-packages:
    pkg:
    - installed
    - pkgs:
      - graphite-web
      - graphite-carbon
      - postgresql 
      - libpq-dev 
      - python-psycopg2 
      - apache2 
      - libapache2-mod-wsgi


