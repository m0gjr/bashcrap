#!/bin/bash

for server in $(cat ~/serverlist) $(hostname)
do
	ssh $server bash <<'EOF' | sed -e "s/^/$server $(date): /"
		cat /var/run/reboot-required 2> /dev/null &&
		sudo init 6
EOF

done
