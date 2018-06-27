monit:
  pkg.installed: []
  service.running:
    - enable: true
    - require:
      - pkg: monit
    - watch:
      - file: /etc/monit/conf.d/*

{% for name in pillar['monit'].keys() %}
/etc/monit/conf.d/{{ name }}.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents_pillar: monit:{{ name }}
    - require:
      - pkg: monit
{% endfor %}
