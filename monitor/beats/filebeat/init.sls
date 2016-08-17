include:
  - monitor.beats

filebeat_pkg:
  pkg:
    - installed
    - name: filebeat
    - require:
      - pkgrepo: beat-repo


