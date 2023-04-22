monit:
  pkg.installed: []
  service.running:
    - enable: true
    - require:
      - pkg: monit

{% if grains['os'] == 'FreeBSD' %}
# FreeBSD doesn't use include by default
/usr/local/etc/monitrc:
  file.managed:
    - user: root
    - group: wheel
    - mode: 600
    - contents:
      - set daemon 30
      - set log syslog
      - include /usr/local/etc/monit.d/*
    - watch_in:
      - service: monit
{% endif %}

# Make sure all files not managed by Salt are removed from configuration directory
monit-config-directory:
  file.directory:
{% if grains['os'] == 'FreeBSD' %}
    - name: /usr/local/etc/monit.d
    - user: root
    - group: wheel
{% else %}
    - name: /etc/monit/conf.d
    - user: root
    - group: root
{% endif %}
    - mode: 755

monit-clean-directory:
  file.directory:
{% if grains['os'] == 'FreeBSD' %}
    - name: /usr/local/etc/monit.d
{% else %}
    - name: /etc/monit/conf.d
{% endif %}
    - clean: true
    - watch_in:
      - service: monit

{% for name in pillar['monit'].keys() %}
monit-{{ name }}:
  file.managed:
{% if grains['os'] == 'FreeBSD' %}
    - name: /usr/local/etc/monit.d/{{ name }}.conf
    - user: root
    - group: wheel
{% else %}
    - name: /etc/monit/conf.d/{{ name }}.conf
    - user: root
    - group: root
{% endif %}
    - mode: 644
    - contents_pillar: monit:{{ name }}
    - require:
      - pkg: monit
      - file: monit-config-directory
    - watch_in:
      - service: monit
    - require_in:
      - file: monit-clean-directory
{% endfor %}
