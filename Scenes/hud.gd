extends Control

@onready var top_bar_bg = $TopBarBG
@onready var top_bar = $TopBarBG/TopBar
@onready var score_label = $TopBarBG/TopBar/ScoreLabel


func _ready():
	var current_os = OS.get_name()
	var safe_area
	var safe_area_top:int = 0
	var screen_scale:float = 1.0

	
	GameManager.onScore.connect(onScore)

	if current_os in ["Android", "iOS"]:
		safe_area = DisplayServer.get_display_safe_area()
		safe_area_top = safe_area.position.y
		
	if current_os in ["iOS"]:
		screen_scale = DisplayServer.screen_get_scale()
		safe_area_top = int(safe_area_top / screen_scale)
	
	top_bar_bg.set_deferred("size.y", top_bar_bg.size.y + safe_area_top)
	#top_bar_bg.size.y += safe_area_top
	top_bar.position.y += safe_area_top
	
	GameManager.log_msg("Safe Area Top: %d" % safe_area_top)


func _process(_delta):
	if get_tree().paused == true and visible:
		visible = false
	if get_tree().paused == false and !visible:
		visible = true


func _on_pause_button_pressed():
	SoundFX.play("Click")
	print("Pause button pressed in HUD")
	get_tree().paused = true
	GameManager.onPauseGame.emit()


func onScore(score:int):
	score_label.text = str(score)
	
