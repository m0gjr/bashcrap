#!/bin/bash

for server in $(cat ~/serverlist) $(hostname)
do
	ssh $server bash <<'EOF' 2> /dev/null
		cat /var/run/reboot-required > /dev/null &&
		echo "$(hostname) will reboot for patching" &&
		sudo init 6
EOF

done
