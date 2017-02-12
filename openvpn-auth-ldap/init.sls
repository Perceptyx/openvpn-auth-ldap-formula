{% from "openvpn-auth-ldap/map.jinja" import map with context %}

{% set openvpn_auth_ldap  = salt['pillar.get']('openvpn_auth_ldap', {}) %}

openvpn-auth-ldap:
    pkg.installed

/etc/openvpn/auth:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

auth-ldap-script:
  file.managed:
    - name: /etc/openvpn/auth/auth-ldap.conf
    - source: salt://openvpn-auth-ldap/files/auth-ldap.jinja
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
      openvpn_auth_ldap: {{ openvpn_auth_ldap|json }}
    - watch_in:
{% if salt['grains.has_value']('systemd') %}
{% for type, names in salt['pillar.get']('openvpn', {}).iteritems() %}
{% if type in ['client', 'server', 'peer'] %}
{% for name in names %}
        - service: openvpn_{{name}}_service
{% endfor %}
{% endif %}
{% endfor %}
{% else %}
        - service: openvpn_service
{% endif %}

