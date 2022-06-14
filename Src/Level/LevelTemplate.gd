extends Node2D

onready var enemy_path = preload("res://Src/Enemy/Enemy.tscn")
onready var timer: Timer = get_node("Respawn")

var rand: Vector2

func _ready():
	timer.start()

func _on_Respawn_timeout():
	# Randomize a pointer, multiplier by radius (=540) and
	# centralize with the screen (1920x1080)
	var enemy = enemy_path.instance()
	add_child(enemy)
	var enemyStrength = int(rand_range(1, 8))
	enemy.type = int(rand_range(0, 4))
	if enemy.type == 4:
		enemy.type = 3
	enemy.speed = Vector2(800.0 / enemyStrength, 800.0 / enemyStrength)
	enemy.hitpoints = enemyStrength
	enemy.exp_points = enemyStrength
	enemy.damage = enemyStrength
	
	rand.x = rand_range(-1, 1)
	rand.y = rand_range(-1, 1)
	rand = rand.normalized()
	
	rand.x = 960 + rand.x * 540
	rand.y = 540 + rand.y * 540
	enemy.position = rand
	
	timer.start()
