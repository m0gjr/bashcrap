#!/usr/bin/python3

import os
import json
import sys

def get_workspace():
	workspaces=json.loads(os.popen('i3-msg -t get_workspaces').read())
	ws_num=[workspace['num'] for workspace in workspaces if workspace['focused']==True][0]
	return ws_num

def get_tree():
	tree=json.loads(os.popen('i3-msg -t get_tree').read())
	return tree

def get_active_node(nodes,num):
	for node in nodes:
		if node.get('num') == num:
			return node
		elif node.get('nodes') != []:
			result=get_active_node(node['nodes'],num)
			if result != None:
				return result

def get_leaf_ids(nodes):
	ids=[]
	for node in nodes:
		if node.get('nodes') != []:
			result=get_leaf_ids(node['nodes'])
			if result != None:
				ids=ids+result
		elif 'id' in node:
			ids.append(node['id'])
			if node.get('focused') == True:
				ids.append('focus')
	return ids

def get_focused_node(nodes):
        for node in nodes:
                if node.get('focused') == True:
                        return node
                elif node.get('nodes') != []:
                        result=get_focused_node(node['nodes'])
                        if result != []:
                                return result
        return []
