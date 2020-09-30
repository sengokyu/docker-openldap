FROM fedora

RUN dnf -y install openldap openldap-servers openldap-clients
RUN rm -rf /var/lib/rpm/* /var/lib/dnf/*

COPY ldif /etc/openldap/init
COPY docker-entrypoint.sh /usr/local/bin

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "/usr/sbin/slapd", "-d", "0", "-u", "ldap", "-h", "ldap:/// ldaps:/// ldapi:///" ]

EXPOSE 389

VOLUME ["/etc/openldap", "/var/lib/ldap"]
