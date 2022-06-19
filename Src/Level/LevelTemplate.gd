extends Node2D

onready var enemy_path = preload("res://Src/Enemy/Enemy.tscn")
onready var timer: Timer = get_node("Respawn")
onready var slot3 = get_node("Gems/Slots/Slot3/Gem")
onready var slot3Default = preload("res://Assets/HUD/queue.png")
onready var wasp = preload("res://Assets/Tilesets/enemy_wasp.png")
onready var golem = preload("res://Assets/Tilesets/enemy_golem.png")
onready var phantom = preload("res://Assets/Tilesets/enemy_phantom.png")

var rand: Vector2
var wave
var num_enemies
var addStrength
var addType

func _ready():
	
	randomize()
	wave = 0
	num_enemies = 2
	timer.start()

func update_strength(gem_id: int):
	var diff_sizes = 4
	var gtype = int(gem_id / diff_sizes)
	var size = gem_id % diff_sizes
	addStrength = size + 1
	addType = gtype

func _on_Respawn_timeout():
	var val = slot3.get_node("Bar").value
	if (wave % 3) == 0:
		num_enemies += 1
	wave += 1
	for _i in num_enemies:
		# Randomize a pointer, multiplier by radius (=540) and
		# centralize with the screen (1920x1080)
		var enemy = enemy_path.instance()
		add_child(enemy)
		#var enemyStrength = int(rand_range(1, 8))
		var min_range = max(1, int(wave / 3))
		var max_range = 1 + int(wave / 2)
		var enemyStrength = int(rand_range(min_range, max_range))
		if val > 0:
			enemyStrength += addStrength
			val -= 10
			if val < 0:
				val = 0
			# Same Type or Opposite Type?
			enemy.type = addType
		else:
			enemy.type = int(rand_range(0, 4))
			if enemy.type == 4:
				enemy.type = 3
		if enemyStrength < 6:
			enemy.get_node("Sprite").texture = wasp
		elif enemyStrength < 12:
			enemy.get_node("Sprite").texture = phantom
		else:
			enemy.get_node("Sprite").texture = golem
		match enemy.type:
			0:
				enemy.get_node("Sprite").modulate = "#ff4b4b"
			1:
				enemy.get_node("Sprite").modulate = "#4b96ff"
			2:
				enemy.get_node("Sprite").modulate = "#806035"
			3:
				enemy.get_node("Sprite").modulate = "#c2ffff"
		enemy.speed = Vector2(100.0 / enemyStrength, 100.0 / enemyStrength)
		enemy.hitpoints = enemyStrength# * 2
		enemy.hp.value = enemyStrength# * 2
		enemy.hp.max_value = enemyStrength# * 2
		enemy.exp_points = enemyStrength
		enemy.damage = enemyStrength
		rand.x = rand_range(-1, 1)
		rand.y = rand_range(-1, 1)
		rand = rand.normalized()
		
		rand.x = 1920 + rand.x * 1920
		rand.y = 1080 - rand.y * 1080
		enemy.position = rand
	if val > 0:
		slot3.get_node("Bar").set_value(val)
	elif slot3.texture != slot3Default:
		slot3.texture = slot3Default
		slot3.modulate = "#ffffff"
		slot3.get_node("Bar").set_value(0)
	timer.start()
