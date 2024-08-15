extends CharacterBody2D
class_name Player

@export var speed:float = 300.0
@export var accelerometer_speed:float = 130.0
@export var jump_height:float = 600.0
@export var softness:float = 0.92 # 0.0 - 1.0

@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D

var gravity:float = 15.0
var max_fall_velocity:float = 1000.0

var dead:bool = false
var viewport_size:Vector2
var viewport_margin:int

var highest_position:int = 0

var use_accelerometer:bool = false
var current_os


func _ready():
	var sprite_width = $Sprite2D.texture.get_width() * $Sprite2D.scale.x
	viewport_size = get_viewport_rect().size

	viewport_margin = (sprite_width / 6)
	
	current_os = OS.get_name()
	highest_position = int(global_position.y)
	
	if current_os in ["Android", "iOS"]:
		use_accelerometer = true
		print("Using Accelerometer on ", current_os)
	


func _process(_delta):
	if dead:
		return
	calculate_score()


func _physics_process(delta):
	if Input.is_action_just_pressed("jump"):
		if GameManager.get_player_color() == "yellow":
			GameManager.set_player_color("red")
		else:
			GameManager.set_player_color("yellow")

	apply_gravity(delta)
	play_animation()
	
	''
	move(delta)
	move_and_slide()


func calculate_score():
	var score:int = 0
	if global_position.y < highest_position:
		score = highest_position - int(global_position.y)
		highest_position = int(global_position.y)
		if score:
			GameManager.add_score(score)



func apply_gravity(_delta):
	velocity.y += gravity
	if velocity.y > max_fall_velocity:
		velocity.y = max_fall_velocity


func play_animation():
	var fall_animation = "fall_%s" % GameManager.get_player_color()
	var jump_animation = "jump_%s" % GameManager.get_player_color()
	if velocity.y > 0:
		change_animation(fall_animation)
	else:
		change_animation(jump_animation)


func change_animation(animation:String):
	if animation_player.current_animation != animation:
		animation_player.play(animation)


func move(_delta):
	var direction:float
	
	if use_accelerometer:
		direction = Input.get_accelerometer().x * accelerometer_speed
	else:
		direction = Input.get_axis("move_left", "move_right") * speed
		
	if direction:
		# move
		velocity.x = direction
	else:
		# slow/stop
		velocity.x = move_toward(velocity.x, 0, speed * (1.0 - softness))


	if global_position.x > viewport_size.x + viewport_margin:
		global_position.x = -viewport_margin

	if global_position.x < -viewport_margin:
		global_position.x = viewport_size.x + viewport_margin


func jump():
	SoundFX.play("Jump")
	velocity.y = -jump_height



func _on_visible_on_screen_notifier_2d_screen_exited():
	die()


func die():
	if dead:
		return
	
	dead = true
	SoundFX.play("Fall")
	Log.write(Log.Type.INFO, "Player died")
	GameManager.set_high_score()
	collision_shape_2d.set_deferred("disabled", true)
	GameManager.onGameOver.emit()
