FROM fedora

RUN dnf -y install openldap openldap-servers openldap-clients

ADD ldif /ldif
ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/usr/sbin/slapd", "-d", "0", "-u", "ldap", "-h", "ldap:/// ldaps:/// ldapi:///" ]

EXPOSE 389

VOLUME ["/etc/openldap", "/var/lib/ldap"]
