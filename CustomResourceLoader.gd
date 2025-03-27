extends Node

var boltSpriteRes = preload("res://Abilities/Animations/BoltSprite.tres")
var chargeSpriteRes = preload("res://Abilities/Animations/ChargeSprite.tres")
var rockSpriteRes = preload("res://Abilities/Animations/RockSprite.tres")
var cellSpriteRes = preload("res://Abilities/Animations/CellSprite.tres")
var displaceSpriteRes = preload("res://Abilities/Animations/DisplaceSprite.tres")
var decaySpriteRes = preload("res://Abilities/Animations/DecaySprite.tres")
var fountainSpriteRes = preload("res://Abilities/Animations/Spells/FountainSprite.tres")
var crackSpriteRes = preload("res://Abilities/Animations/Spells/CrackSprite.tres")
var stormSpriteRes = preload("res://Abilities/Animations/Spells/StormSprite.tres")

var sunder_xp := 0
var entropy_xp := 0
var construct_xp := 0
var growth_xp := 0
var flow_xp := 0
var wither_xp := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	load_game()

func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")
		print("Saved data for Node: ", node)
		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	# read the first line
	var json_string = save_file.get_line()
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

	# Get the data from the JSON object
	var node_data = json.get_data()
	if node_data:
		sunder_xp = int(node_data["sunder_xp"])
		entropy_xp = int(node_data["entropy_xp"])
		construct_xp = int(node_data["construct_xp"])
		growth_xp = int(node_data["growth_xp"])
		flow_xp = int(node_data["flow_xp"])
		wither_xp = int(node_data["wither_xp"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func test():
	print("yu")
