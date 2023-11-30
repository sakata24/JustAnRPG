extends TextureRect

class_name SkillIcon

signal select
signal equip

const ART_PATH = "res://Resources/icons/"

var spell : String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func init(spl:String, text = ""):
	spell = spl
	$Label.text = text
	$ProgressBar.max_value = UniversalSkills._get_ability(spl)["cooldown"]
	_get_icon()


func _get_icon():
	if ResourceLoader.exists(ART_PATH+spell+".png"):
		texture = load(ART_PATH+spell+".png")
	else:
		texture = load("res://Resources/icon.png")


func set_icon(spl:String):
	spell = spl
	$ProgressBar.max_value = UniversalSkills._get_ability(spl)["cd"]
	_get_icon()


func empty():
	spell = ""
	texture = load("res://Resources/icons/default.png")


func _on_gui_input(event:InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if  event.is_action_pressed("R-Click"):
			print(spell + "-right clicked")
			emit_signal("equip", self)
		else:
			print(spell + "-clicked")
			emit_signal("select", self)
