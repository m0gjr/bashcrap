#!/usr/bin/python3

def is_floating(container) -> bool:
	if container.floating:
		# We're on i3: on sway it would be None
		# May be 'auto_on' or 'user_on'
		return "_on" in container.floating
	else:
		# We are on sway
		return container.type == "floating_con"


def set_splitting(i3, event) -> None:
	workspace=i3.get_tree().find_focused().workspace()
	tiled_windows = [leaf for leaf in workspace.leaves() if not is_floating(leaf) and not leaf.fullscreen_mode]
	if len(tiled_windows) == 1:
		window = tiled_windows[0]
		window.command("splith")
	elif len(tiled_windows) == 2:
		left, right = tiled_windows
		left.command("splitv")
		right.command("splitv")
		right.command("resize set width 45 ppt")
