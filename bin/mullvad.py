#!/usr/bin/python

import json
#import urllib.request
import urllib2
import random
import sys
import os.path

url="https://api.mullvad.net/www/relays/all/"
dir="/etc/wireguard"

#servers=json.load(urllib.request.urlopen(url))
servers=json.load(urllib2.urlopen(url))
#servers=json.load(open('api','r'))

servers=[x for x in servers if x['type']=='wireguard']
if len(sys.argv)>1:
	if sys.argv[1]=='-ip4':
		for x in servers: print (x['ipv4_addr_in'])
		sys.exit()
	if sys.argv[1]=='-ip6':
		for x in servers: print (x['ipv6_addr_in'])
		sys.exit()

	servers=[x for x in servers if x['country_code']==sys.argv[1]]
if len(sys.argv)>2:
	servers=[x for x in servers if x['city_code']==sys.argv[2]]

owned=[x for x in servers if x['owned']==1]
if len(owned)>0: servers=owned

server=servers[random.randint(0,len(servers)-1)]

print (json.dumps(server, indent=4))

hostname=server["hostname"]
servername="mullvad-"+hostname[:hostname.index('-')]

with open(os.path.join(dir,'template'),'r') as file:
	template=file.read()

#with open('outfile','w') as file:
with open(os.path.join(dir,servername+".conf"),'w') as file:
	file.write(template)
	file.write("PublicKey = "+server["pubkey"]+"\n")
	file.write("Endpoint = "+server["ipv4_addr_in"]+":51820"+"\n")

os.chmod(os.path.join(dir,servername+".conf"),0o600);
