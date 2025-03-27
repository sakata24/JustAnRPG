extends Node2D

var map0 = preload("res://Maps/Map.tscn")
var map1 = preload("res://Maps/Map1.tscn")
var map2 = preload("res://Maps/Map2.tscn")
var map3 = preload("res://Maps/Map3.tscn")
var spawn = preload("res://Maps/Spawn.tscn")
var exit = preload("res://Maps/Exit.tscn")
var boss_level = preload("res://Maps/MapBoss.tscn")
var exit_room = Vector2i()
var roomArray = []
var MAP_SIZE = 2 # sqrt of room amt
var dead = false
var menus = []
var level = 0
var boss_level_multiple = 5 # default floor multiple boss spawns on
enum {
	NONE,
	NORMAL,
	BOSS
}
var level_type: int = NONE # the type of level



# room hex: 25131a

func _ready():
	# connect hud to player
	$HUD.init($Player.health,$Player.max_health,str($Player.equippedSkills[0]),str($Player.equippedSkills[1]),str($Player.equippedSkills[2]),str($Player.equippedSkills[3]))
	$Player.connect("moving_to", Callable(self, "_show_click"))
	$Player.connect("cooling_down", Callable($HUD, "_set_cd"))
	$Player.connect("player_hit", Callable($HUD, "_set_health"))
	$Player.connect("player_hit", Callable(self, "_check_death"))
	$Player.connect("cooling_dash", Callable($HUD, "_set_dash_cd"))
	$Menu.connect("skill_changed", Callable(self, "_change_skills"))
	$Rooms/Home.connect("load_level", Callable(self, "_load_level"))
	$Rooms/Home/Tome.connect("button_pressed", Callable(self, "_add_menu"))
	$Rooms/Home/Tome.connect("button_pressed", Callable(self, "_give_tome_spells"))
	$Rooms/Home/Tome/ChangeSpells.connect("equip_skill", Callable(self, "_change_skills"))
	$Rooms/Home/Librarian.connect("button_pressed", Callable(self, "_add_menu"))
	$Rooms/Home/Librarian/Shop.connect("purchased", Callable(self, "_unlock_skill"))
	$Rooms/Home/Armorer.connect("button_pressed", Callable(self, "_add_menu"))
	update_shopkeeper()
	if Settings.is_dev_mode:
		boss_level_multiple = 2

# called every time a player goes thru the door
func _load_level():
	# inc difficulty when loading
	level += 1
	$HUD.set_floor(level)
	# clean rooms node
	for child in $Rooms.get_children():
		child.queue_free()
	# clean monsters group
	$Player.position = Vector2i(250, 250)
	$Player.moving = false
	$Player.move_target = $Player.position
	var prev_level_type = level_type
	# init rooms
	if level % boss_level_multiple == 0:
		level_type = BOSS
		init_boss_room()
	else:
		level_type = NORMAL
		init_rooms()
		$AudioStreamPlayer.swap_bgm("default")
	# save the state of the game every level to be persisted
	CustomResourceLoader.save_game()

func cleanup_previous_level():
	for enemy in get_tree().get_nodes_in_group("monsters"):
		# remove them from group first, so that generating rooms does not break the game
		enemy.remove_from_group("monsters")
		# then free them at the end of the frame
		enemy.queue_free()
	for spell in get_tree().get_nodes_in_group("skills"):
		# remove them from group first, so that generating rooms does not break the game
		spell.remove_from_group("monsters")
		# then free them at the end of the frame
		spell.queue_free()

func init_boss_room():
	var new_room = boss_level.instantiate()
	$Rooms.add_child(new_room)
	new_room.get_node("ExitDoor").connect("load_level", Callable(self, "_load_level"))
	for monster in get_tree().get_nodes_in_group("monsters"):
		monster.maxHealth += level * 100
		monster.health += level * 100
		monster.my_dmg *= 1 + (level/10)
		monster.baseDmg += 1 + (level/10)

func init_rooms():
	exit_room = Vector2i(randi_range(1, MAP_SIZE-1), randi_range(1, MAP_SIZE-1))
	for i in range(0,MAP_SIZE):
		for j in range(0,MAP_SIZE):
			var new_room
			if Vector2i(0, 0) == Vector2i(i, j):
				new_room = spawn.instantiate()
			elif exit_room == Vector2i(i, j):
				new_room = exit.instantiate()
				new_room.get_node("ExitDoor").connect("load_level", Callable(self, "_load_level"))
			else:
				var rand = randi_range(0,3);
				if rand == 0:
					new_room = map0.instantiate()
				elif rand == 1:
					new_room = map1.instantiate()
				elif rand == 2:
					new_room = map2.instantiate()
				else:
					new_room = map3.instantiate()
			new_room.position = Vector2(position.x + (496.0 * i), position.y + (496.0 * j))
			
			# block off edges of map
			var tilemap: TileMapLayer = new_room.get_node("NavigationRegion2D/Layer0")
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
			$Rooms.add_child(new_room)
	# fetch group of monsters on the map and connect their giveXp signals to player
	var monsters = get_tree().get_nodes_in_group("monsters")
	for monster in monsters:
		monster.maxHealth *= level
		monster.health *= level
		monster.my_dmg *= level
		monster.baseDmg *= level
		monster.connect("give_xp", Callable(self, "gain_xp"))

