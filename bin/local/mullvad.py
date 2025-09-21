#!/usr/bin/python3

import json
import urllib.request
import random
import os

def get_servers():
	filepath=os.getenv('XDG_RUNTIME_DIR')+"/mullvad-servers"
	url="https://api.mullvad.net/www/relays/all/"
	try:
		with open(filepath,'r') as file:
			servers=json.load(file)
			return servers
	except:
		with open(filepath,'w') as file:
			servers=json.load(urllib.request.urlopen(url))
			json.dump(servers,file,indent=4)
			return servers

def filter(args,servers):
	servers=[x for x in servers if x['type']=='wireguard']
	if len(args)>1:
		servers=[x for x in servers if x['country_code']==args[1]]
	if len(args)>2:
		servers=[x for x in servers if x['city_code']==args[2]]

	servers=[x for x in servers if x['active']==True]
	servers=[x for x in servers if x['status_messages']==[]]

	return servers

def pick_server(servers):
	server=servers.pop(random.randint(0,len(servers)-1))
	print (json.dumps(server, indent=4))

	return server

