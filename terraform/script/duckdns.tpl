#!/bin/bash
yum update -y; yum upgrade -y

#Updates the public IP on DuckDns site
DUCKNS_SUBDOMAIN="${duckdns_subdomain}"
DUCKNS_TOKEN="${duckdns_token}"

PER_BOOT_PATH=/var/lib/cloud/scripts/per-boot

printf "#\041/bin/bash\necho url=\"https://www.duckdns.org/update?domains=$${DUCKNS_SUBDOMAIN}&token=$${DUCKNS_TOKEN}&ip=\" | \
    curl -k -o $${PER_BOOT_PATH}/duck.log -K - " > $${PER_BOOT_PATH}/duck-dns.sh

chmod +x $${PER_BOOT_PATH}/duck-dns.sh
$${PER_BOOT_PATH}/duck-dns.sh