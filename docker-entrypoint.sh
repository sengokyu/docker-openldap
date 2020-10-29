#!/bin/bash

set -e

etc_dir=/etc/openldap
config_dir=${etc_dir}/slapd.d
configured_flag=${etc_dir}/.configured

if [ -f $configured_flag ]; then
    exec "$@"
fi

echo 'Configurering OpenLDAP Server.'

if [ -z "$SUFFIX" ]; then
    echo 'SUFFIX not specified. Re run docker command with -e SUFFIX=...'
    echo ' Example: docker run -e SUFFIX=dc=example,dc=com openldap'
    exit 1
fi

if [ -z "$ROOT_PW" ]; then
    echo 'ROOT_PW not specified. Default password will be used.'
fi

schemas="collective corba cosine duaconf \
    dyngroup inetorgperson java misc \
    nis openldap pmi ppolicy"
root_dn=${ROOT_DN:-cn=root,${SUFFIX}}
root_pw=${ROOT_PW:-slappasswd}

add_init_config() {
    local init_ldif=${etc_dir}/init/config.ldif
    local hashed_pw=$(slappasswd -s "${root_pw}")

    sed -i \
        -e "s#^olcSuffix:.*#olcSuffix: $SUFFIX#" \
        -e "s#^olcRootDN:.*#olcRootDN: $root_dn#" \
        -e "s#^olcRootPW:.*#olcRootPW: $hashed_pw#" \
        ${init_ldif}

    ## Clear default configuration
    rm -rf ${config_dir}/*

    ## Re create configuration
    sudo -u ldap slapadd -n 0 -F $config_dir -l ${init_ldif}
}

add_schema() {
    for i in $schemas; do
        sudo -u ldap slapadd -n 0 -F $config_dir -l ${etc_dir}/schema/${i}.ldif
    done
}

add_base_entry() {
    local entry_ldif=${etc_dir}/init/entry.ldif
    local dc=`echo $SUFFIX | sed -e 's#^dc=\([^,]*\),.*#\1#'`

    sed -i \
        -e "s#^dn: .*#dn: $SUFFIX#" \
        -e "s#^dc: .*#dc: $dc#" \
        -e "s#^o: .*#o: $dc Organization#" \
        $entry_ldif
    
    sudo -u ldap slapadd -b "${SUFFIX}" -l $entry_ldif
}


add_init_config
add_schema
add_base_entry

touch ${configured_flag}

exec "$@"
