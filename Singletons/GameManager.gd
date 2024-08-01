extends Node

var build_number = "0.1.0.c"
var production = false

var console:Control
var log_label:RichTextLabel
var _log_msgs:String = ""

signal onPauseGame
signal onNewGame
signal onScore
signal onGameOver

var save_file = "user://highscore.save"
var _score:int

# game_data loading:
#	load default game data:  default_game_data()
#	merge in game_data from save file, if any
#	merge in game_data_overrides
#	save back to disk
#	note:   Override fields clobber any other data. 
#			Used for testing and for build_number, etc.

var game_data

var game_data_overrides = {
	"build_number": build_number,
	"red_skin_unlocked": false,
	"player_skin": "yellow",
	"production": production,
	"high_score": 300,
}


func _ready():
	setup()
	process_mode = Node.PROCESS_MODE_ALWAYS


func setup():
	#remove_data()	# only used to force delete saved data file
	load_data()
	game_data.merge(game_data_overrides, true)
	save_data()
	set_score(0)
	log_game_data()

func log_msg(msg:String):
	
	print("log_msg: %s" % msg)
	if console == null:
		console = get_tree().get_first_node_in_group("debug_console")
	
	if console == null:
		return
	
	if log_label == null:
		log_label = console.find_child("LogLabel")
	
	if log_label == null:
		return
	
	if _log_msgs == "":
		_log_msgs = "==== LOG STARTED " + Time.get_date_string_from_system() + "\n"

	_log_msgs += Time.get_time_string_from_system() + ": " + msg + "\n"
	log_label.text = _log_msgs


func log_error(msg:String):
	log_msg("ERROR: %s" % msg)


func add_score(amount:int):
	set_score(_score + amount)


func get_score() -> int:
	return _score


func set_score(amount:int):
	_score = amount
	onScore.emit(_score)
	set_high_score()
	#log_msg("Score: %d" % _score)


func get_high_score() -> int:
	return game_data["high_score"]


func set_high_score():
	if _score < game_data["high_score"]:
		return
	game_data["high_score"] = _score
	red_skin_unlock()
	set_player_color("red")
	
	save_data()
	#log_msg("New High Score: %d" % _high_score)


func reset_high_score():
	game_data["high_score"] = 0
	save_data()


func set_player_color(new_color:String):
	if new_color == game_data["player_skin"]:
		return

	if new_color not in ["yellow", "red"]:
		game_data["player_skin"] = "yellow"
	else:
		game_data["player_skin"] = new_color
	
	save_data()


func get_player_color() -> String:
	set_player_color(game_data["player_skin"])
	return game_data["player_skin"]


func red_skin_unlock():
	game_data["red_skin_unlocked"] = true
	save_data()


func is_red_skin_unlocked() -> bool:
	return game_data["red_skin_unlocked"]


func get_sounds_enabled() -> bool:
	return game_data["sounds_enabled"]


func set_sounds_enabled(onoff:bool):
	game_data["sounds_enabled"] = onoff
	save_data()


func log_game_data():
	for key in game_data.keys():
		var msg = "==> GameData: [%s] = %s" % [key, str(game_data[key])]
		log_msg(msg)


func save_data():
	#game_data.merge(game_data_overrides, true)
	
	var fh = FileAccess.open(save_file, FileAccess.WRITE)
	fh.store_var(game_data)
	fh.close()
	#log_msg("Saved game data to disk")


func load_data():
	default_game_data()
	
	var fh = FileAccess.open(save_file, FileAccess.READ)
	if fh:
		log_msg("Loaded data from disk")
		game_data.merge(fh.get_var(), true)
		fh.close()
	else:
		log_msg("Loaded data from defaults")

	save_data()


func default_game_data():
	# set all fields to default values
	game_data = {
		"build_number": build_number,
		"high_score": 250,
		"player_skin": "yellow",
		"sounds_enabled": true,
		"red_skin_unlocked": false,
		"yellow_skin_unlocked": true
	}


func remove_data():
	if not FileAccess.file_exists(save_file):
		return
	DirAccess.remove_absolute(save_file)
	default_game_data()
	save_data()
