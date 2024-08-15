extends TextureButton
class_name ScreenButton

signal clicked(button:TextureButton)

func _on_pressed():
	clicked.emit(self)
