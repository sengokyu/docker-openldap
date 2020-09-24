#!/bin/bash

if [ -z "$SUFFIX" ]; then
    echo 'SUFFIX not specified. Re run docker command with -e SUFFIX=...'
    echo ' Example: docker run -e SUFFIX=dc=example,dc=com openldap'
    exit 1
fi

if [ -z "$ROOT_PW" ]; then
    echo 'ROOT_PW not specified. Default password will be used.'
fi

config_dir=/etc/openldap/slapd.d
schemas="collective corba cosine duaconf \
    dyngroup inetorgperson java misc \
    nis openldap pmi ppolicy"
root_dn=${ROOT_DN:-cn=root,${SUFFIX}}
hashed_pw=$(slappasswd -s "${ROOT_PW:-slappasswd}")

sed -i -e "s#^olcSuffix:.*#olcSuffix: $SUFFIX#" /ldif/config.ldif
sed -i -e "s#^olcRootDN:.*#olcRootDN: $root_dn#" /ldif/config.ldif
sed -i -e "s#^olcRootPW:.*#olcRootPW: $hashed_pw#" /ldif/config.ldif

## Clear default configuration
## 
rm -rf ${config_dir}/*

## Re create configuration
##
slapadd -n 0 -F $config_dir -l /ldif/config.ldif

## Import ldap schemas
##
for i in $schemas; do
    slapadd -q -n 0 -F $config_dir -l /etc/openldap/schema/${i}.ldif
done

chown -R ldap:ldap $config_dir

exec "$@"
