# Fedora based plain OpenLDAP servers 

----

# Get Start

```
docker run -d -p 389:389 -e SUFFIX=dc=example,dc=com openldap
```

# Configuration

Following environment variables are supported.

* `SUFFIX` (required) Suffix of the base entry.
* `ROOT_PW` (optional) Password of root user. Default: slappasswd
* `ROOT_DN` (optional) DN of root user. Default: cn=root + SUFFIX


