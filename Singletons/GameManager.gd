extends Node

var build_number = "0.1.0.c"
var production = false

var node_paths:Array = []

signal onPauseGame
signal onNewGame
signal onScore
signal onGameOver
signal onPurchaseSkin
signal onRestorePurchases


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
	#"player_skin": "yellow",
	"production": production,
	"high_score": 300,
}


func _ready():
	# only used to force delete saved data file
	#remove_data() 

	setup()
	
	# only used to force delete in-app purchase
	clear_red_skin()
	log_game_data()
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	#onPurchaseSkin.connect(unlock_red_skin)


func setup():
	load_data()
	game_data.merge(game_data_overrides, true)
	save_data()
	set_score(0)
	log_game_data()



func add_score(amount:int):
	set_score(_score + amount)


func get_score() -> int:
	return _score


func set_score(amount:int):
	_score = amount
	onScore.emit(_score)
	set_high_score()
	#Log.write(Log.Type.DEBUG, "Score: %d" % _score)


func get_high_score() -> int:
	return game_data["high_score"]


func set_high_score():
	if _score < game_data["high_score"]:
		return
	game_data["high_score"] = _score
	set_player_color("red")
	
	save_data()
	#Log.write(Log.Type.DEBUG, "New High Score: %d" % _high_score)


func reset_high_score():
	game_data["high_score"] = 0
	save_data()


func set_player_color(new_color:String):
	if new_color == game_data["player_skin"]:
		return

	if new_color not in ["yellow", "red"]:
		new_color = "yellow"

	if new_color == "red" and not is_red_skin_unlocked():
		new_color = "yellow"

	game_data["player_skin"] = new_color
	save_data()


func get_player_color() -> String:
	set_player_color(game_data["player_skin"])
	return game_data["player_skin"]


func unlock_red_skin():
	game_data["red_skin_unlocked"] = true
	set_player_color("red")
	#Log.print_log()


func clear_red_skin():
	game_data["red_skin_unlocked"] = false
	set_player_color("yellow")


func is_red_skin_unlocked() -> bool:
	return game_data["red_skin_unlocked"]


func get_sounds_enabled() -> bool:
	return game_data["sounds_enabled"]


func set_sounds_enabled(onoff:bool):
	game_data["sounds_enabled"] = onoff
	save_data()


func log_game_data():
	Log.write(Log.Type.DEBUG, "======== GAME DATA ========")
	for key in game_data.keys():
		var msg = "==> GameData: [%s] = %s" % [key, str(game_data[key])]
		Log.write(Log.Type.DEBUG, msg)


func save_data():
	var fh = FileAccess.open(save_file, FileAccess.WRITE)
	fh.store_var(game_data)
	fh.close()
	#Log.write(Log.Type.DEBUG, "Saved game data to disk")


func load_data():
	default_game_data()
	
	var fh = FileAccess.open(save_file, FileAccess.READ)
	if fh:
		Log.write(Log.Type.INFO, "Loaded data from disk")
		game_data.merge(fh.get_var(), true)
		fh.close()
	else:
		Log.write(Log.Type.INFO, "Loaded data from defaults")

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


func load_node_tree():
	GetTreeInfo()
	for path in node_paths:
		var mynode = get_node(path)
		var scene_path = mynode.scene_file_path
		if scene_path:
			Log.write(Log.Type.DEBUG, "Scene: %s" % path)
		else:
			Log.write(Log.Type.DEBUG, "-----: %s" % path)


func GetTreeInfo(node = get_tree().root):
	node_paths.append(node.get_path())
	
	for childNode in node.get_children():
		GetTreeInfo(childNode)
