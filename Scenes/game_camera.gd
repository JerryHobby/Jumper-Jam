extends Camera2D

@onready var destroyer = $Destroyer
@onready var destroyer_shape = $Destroyer/CollisionShape2D

var player:Player = null
var viewport_size:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_size = get_viewport_rect().size
	global_position = viewport_size / 2
	limit_bottom = int(viewport_size.y)
	
	destroyer.position.y = viewport_size.y / 2 - 50
	var rect_shape = RectangleShape2D.new()
	var rect_shape_size = Vector2(viewport_size.x, 450)
	rect_shape.size = rect_shape_size
	destroyer_shape.shape = rect_shape
	

func _process(_delta):
	var limit_margin = viewport_size.y / 3
	if player:
		if limit_bottom > player.global_position.y + limit_margin:
			limit_bottom = int(player.global_position.y + limit_margin)

	destroy_overlapping_platforms()


func destroy_overlapping_platforms():
	var overlapping_areas:Array = destroyer.get_overlapping_areas()

	if overlapping_areas.size() == 0:
		return
	
	for area in overlapping_areas:
		if area is Platform:
			area.die()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if player:
		global_position.y = player.global_position.y


func setup(_player:Player):
	if _player != null:
		player = _player
