extends KinematicBody2D

onready var sceneTree: = get_tree()
onready var node: Node2D = get_node("Node2d") 
onready var spawn: Position2D = get_node("Node2d/SpawnPoint") 
onready var arrow: Sprite = get_node("Node2d/Arrow")
onready var anim: AnimationPlayer = get_node("AnimationPlayer")
onready var towerHP: ProgressBar = get_parent().get_node("TowerHP")
onready var orb_path = preload("res://Src/Actor/Orb.tscn")

# Player Stats
var direction = Vector2.RIGHT
var currentTime

var num_bullets = 1
var type = -1
var color = "#FFFFFF"
var speed = 200
var rot_speed = PI
var buff = 0
var facing = 0
var automode = true

func _ready():
	currentTime = 0
	towerHP.max_value = 1000
	towerHP.value = 1000

func _physics_process(delta: float) -> void:
	currentTime += delta
	if buff < 0:
		buff = 0
		speed = 200
		rot_speed = PI
	else:
		buff -= delta

	var enemies = get_tree().get_nodes_in_group("Enemies")
	if not automode:
		var angle = Input.get_action_strength("clockwise") - Input.get_action_strength("anticlockwise")
		angle = angle * rot_speed * delta
		node.global_rotation += angle
		angle = node.global_rotation
		if angle < -1.5:
			facing = 2
		elif angle < 0:
			facing = 3
		elif angle < 1.5:
			facing = 0
		elif angle < 3:
			facing = 1
		if Input.is_action_just_pressed("shoot") and anim.current_animation == "Idle":
			match facing:
				0:
					anim.play("Shoot0")
				1:
					anim.play("Shoot1")
				2:
					anim.play("Shoot2")
				3:
					anim.play("Shoot3")
	elif not enemies.empty():
		var loop = 0
		var dist
		var min_dist
		var closer_enemy = 0
		
		for e in enemies:
			if loop == 0:
				var pos = e.get_global_position() - node.get_global_position()
				min_dist = abs(pos.x) + abs(pos.y)
			else:
				var pos = e.get_global_position() - node.get_global_position()
				dist = abs(pos.x) + abs(pos.y)
				if dist < min_dist:
					min_dist = dist
					closer_enemy = loop
			loop += 1
		
		var angle = (enemies[closer_enemy].get_global_position() - node.get_global_position()).angle()
		var grot = node.global_rotation
		var angle_delta = rot_speed * delta
		angle = lerp_angle(grot, angle, 1.0)
		angle = clamp(angle, grot - angle_delta, grot + angle_delta)
		node.global_rotation = angle
		if angle < -1.5:
			facing = 2
		elif angle < 0:
			facing = 3
		elif angle < 1.5:
			facing = 0
		elif angle < 3:
			facing = 1
		
		if anim.current_animation == "Idle":
			match facing:
				0:
					anim.play("Shoot0")
				1:
					anim.play("Shoot1")
				2:
					anim.play("Shoot2")
				3:
					anim.play("Shoot3")

func update_staff(gem_id: int):
	if gem_id == -1:
		num_bullets = 1
		type = -1
		color = "#FFFFFF"
	else:
		var diff_sizes = 4
		var gtype = int(gem_id / diff_sizes)
		var size = gem_id % diff_sizes
		num_bullets = 2 + size
		type = gtype
		match type:
			0:
				color = "#ba0b04"
			1:
				color = "#09c3db"
			2:
				color = "#806043"
			3:
				color = "#a6e7ff"
	arrow.modulate = color

func update_tower(gem_id: int):
	if gem_id != -1:
		var diff_sizes = 4
		var gtype = int(gem_id / diff_sizes)
		var size = gem_id % diff_sizes
		if gtype == 0:
			var enemies = get_tree().get_nodes_in_group("Enemies")
			for e in enemies:
				e.get_on_fire(10 + size * 10)
		elif gtype == 1:
			var enemies = get_tree().get_nodes_in_group("Enemies")
			for e in enemies:
				e.get_wet(10 + size * 10)
		elif gtype == 2:
			var enemies = get_tree().get_nodes_in_group("Enemies")
			for e in enemies:
				e.get_slowed(10 + size * 10)
		elif gtype == 3:
			speed = 200 + (size + 1) * 200
			rot_speed = PI + (size + 1) * PI / 2
			buff = 10 + size * 10

func shoot() -> void:
	var vel_b = (spawn.global_position - global_position).normalized()
	for i in num_bullets: #(0 ~ num_bullets - 1)
		var orb = orb_path.instance()
		get_parent().add_child(orb)
		orb.position = spawn.global_position
		orb.speed = speed
		orb.type = type
		orb.get_node("Sprite").modulate = color
		if i == 0:
			orb.velocity = vel_b
		elif i % 2 == 1:
			orb.velocity = vel_b.rotated(deg2rad(10 * int(i / 2 + 1)))
		else:
			orb.velocity = vel_b.rotated(deg2rad(-10 * int(i / 2)))

func take_damage(value) -> void:
	towerHP.value -= value
	if towerHP.value <= 0:
		if GlobalSettings.score < get_parent().get_node("Gems").score:
			GlobalSettings.score = get_parent().get_node("Gems").score
		get_parent().get_node("GameOver").play("FadeOut")
		sceneTree.paused = true

func _on_animation_finished(anim_name):
	if anim_name != "Idle":
		shoot()
		anim.play("Idle")

func _on_AutoMode_button_up():
	automode = not automode
