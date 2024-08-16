extends Control
@onready var console_log = $ConsoleLog
@onready var build_number_label = $ConsoleLog/MarginContainer/BuildNumberLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	console_log.visible = false
	build_number_label.text = "Build Number: %s" % GameManager.build_number


func _on_toggle_console_pressed():
	SoundFX.play("Click")
	console_log.visible = !console_log.visible
	Log.write(Log.Type.DEBUG, "Console visible: %s" % console_log.visible)
