extends Node2D

onready var enemy_path = preload("res://Src/Enemy/Enemy.tscn")
onready var timer: Timer = get_node("Respawn")
onready var slot3 = get_node("Gems/Slots/Slot3/Gem")

var rand: Vector2
var addStrength
var addType

func _ready():
	randomize()
	timer.start()

func update_strength(gem_id: int):
	var diff_sizes = 4
	var gtype = int(gem_id / diff_sizes)
	var size = gem_id % diff_sizes
	addStrength = size + 1
	addType = gtype

func _on_Respawn_timeout():
	var val = slot3.get_node("Bar").value
	for _i in 5:
		# Randomize a pointer, multiplier by radius (=540) and
		# centralize with the screen (1920x1080)
		var enemy = enemy_path.instance()
		add_child(enemy)
		var enemyStrength = int(rand_range(1, 8))
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
		enemy.speed = Vector2(200.0 / enemyStrength, 200.0 / enemyStrength)
		enemy.hitpoints = enemyStrength * 2
		enemy.exp_points = enemyStrength
		enemy.damage = enemyStrength
		
		rand.x = rand_range(-1, 1)
		rand.y = rand_range(-1, 1)
		rand = rand.normalized()
		
		rand.x = 960 + rand.x * 540
		rand.y = 540 + rand.y * 540
		enemy.position = rand
	if val > 0:
		slot3.get_node("Bar").set_value(val)
	elif slot3.texture != null:
		slot3.texture = null
		slot3.get_node("Bar").set_value(0)
	timer.start()
