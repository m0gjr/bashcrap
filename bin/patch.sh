#!/bin/bash

if [ "$1" != "-v" ]
then
	exec 2> /dev/null
fi

for server in $(hostname) $(cat ~/serverlist)
do
	ssh $server bash <<'EOF' 3>&2 2>&1 1>&3 3>&- | sed -e "s/^/$server $(date): /"
		hostname
		echo
		sudo apt-get update &&
		sudo DEBIAN_FRONTEND=noninteractive apt-get -y --with-new-pkgs upgrade &&
		sudo apt-get -s autoremove | grep "Remv linux-" | cut -d" " -f2 | xargs sudo apt-get -y remove ||
		echo $(hostname) failed 1>&2
		echo
		echo
EOF

done
