extends KinematicBody2D

onready var spawn: Position2D = get_node("SpawnPoint") 
onready var anim: AnimationPlayer = get_node("AnimationPlayer")
onready var orb_path = preload("res://Src/Actor/Orb.tscn")

# Player Stats
var direction = Vector2.RIGHT
var currentTime

var num_bullets = 1
var type = -1
var speed = 200
var rot_speed = PI
var buff = 0

func _ready():
	currentTime = 0

func _physics_process(delta: float) -> void:
	currentTime += delta
	if buff < 0:
		buff = 0
		speed = 200
		rot_speed = PI
	else:
		buff -= delta

	var enemies = get_tree().get_nodes_in_group("Enemies")
	if not enemies.empty():
		#direction = (enemies[0].get_global_position() - get_global_position()).normalized()
		#look_at(get_global_position() + direction)
		var angle = (enemies[0].get_global_position() - get_global_position()).angle()
		var grot = global_rotation
		var angle_delta = rot_speed * delta
		angle = lerp_angle(grot, angle, 1.0)
		angle = clamp(angle, grot - angle_delta, grot + angle_delta)
		global_rotation = angle
		
		if anim.current_animation == "Idle":
			anim.play("Rest")
			shoot()

func update_staff(gem_id: int):
	if gem_id == -1:
		num_bullets = 1
		type = -1
	else:
		var diff_sizes = 4
		var gtype = int(gem_id / diff_sizes)
		var size = gem_id % diff_sizes
		num_bullets = 2 + size
		type = gtype

func update_tower(gem_id: int):
	var diff_sizes = 4
	var gtype = int(gem_id / diff_sizes)
	var size = gem_id % diff_sizes
	if gtype == 0:
		var enemies = get_tree().get_nodes_in_group("Enemies")
		for e in enemies:
			e.get_on_fire(5 + size * 5)
	elif gtype == 1:
		var enemies = get_tree().get_nodes_in_group("Enemies")
		for e in enemies:
			e.get_wet(5 + size * 5)
	elif gtype == 2:
		var enemies = get_tree().get_nodes_in_group("Enemies")
		for e in enemies:
			e.get_slowed(5 + size * 5)
	elif gtype == 3:
		speed = 200 + (size + 1) * 200
		rot_speed = PI + (size + 1) * PI / 2
		buff = 5 + size * 5

func shoot() -> void:
	var vel_b = (spawn.global_position - global_position).normalized()
	for i in num_bullets: #(0 ~ num_bullets - 1)
		var orb = orb_path.instance()
		get_parent().add_child(orb)
		orb.position = spawn.global_position
		orb.speed = speed
		orb.type = type
		if i == 0:
			orb.velocity = vel_b
		elif i % 2 == 1:
			orb.velocity = vel_b.rotated(deg2rad(10 * int(i / 2 + 1)))
		else:
			orb.velocity = vel_b.rotated(deg2rad(-10 * int(i / 2)))

func take_damage(value) -> void:
	#print("Ouch x", value, "!")
	pass

func _on_animation_finished(anim_name):
	if anim_name == "Rest":
		anim.play("Idle")