func gain_xp(amount, elements):
	print("gaining xp")
	for element in elements:
		PersistentData.increase_xp(amount, element)

func _unhandled_input(event):
	if event.is_action_pressed('ui_cancel') and !dead:
		# if no menu open, open the pause menu
		if menus.is_empty():
			menus.push_front($Menu)
			$Menu.visible = true
			# pass along the xp from player to the menu
			$Menu.update_exp_count(PersistentData.sunder_xp, PersistentData.entropy_xp, PersistentData.construct_xp, PersistentData.growth_xp, PersistentData.flow_xp, PersistentData.wither_xp)
			get_tree().paused = true
		# if menu is open, close it
		else:
			menus.pop_front().visible = false
			get_tree().paused = false

func _add_menu(menu):
	add_child(menu)
	menus.push_front(menu)
	menu.visible = true

func _show_click():
	$ClickAnimation.global_position = get_global_mouse_position()
	$ClickAnimation.set_frame(0)
	$ClickAnimation.visible = true
	$ClickAnimation.play()

func _on_click_animation_animation_finished():
	$ClickAnimation.visible = false

func _check_death(newHP, maxHP):
	if newHP <= 0:
		dead = true
		$Death.setup()
		$Death.visible = true
		# reset difficulty
		level = 0

func _change_skills(idx, newSkill):
	print("update skils")
	var key
	match idx:
		0: key = "Q"
		1: key = "W"
		2: key = "E"
		3: key = "R"
	$Player.equippedSkills[idx] = newSkill
	$Player.init_skill_cooldowns()
	get_node("HUD/Skill/Ability" + str(idx+1) + "/HBoxContainer/SkillMargin/SkillIcon").set_icon(newSkill, key)

func _unlock_skill(name, element, price):
	# check if player already has that spell
	if(PersistentData.get_unlocked_skills().has(name)):
		print("already has: " + name)
		return
	# check if player has enough xp for the transaction, then add it to the players spells
	match element:
		"sunder":
			if PersistentData.sunder_xp >= price:
				PersistentData.sunder_xp -= price
				PersistentData.unlockedSkills.append(name)
				$Rooms/Home/Librarian/Shop.remove_item(name)
		"entropy":
			if PersistentData.entropy_xp >= price:
				PersistentData.entropy_xp -= price
				PersistentData.unlockedSkills.append(name)
				$Rooms/Home/Librarian/Shop.remove_item(name)
		"construct":
			if PersistentData.construct_xp >= price:
				PersistentData.construct_xp -= price
				PersistentData.unlockedSkills.append(name)
				$Rooms/Home/Librarian/Shop.remove_item(name)
		"growth":
			if PersistentData.growth_xp >= price:
				PersistentData.growth_xp -= price
				PersistentData.unlockedSkills.append(name)
				$Rooms/Home/Librarian/Shop.remove_item(name)
		"flow":
			if PersistentData.flow_xp >= price:
				PersistentData.flow_xp -= price
				PersistentData.unlockedSkills.append(name)
				$Rooms/Home/Librarian/Shop.remove_item(name)
		"wither":
			if PersistentData.wither_xp >= price:
				PersistentData.wither_xp -= price
				PersistentData.unlockedSkills.append(name)
				$Rooms/Home/Librarian/Shop.remove_item(name)
	update_shopkeeper()

# make librarian update inventory based on players unlocked skills
func update_shopkeeper():
	$Rooms/Home/Librarian.update_inventory(PersistentData.get_unlocked_skills(), {"sunder xp": PersistentData.sunder_xp, "entropy xp": PersistentData.entropy_xp, "construct xp": PersistentData.construct_xp, "growth xp": PersistentData.growth_xp, "flow xp": PersistentData.flow_xp, "wither xp": PersistentData.wither_xp})

func _give_tome_spells(menu):
	$Rooms/Home/Tome/ChangeSpells.init(PersistentData.get_unlocked_skills(), $Player.get_equipped_skills())

func despawn_light():
	var tween = create_tween()
	tween.tween_property($CanvasModulate, "color", Color(1,1,1,1), 2)
	tween.parallel().tween_property($Player/PointLight2D, "modulate", Color(1,1,1,0), 2)
	await tween.finished
	$CanvasModulate.visible = false
	$CanvasModulate.color = Color(0,0,0,1)
	$Player/PointLight2D.visible = false
	$Player/PointLight2D.modulate = Color(1,1,1,1)
