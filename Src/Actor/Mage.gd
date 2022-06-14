extends KinematicBody2D

onready var spawn: Position2D = get_node("SpawnPoint") 
onready var anim: AnimationPlayer = get_node("AnimationPlayer")
onready var projectile_path = preload("res://Src/Actor/Orb.tscn")

# Player Stats
var direction = Vector2.RIGHT
var currentTime

var num_bullets = 1
var speed = 400
var rot_speed = PI

func _ready():
	currentTime = 0

func _physics_process(delta: float) -> void:
	currentTime += delta
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

func shoot() -> void:
	var vel_b = (spawn.global_position - global_position).normalized()
	for i in num_bullets: #(0 ~ num_bullets - 1)
		if i == 0:
			var projectile = projectile_path.instance()
			get_parent().add_child(projectile)
			projectile.position = spawn.global_position
			projectile.speed = speed
			projectile.velocity = vel_b
		elif i % 2 == 1:
			var projectile = projectile_path.instance()
			get_parent().add_child(projectile)
			projectile.position = spawn.global_position
			projectile.speed = speed
			projectile.velocity = vel_b.rotated(deg2rad(5 * int(i / 2 + 1)))
		else:
			var projectile = projectile_path.instance()
			get_parent().add_child(projectile)
			projectile.position = spawn.global_position
			projectile.speed = speed
			projectile.velocity = vel_b.rotated(deg2rad(-5 * int(i / 2)))

func take_damage(value) -> void:
	print("Ouch x", value, "!")

func _on_animation_finished(anim_name):
	if anim_name == "Rest":
		anim.play("Idle")
