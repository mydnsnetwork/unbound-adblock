#!/bin/bash

UNBOUND_BLOCKED_HOSTS_DIR=/etc/unbound/blocked

lists=(
  'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/StevenBlack/hosts'
  'https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt'
  'https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt'
)

for value in "${lists[@]}"; do
  listName=$(echo "$value" | sed -E "s/(http:\/\/|https:\/\/)//g" | sed "s/\//-/g")
  data=$(curl -s "$value")
  echo "$data" | grep -Ei '^(0.0.0.0|127.0.0.1)' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' > "${UNBOUND_BLOCKED_HOSTS_DIR}/${listName}"
done

chown -Rf unbound:unbound "${UNBOUND_BLOCKED_HOSTS_DIR}"

# Reload config
if [[ "${1}" != "no-reload" ]]; then
  unbound-control reload >/dev/null 2>&1
  if [[ "$?" != "0" ]]; then
    echo "| WARN: unbound reload failed, trying to restart service..."
    supervisorctl restart unbound
    checkErr $? "Unbound service restart failed!"
  fi
fi