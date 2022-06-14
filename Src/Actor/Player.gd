extends KinematicBody2D

onready var spawn: Position2D = get_node("SpawnPoint") 
onready var anim: AnimationPlayer = get_node("AnimationPlayer")
onready var projectile_path = preload("res://Src/Actor/Orb.tscn")

# Player Stats
export var speed: = Vector2(400.0, 400.0)
var last_direction = Vector2.RIGHT
var direction = Vector2.ZERO
var currentTime

var num_bullets = 1

var orbs_collected = []
enum types {Fire, Water, Earth, Air}
var diff_types = 4
var diff_sizes = 3

func _ready():
	currentTime = 0
	for x in diff_types:
		orbs_collected.append([])
		for y in range(diff_sizes):
			orbs_collected[x].append(0)

func _physics_process(delta: float) -> void:
	currentTime += delta
	direction = get_direction()
	if direction: # Different than (0,0)
		last_direction = direction
	direction = move_and_slide(direction * speed)
	
	# With keyboard, this is enough. With Gamepad, may need what's down there
	look_at(get_global_position() + direction)
	
	if Input.is_action_just_pressed("cast") and anim.current_animation == "Idle":
		shoot()

func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

func shoot() -> void:
	var vel_b = last_direction.normalized()
	for i in num_bullets: #(0 ~ num_bullets - 1)
		if i == 0:
			var projectile = projectile_path.instance()
			get_parent().add_child(projectile)
			projectile.position = spawn.global_position
			projectile.speed = speed.x * 2
			projectile.velocity = vel_b
		elif i % 2 == 1:
			var projectile = projectile_path.instance()
			get_parent().add_child(projectile)
			projectile.position = spawn.global_position
			projectile.speed = speed.x * 2
			projectile.velocity = vel_b.rotated(deg2rad(5 * int(i / 2 + 1)))
		else:
			var projectile = projectile_path.instance()
			get_parent().add_child(projectile)
			projectile.position = spawn.global_position
			projectile.speed = speed.x * 2
			projectile.velocity = vel_b.rotated(deg2rad(-5 * int(i / 2)))

func get_exp(value, type) -> void:
	print(orbs_collected)
	orbs_collected[types.get(type)][0] += value
	if orbs_collected[types.get(type)][0] >= 10:
		orbs_collected[types.get(type)][0] -= 10
		orbs_collected[types.get(type)][1] += 1
		if orbs_collected[types.get(type)][1] >= 10:
			orbs_collected[types.get(type)][1] -= 10
			orbs_collected[types.get(type)][2] += 1
	print(orbs_collected)

func take_damage() -> void:
	print("Ouch!")

func _on_animation_finished(anim_name):
	if anim_name == "Rest":
		anim.play("Idle")

	# With Gamepad may need the below
	# var aim_direction = Vector2.ZERO
	# var dead_zone = 0.2
	# if direction.x > dead_zone:
	# 	aim_direction.x = 1
	# elif direction.x < -dead_zone:
	# 	aim_direction.x = -1
	# if direction.y > dead_zone:
	# 	aim_direction.y = 1
	# elif direction.y < -dead_zone:
	# 	aim_direction.y = -1
	# look_at(get_global_position() + aim_direction)
