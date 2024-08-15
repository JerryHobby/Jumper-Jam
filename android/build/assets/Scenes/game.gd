extends Node2D

@onready var game_camera:Camera2D
@onready var platforms = $Platforms
@onready var level_generator = $LevelGenerator
@onready var ground_sprite = $GroundSprite
@onready var hud = $CanvasLayer/HUD

var game_camera_scene:PackedScene = preload("res://Scenes/game_camera.tscn")
var platform_scene:PackedScene = preload("res://Platform/platform.tscn")
var player_scene:PackedScene = preload("res://Player/player.tscn")
var player:Player
var viewport_size:Vector2

func _ready():
	hud.visible = false
	viewport_size = get_viewport_rect().size
	Log.write(Log.Type.INFO, "Viewport size: %d / %d" % [viewport_size.x, viewport_size.y])
	setup_parallax_background()
	
	ground_sprite.global_position.x = viewport_size.x / 2
	ground_sprite.global_position.y = viewport_size.y
	
	level_generator.setup(platforms)
	GameManager.onNewGame.connect(onNewGame)
	
	GameManager.load_node_tree()


func onNewGame():
	await get_tree().create_timer(0.5).timeout
	new_game()


func new_game():
	if player == null:
		GameManager.setup()
		add_player()
		add_camera()
		level_generator.generate_floor()
		level_generator.update_platforms()
	else:
		level_generator.clear_platforms()
		player.queue_free()
		game_camera.queue_free()
		player = null
		game_camera = null
		new_game()

	hud.visible = true


func add_player():
	player = player_scene.instantiate()
	player.global_position.x = viewport_size.x / 2
	player.global_position.y = viewport_size.y - 100
	add_child(player)


func add_camera():
	game_camera = game_camera_scene.instantiate()
	game_camera.setup(player)
	add_child(game_camera)


func setup_parallax_background():
	var p1 = $ParallaxBackground/ParallaxLayer1
	var p2 = $ParallaxBackground/ParallaxLayer2
	var p3 = $ParallaxBackground/ParallaxLayer3
	
	setup_parallax_layer(p1)
	setup_parallax_layer(p2)
	setup_parallax_layer(p3)
	
	p1.motion_scale.y = 0.1
	p2.motion_scale.y = 0.5
	p3.motion_scale.y = 0.8


func setup_parallax_layer(parallax_layer:ParallaxLayer):
	var sprite = parallax_layer.find_child("Sprite2D")
	
	if sprite == null:
		return
		
	sprite.scale = get_sprite_scale(sprite)
	var motion_y = sprite.scale.y * sprite.get_texture().get_height()
	
	parallax_layer.motion_mirroring.y = motion_y


func get_sprite_scale(sprite:Sprite2D) -> Vector2:
	var texture = sprite.get_texture()
	var width = texture.get_width()
	var sprite_scale = viewport_size.x / width
	
	return Vector2(sprite_scale, sprite_scale)
