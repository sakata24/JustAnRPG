class_name BGMPlayer extends AudioStreamPlayer

var dungeon_delving_bgm = preload("res://Resources/audio/music/Dungeon_Delving.mp3")

var currently_playing: String

# change bgm to the new based on string
func swap_bgm(bgm_name: String):
	if bgm_name == currently_playing:
		return
	match bgm_name:
		"default": set_stream(dungeon_delving_bgm)
		_: set_stream(dungeon_delving_bgm)
	play()

# on finish, loop bgm
func _on_finished() -> void:
	play()
