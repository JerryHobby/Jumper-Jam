extends Node

var console:Control
var log_label:RichTextLabel
var _log_msgs:Array = []

enum Type {DEBUG, INFO, ERROR}

var prefix:Array = [
	"DEBUG",
	"INFO ",
	"ERROR"
]

var ShowDEBUG = true
var ShowINFO = true
var ShowERROR = true

var max_log_lines = 1000


# write - adds log messages to the _log_msgs array.
# if write_display - outputs to the debug output in Godot
# if write_console - outputs to the console area in the game.
# it only outputs to the display or console based on the 
# Show flags.  However, a print_log() function exists to print
# the contents of _log_msgs without regard to those flags.
# The _log_msgs array gets truncated to the max_log_lines size.

func write(type:Type, msg:String):
	var write_display = false
	var write_console = false
	match type:
		Type.DEBUG:
			if ShowDEBUG:
				write_display = true
				write_console = true
		Type.INFO:
			if ShowINFO:
				write_display = true
				write_console = true
		Type.ERROR:
			if ShowERROR:
				write_display = true
				write_console = true
	
	msg = format_msg(type, msg)
	
	if _log_msgs.size() == 0:
		var header = format_msg(Type.INFO, "LOG STARTED " + Time.get_date_string_from_system())
		_log_msgs.append(header)
		print(header)

	_log_msgs.append(msg)
	_truncate_log()
	
	if write_display:
		print(msg)
	
	
	# this section could be rewritten to be unaware of the console
	# and simply return a filtered string.  Let the calling node
	# see what it needs to see.  
	
	if not write_console:
		return
		
	if console == null:
		console = get_tree().get_first_node_in_group("debug_console")
		if console == null:
			return
	
	if log_label == null:
		log_label = console.find_child("LogLabel")
		if log_label == null:
			return

	var new_text = ""
	for line:String in _log_msgs:
		if (line.contains(prefix[Type.DEBUG]) and ShowDEBUG) \
		or (line.contains(prefix[Type.INFO]) and ShowINFO) \
		or (line.contains(prefix[Type.ERROR]) and ShowERROR):
			new_text += line + "\n"
	
	log_label.text = new_text


func _truncate_log():
	while _log_msgs.size() > max_log_lines:
		_log_msgs.pop_front()


func print_log(prefix = ""):
	for line in _log_msgs:
		print(prefix + line)


func format_msg(type:Type, msg:String) -> String:
	var ts = Time.get_time_string_from_system()
	return "%s [%s] %s" % [ts, prefix[type], msg]

