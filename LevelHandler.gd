class_name LevelHandler extends Node2D

var boss_levels = [preload("res://Maps/DarkMageMap.tscn"), preload("res://Maps/LuminousEyeMap.tscn")]
var available_boss_levels = [preload("res://Maps/DarkMageMap.tscn"), preload("res://Maps/LuminousEyeMap.tscn")]
var maps = [preload("res://Maps/Map.tscn"), preload("res://Maps/Map1.tscn"), preload("res://Maps/Map2.tscn"), preload("res://Maps/Map3.tscn"), preload("res://Maps/Map4.tscn")]
var spawn = preload("res://Maps/Spawn.tscn")
var exit = preload("res://Maps/Exit.tscn")
var home = preload("res://Maps/Home.tscn")

var current_level: int = 0
var boss_level_multiple: int = 5 # default floor multiple boss spawns on
var exit_room: Vector2i = Vector2i() # the location of the room
var roomArray = []
var MAP_SIZE = 4 # sqrt of room amt

@onready var main = get_parent()
@onready var player: Player = main.get_node("Player")

@export var initial_level: Node2D # for debugging purposes

func _ready() -> void:
	if get_child_count() <= 0:
		add_child(home.instantiate())
	for room in get_children():
		init_room_connections(room)
	if Settings.dev_mode:
		boss_level_multiple = 2

# called every time a player goes thru the door
func _load_level():
	# inc difficulty when loading
	current_level += 1
	main.get_node("HUD").set_floor(current_level)
	# clean rooms node
	for child in get_children():
		child.queue_free()
	player.moving = false
	# clear groups
	for spell in get_tree().get_nodes_in_group("spells"):
		spell.queue_free()
	# init rooms
	if current_level % boss_level_multiple == 0:
		if available_boss_levels.size() <= 0:
			reset_boss_level_array()
		init_boss_room()
	else:
		init_rooms()
	# move player
	player.position = get_player_spawn(get_children())
	# save the state of the game every level to be persisted
	SaveLoader.save_game()

func get_player_spawn(rooms: Array) -> Vector2:
	# find where to spawn the player
	for room in rooms: 
		if room.has_node("PlayerSpawnPos"):
			return room.get_node("PlayerSpawnPos").global_position
	# if none, spawn in top left room center
	return Vector2(250, 250)

func reset_boss_level_array():
	available_boss_levels = boss_levels

func init_boss_room():
	# randomly choose a boss+room to spawn
	var random_num = randi_range(0, available_boss_levels.size()-1)
	var new_room = available_boss_levels[random_num].instantiate()
	add_child(new_room)
	# remove it from the array
	available_boss_levels.remove_at(random_num)
	setup_boss_room(new_room)

func setup_boss_room(new_room: Node2D):
	for node in new_room.get_children():
		if node is Boss:
			node.connect("health_changed", get_parent().get_node("HUD")._on_boss_health_change)
			node.connect("boss_dead", get_parent().get_node("HUD").hide_boss_bar)
			get_parent().get_node("HUD").show_boss_bar(node.boss_name, node.health)
		if node is ExitDoor:
			node.connect("load_level", Callable(self, "_load_level"))

func init_rooms():
	exit_room = Vector2i(randi_range(1, MAP_SIZE-1), randi_range(1, MAP_SIZE-1))
	for i in range(0,MAP_SIZE):
		for j in range(0,MAP_SIZE):
			var newRoom: Node2D
			if Vector2i(0, 0) == Vector2i(i, j):
				newRoom = spawn.instantiate()
			elif exit_room == Vector2i(i, j):
				newRoom = exit.instantiate()
			else:
				var rand = randi_range(0,maps.size() - 1);
				newRoom = maps[rand].instantiate()
			newRoom.position = Vector2(position.x + (496.0 * i), position.y + (496.0 * j))
			
			# block off edges of map
			var tilemap: TileMapLayer = newRoom.get_node("NavigationRegion2D/Layer0")
			# top
			if j == 0:
				for n in range(0, 31):
					if n == 12:
						tilemap.set_cell(Vector2i(n, -1), 0, Vector2i(0, 3), 0)
					elif 12 < n and n < 18:
						tilemap.set_cell(Vector2i(n, -1), 0, Vector2i(1, 0), 0)
					elif n == 18:
						tilemap.set_cell(Vector2i(n, -1), 0, Vector2i(5, 0), 0)
					else:
						tilemap.set_cell(Vector2i(n, -1), 0, Vector2i(8, 7), 0)
			# left
			if i == 0:
				for n in range(0, 31):
					if 11 < n and n < 18:
						tilemap.set_cell(Vector2i(-1, n), 0, Vector2i(0, 1), 0)
					elif n == 18:
						tilemap.set_cell(Vector2i(-1, n), 0, Vector2i(0, 4), 0)
					else:
						tilemap.set_cell(Vector2i(-1, n), 0, Vector2i(8, 7), 0)
			# bottom
			if j == MAP_SIZE-1:
				for n in range(0, 31):
					if n == 12:
						tilemap.set_cell(Vector2i(n, 31), 0, Vector2i(0, 4), 0)
					elif 12 < n and n < 18:
						tilemap.set_cell(Vector2i(n, 31), 0, Vector2i(1, 4), 0)
					elif n == 18:
						tilemap.set_cell(Vector2i(n, 31), 0, Vector2i(5, 4), 0)
					else:
						tilemap.set_cell(Vector2i(n, 31), 0, Vector2i(8, 7), 0)
			# right
			if i == MAP_SIZE-1:
				for n in range(0, 31):
					if 11 < n and n < 18:
						tilemap.set_cell(Vector2i(31, n), 0, Vector2i(5, 1), 0)
					elif n == 18:
						tilemap.set_cell(Vector2i(31, n), 0, Vector2i(5, 4), 0)
					else:
						tilemap.set_cell(Vector2i(31, n), 0, Vector2i(8, 7), 0)
			add_child(newRoom)
			init_room_connections(newRoom)

func init_room_connections(newRoom: Node2D):
	for node in newRoom.get_children():
		if node is NPC:
			node.connect("button_pressed", main._add_menu)
		if node is ExitDoor:
			node.connect("load_level", _load_level)
		if node is Monster:
			node.maxHealth += node.maxHealth * current_level
			node.health += node.health * current_level
			node.my_dmg += node.my_dmg * current_level
			node.baseDmg += node.baseDmg * current_level
