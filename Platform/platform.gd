extends Area2D
class_name Platform

var is_floor:bool = false
var touched:bool = false
var dieing:bool = false


func _ready():
	#Log.write(Log.Type.DEBUG, "Platform created")
	$AnimationPlayer.play("create")


func _on_body_entered(body):
	if body is Player:
		if body.velocity.y > 0:
			body.jump()
			if not touched and not is_floor:
				touched = true
				#GameManager.add_score(1)


func die():
	if dieing:
		return

	dieing = true
	#Log.write(Log.Type.DEBUG, "Platform removed")
	$AnimationPlayer.play("die")
