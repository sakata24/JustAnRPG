extends CanvasLayer


func _ready():
	pass


func _on_StartButton_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")
