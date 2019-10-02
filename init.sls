monit:
  pkg.installed: []
  service.running:
    - enable: true
    - require:
      - pkg: monit
    - watch:
      - file: /etc/monit/conf.d/*

# Make sure all files not managed by Salt are removed from /etc/monit/conf.d
/etc/monit/conf.d:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - clean: true
    - require:
{% for name in pillar['monit'].keys() %}
      - file: /etc/monit/conf.d/{{ name }}.conf
{% endfor %}

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
