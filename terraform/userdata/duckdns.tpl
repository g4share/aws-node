#!/bin/bash
apt update; sudo apt full-upgrade -y;

#Updates the public IP on DuckDns site
DUCKDNS_SUBDOMAIN="${duckdns_subdomain}"
DUCKDNS_TOKEN="${duckdns_token}"

PER_BOOT_PATH=/var/lib/cloud/scripts/per-boot

printf "#\041/bin/bash\necho url=\"https://www.duckdns.org/update?domains=$${DUCKDNS_SUBDOMAIN}&token=$${DUCKDNS_TOKEN}&ip=\" | \
    curl -k -o $${PER_BOOT_PATH}/duck.log -K - " > $${PER_BOOT_PATH}/duck-dns.sh

chmod +x $${PER_BOOT_PATH}/duck-dns.sh
$${PER_BOOT_PATH}/duck-dns.sh

#Some updates require reboot - Optional
reboot