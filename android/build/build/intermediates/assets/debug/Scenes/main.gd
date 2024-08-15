extends Node

@onready var iap_manager = $IAPManager

func _ready():
	get_viewport().focus_entered.connect(_on_window_focus_in)
	get_viewport().focus_exited.connect(_on_window_focus_out)
	iap_manager.unlock_new_skin.connect(_iap_unlock_new_skin)
	GameManager.onPurchaseSkin.connect(onScreenPurchaseSkin)


func _on_window_focus_in():
	get_tree().paused = false
	Log.write(Log.Type.DEBUG, "Window gained focus")


func _on_window_focus_out():
	get_tree().paused = true
	Log.write(Log.Type.DEBUG, "Window lost focus")


func _iap_unlock_new_skin():
	Log.write(Log.Type.INFO, "New skin unlocked")
	GameManager.unlock_red_skin()


func onScreenPurchaseSkin():
	Log.write(Log.Type.DEBUG, "Unlock skin button pressed")
	iap_manager.purchase_skin()
