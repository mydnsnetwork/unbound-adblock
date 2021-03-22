#!/bin/bash

if [[ "$1" == "" ]]; then
  UNBOUND_BLOCKED_HOSTS_FILE=/etc/unbound/unbound.blocked.hosts
else
  UNBOUND_BLOCKED_HOSTS_FILE="$1"
fi

lists=(
  'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/StevenBlack/hosts'
  'https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt'
  'https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt'
  'https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt'
  'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext'
)
domainLists=(
  'https://v.firebog.net/hosts/AdguardDNS.txt'
  'https://v.firebog.net/hosts/Admiral.txt'
  'https://v.firebog.net/hosts/Easylist.txt'
  'https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt'
)

echo "| INFO: Starting blocklist update..."
for value in "${domainLists[@]}"; do
  listName=$(echo "$value" | sed -E "s/(http:\/\/|https:\/\/)//g" | sed "s/\//-/g")
  data=$(curl -s "$value")
  echo "${data}" | grep -Ei '^[^#]' | awk '{print "local-zone: \""$1"\" redirect\nlocal-data: \""$1" A 0.0.0.0\""}' > "${UNBOUND_BLOCKED_HOSTS_DIR}/${listName}"
done

for value in "${lists[@]}"; do
  listName=$(echo "$value" | sed -E "s/(http:\/\/|https:\/\/)//g" | sed "s/\//-/g")
  data=$(curl -s "$value")
  echo "${data}" | grep -Ei '^(0.0.0.0|127.0.0.1)' | awk '{print "local-zone: \""$2"\" redirect\nlocal-data: \""$2" A 0.0.0.0\""}' > "${UNBOUND_BLOCKED_HOSTS_DIR}/${listName}"
done

chown -Rf unbound:unbound "${UNBOUND_BLOCKED_HOSTS_DIR}"

# Reload config
if [[ "${2}" != "no-reload" ]]; then
  unbound-control reload >/dev/null 2>&1
  if [[ "$?" != "0" ]]; then
    echo "| WARN: unbound reload failed, trying to restart service..."
    supervisorctl restart unbound
    checkErr $? "Unbound service restart failed!"
  fi
fi

echo "| INFO: Blocklist update completed successfully..."