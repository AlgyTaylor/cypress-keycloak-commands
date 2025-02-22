#!/bin/bash

function run_keycloak_ge_18() {
  mkdir -p /opt/keycloak/data/import/
  cp /tmp/example-realm.json /opt/keycloak/data/import/example-realm.json
  /opt/keycloak/bin/kc.sh start-dev --import-realm --http-relative-path=/auth
}

function run_keycloak_17() {
  echo "* Importing"
  /opt/keycloak/bin/kc.sh import --file "/tmp/example-realm.json"
  echo "* Starting"
  /opt/keycloak/bin/kc.sh start-dev --http-relative-path=/auth
  echo "* Done!"
}

function run_keycloak_le_16() {
  KEYCLOAK_IMPORT=/tmp/example-realm.json /opt/jboss/tools/docker-entrypoint.sh -b 0.0.0.0
}

if [ -f /opt/jboss/tools/docker-entrypoint.sh ]; then
  echo "* Keycloak <= 16 detected!"
  run_keycloak_le_16
  exit 0
fi

if [[ $KEYCLOAK_VERSION == 17* ]]; then
  echo "* Keycloak 17* detected!"
  run_keycloak_17
  exit 0
fi

echo "* Keycloak >= 18 detected!"
run_keycloak_ge_18