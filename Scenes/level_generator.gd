extends Node2D

var viewport_size:Vector2

var platform_gap:int = 100
var platform_width = 134
var platform_height = 60
var max_platforms:int = 8
var next_platform_y:float

var prev_platform_x:int = -1 # init
var _platforms_generated:int = 0
var _game_running:bool = false

var platform_scene:PackedScene = preload("res://Platform/platform.tscn")
var platforms:Node


# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_size = get_viewport_rect().size
	next_platform_y = viewport_size.y - platform_gap


func setup(game_platforms:Node):
	platforms = game_platforms


func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

	if _game_running:
		update_platforms()


func generate_floor():
	var floor_platforms = int(viewport_size.x / platform_width) + 1
	for i in floor_platforms:
		create_platform(Vector2(i * platform_width, viewport_size.y - platform_height ), true)


func update_platforms():
	_game_running = true

	var all_platforms = platforms.get_children()
	var num_platforms:int = 0

	max_platforms = int(viewport_size.y / (platform_gap + platform_height)) + 2

	for platform in all_platforms:
		if platform.is_floor == false:
			num_platforms += 1

	# remove floor platforms
	if num_platforms < max_platforms:
		generate_platforms(1)


func clear_platforms():
	var all_platforms = platforms.get_children()
	for platform in all_platforms:
		platform.queue_free()
	prev_platform_x = -1
	_platforms_generated = 0
	next_platform_y = viewport_size.y - platform_gap


func generate_platforms(num_platforms:int):
	platform_gap = 100

	if prev_platform_x < 0:
		prev_platform_x = int(viewport_size.x / 2)

	# ensure it's not too far away from prev platform
	var min_x = prev_platform_x - (platform_width * 2)
	if min_x <= 0:
		min_x = 0

	# not too far away
	var max_x = viewport_size.x - platform_width
	if max_x >= prev_platform_x + platform_width * 1:
		max_x = prev_platform_x + platform_width * 1

	for i in num_platforms:
		var x = randi_range(min_x, max_x)
		next_platform_y -= platform_gap
		create_platform(Vector2(x, next_platform_y))


func create_platform(location:Vector2, is_floor:bool = false):
	var platform:Platform = platform_scene.instantiate()
	platform.global_position = location

	var new_scale:float = platform.scale.x - (_platforms_generated * 0.0005)
	if new_scale < 0.2:
		new_scale = 0.2

	Engine.time_scale = 1 + _platforms_generated * 0.0005

	platform.scale.x = new_scale

	if is_floor:
		platform.is_floor = true
	else:
		_platforms_generated += 1

	platforms.add_child(platform)
	return platform
