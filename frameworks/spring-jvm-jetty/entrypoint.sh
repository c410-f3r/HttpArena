#!/bin/sh
set -e

# Convert PEM cert+key to PKCS12 keystore for Jetty
if [ -f /certs/server.crt ] && [ -f /certs/server.key ]; then
    openssl pkcs12 -export \
        -in /certs/server.crt -inkey /certs/server.key \
        -out /tmp/keystore.p12 -passout pass:changeit -name server
fi

exec java -jar app.jar
