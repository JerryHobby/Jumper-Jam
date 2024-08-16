extends Node

var sounds = {
	"Fall":preload("res://Assets/sound/Fall.wav"),
	"Jump":preload("res://Assets/sound/Jump.wav"),
	"Click":preload("res://Assets/sound/Click.wav")
}

@onready var sound_players = get_children()


func play(sound:String):
	if GameManager.get_sounds_enabled() == false:
		return

	if sound not in sounds:
		Log.write(Log.Type.ERROR, "SoundFX.sound \"%s\" not found" % sound)
		return
	
	for check_player:AudioStreamPlayer in sound_players:
		if check_player.playing == false:
			#Log.write(Log.Type.DEBUG, "SoundFX - playing")
			check_player.stream = sounds[sound]
			check_player.play()
			return
	
	Log.write(Log.Type.ERROR, "SoundFX - No player available")
