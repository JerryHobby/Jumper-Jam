extends Control

const IN = 1.0
const OUT = 0.0
const FADE_TIME = 0.5


func _ready():
	visible = false
	modulate.a = OUT
	get_tree().call_group("buttons", "set_disabled", true)


func appear():
	visible = true
	await fade(IN)
	get_tree().call_group("buttons", "set_disabled", false)


func disappear():
	get_tree().call_group("buttons", "set_disabled", true)
	await fade(OUT)
	visible = false


func fade(goal:float):
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", goal, FADE_TIME)
	await (tween.finished)
