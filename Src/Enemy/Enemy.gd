extends KinematicBody2D
class_name Enemy

onready var player: Node2D = get_parent().get_node("Mage")
onready var anim: AnimationPlayer = get_node("AnimationPlayer")
onready var spawn: Position2D = get_node("SpawnPoint")
onready var projectile_path = preload("res://Src/Enemy/Projectile.tscn")
onready var exp_path = preload("res://Src/Enemy/ExpPoint.tscn")

enum types {Fire, Water, Earth, Air}
var speed
var type
var hitpoints
var exp_points
var damage

var enemy_pos = Vector2()
var target_pos = Vector2()
var direction = Vector2()

func _ready():
	add_to_group("Enemies")

func _physics_process(_delta: float) -> void:
	enemy_pos = get_global_position()
	if is_instance_valid(player):
		target_pos = player.position - enemy_pos
		look_at(player.position)
	if abs(target_pos.x) > 150 or abs(target_pos.y) > 150:
		# Move towards player or tower?
		direction = target_pos.normalized()
		direction = move_and_slide(direction * speed)
	elif anim.current_animation == "Idle":
		if is_instance_valid(player):
			player.take_damage(damage)
			anim.play("Rest")

func take_damage() -> void:
	hitpoints -= 1
	if hitpoints <= 0:
		die()

func die() -> void:
	var exp_point = exp_path.instance()
	get_parent().add_child(exp_point)
	exp_point.position = global_position
	exp_point.value = exp_points
	exp_point.type = type
	queue_free()

func _on_animation_finished(anim_name):
	if anim_name == "Rest":
		anim.play("Idle")
