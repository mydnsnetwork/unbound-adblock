#!/bin/bash

if [[ "$1" == "" ]]; then
  UNBOUND_BLOCKED_HOSTS_DIR=/etc/unbound/blocked
else
  UNBOUND_BLOCKED_HOSTS_DIR="$1"
fi

lists=(
  'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/StevenBlack/hosts'
  'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/URLHaus/hosts'
  'https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts'
  'https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts'
  'https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts'
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

mkdir -p ${UNBOUND_BLOCKED_HOSTS_DIR}

# Start a counter
i=0

for value in "${domainLists[@]}"; do
  listName=$(echo "$value" | sed -E "s/(http:\/\/|https:\/\/)//g" | sed "s/\//-/g")
  data=$(curl -s "$value")
  echo "${data}" | grep -Ei '^[^#]' | awk '{print "local-zone: \""$1"\" always_null"}' > "${UNBOUND_BLOCKED_HOSTS_DIR}/${i}"
  ((i=i+1))
done
for value in "${lists[@]}"; do
  listName=$(echo "$value" | sed -E "s/(http:\/\/|https:\/\/)//g" | sed "s/\//-/g")
  data=$(curl -s "$value")
  echo "${data}" | grep -Ei '^(0.0.0.0|127.0.0.1)' | awk '{print "local-zone: \""$2"\" always_null"}' > "${UNBOUND_BLOCKED_HOSTS_DIR}/${i}"
  ((i=i+1))
done

# Reload config
if [[ "${2}" != "no-reload" ]]; then
  chown -Rf unbound:unbound "${UNBOUND_BLOCKED_HOSTS_DIR}"
  unbound-control reload >/dev/null 2>&1
  if [[ "$?" != "0" ]]; then
    echo "| WARN: unbound reload failed, trying to restart service..."
    supervisorctl restart unbound
    checkErr $? "Unbound service restart failed!"
  fi
fi

echo "| INFO: Blocklist update completed successfully..."