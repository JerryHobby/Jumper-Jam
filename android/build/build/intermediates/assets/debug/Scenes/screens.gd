extends CanvasLayer

@onready var toggle_console = $Debug/ToggleConsole
@onready var log_label = $Debug/ConsoleLog/ScrollContainer/VBoxContainer/LogLabel

@onready var console_log = $Debug/ConsoleLog
@onready var shop_screen = $ShopScreen

@onready var title_screen = $TitleScreen

@onready var pause_screen = $PauseScreen
@onready var game_over_screen = $GameOverScreen



var current_screen:Control = null


# Called when the node enters the scene tree for the first time.
func _ready():
	register_buttons()
	change_screen(title_screen)
	
	GameManager.onPauseGame.connect(onPauseGame)
	GameManager.onGameOver.connect(onGameOver)


func register_buttons():
	var buttons:Array = get_tree().get_nodes_in_group("buttons")
	if buttons.size() == 0:
		Log.write(Log.Type.ERROR, "Unable to register buttons. None found in group \"buttons\".")
		return
	
	for button in buttons:
		if button is ScreenButton:
			button.clicked.connect(_on_button_pressed)
			Log.write(Log.Type.DEBUG, "Button registered: %s" % button.name)


func _on_button_pressed(button:TextureButton):
	Log.write(Log.Type.DEBUG, "Button clicked: %s" % button.name)
	SoundFX.play("Click")
	match button.name:
		"GameOverRetryButton":
			_onGameOverRetryButton()
		"GameOverBackButton":
			_onGameOverBackButton()
		"TitlePlay":
			_onTitlePlay()
		"PauseCloseButton":
			_onPauseCloseButton()
		"PauseRetryButton":
			_onPauseRetryButton()
		"PauseBackButton":
			_onPauseBackButton()
		"TitleShop":
			_onTitleShopButton()
		"ShopPurchaseSkin":
			_onShopPurchaseSkinButton()
		"ShopClose":
			_onShopCloseButton()


func _onGameOverRetryButton():
	change_screen(null)
	GameManager.onNewGame.emit()


func _onGameOverBackButton():
	get_tree().reload_current_scene()


func _onTitlePlay():
	change_screen(null)
	GameManager.onNewGame.emit()


func _onPauseCloseButton():
	change_screen(null)


func _onPauseRetryButton():
	change_screen(null)
	GameManager.onNewGame.emit()


func _onPauseBackButton():
	get_tree().reload_current_scene()


func _onTitleShopButton():
	change_screen(shop_screen)


func _onShopPurchaseSkinButton():
	GameManager.onPurchaseSkin.emit()
	change_screen(title_screen)


func _onShopCloseButton():
	change_screen(title_screen)


func onPauseGame():
	change_screen(pause_screen)


func onGameOver():
	change_screen(game_over_screen)


func change_screen(new_screen):
	if current_screen:
		# no await here to allow new screen to appear 
		# in transition as overlap
		current_screen.disappear()
		current_screen = null
	
	if new_screen:
		Log.write(Log.Type.DEBUG, "Showing: %s" % new_screen.name)
		current_screen = new_screen
		get_tree().paused = true
		await current_screen.appear()
	else:
		get_tree().paused = false

