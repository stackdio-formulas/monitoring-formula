#!/bin/bash

#
# Generate a self-signed certificate
#

openssl genrsa -des3 -passout pass:x -out {{pillar.thorn.web.domain}}.pass.key 2048
openssl rsa -passin pass:x -in {{pillar.thorn.web.domain}}.pass.key -out {{pillar.thorn.web.domain}}.key
rm {{pillar.thorn.web.domain}}.pass.key

echo "








" | openssl req -new -key {{pillar.thorn.web.domain}}.key -out {{pillar.thorn.web.domain}}.csr

openssl x509 -req -days 365 -in {{pillar.thorn.web.domain}}.csr -signkey {{pillar.thorn.web.domain}}.key -out {{pillar.thorn.web.domain}}.crt


