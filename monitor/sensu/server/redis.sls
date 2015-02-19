
redis-server:
  pkg:
    - installed
  service:
    - running
    - enable: true
    - require:
      - pkg: redis-server
