extends Area2D

@onready var collision_shape = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_shape.size.x = get_viewport_rect().size.x
