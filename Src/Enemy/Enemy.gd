extends KinematicBody2D
class_name Enemy

onready var player: Node2D = get_parent().get_node("Mage")
onready var hp: ProgressBar = get_node("HP")
onready var ionfire: Sprite = get_node("ionfire")
onready var iwet: Sprite = get_node("iwet")
onready var islow: Sprite = get_node("islow")
onready var anim: AnimationPlayer = get_node("AnimationPlayer")
onready var projectile_path = preload("res://Src/Enemy/Projectile.tscn")
onready var exp_path = preload("res://Src/Enemy/ExpPoint.tscn")

enum types {Fire, Water, Earth, Air}
var speed
var type
var hitpoints
var exp_points
var damage

var on_fire = false
var wet = false
var slowed = false
var debuff = 0
var debuff_slow = 0

var enemy_pos = Vector2()
var target_pos = Vector2()
var direction = Vector2()

func _ready():
	add_to_group("Enemies")

func _physics_process(delta: float) -> void:
	if debuff > 0:
		debuff -= delta
	elif debuff < 0:
		debuff = 0
		on_fire = false
		wet = false
		ionfire.set_visible(false)
		iwet.set_visible(false)
	
	if debuff_slow > 0:
		debuff_slow -= delta
	elif debuff_slow < 0:
		debuff_slow = 0
		slowed = false
		islow.set_visible(false)
	
	enemy_pos = get_global_position()
	if is_instance_valid(player):
		target_pos = player.position - enemy_pos
		look_at(player.position)
	if abs(target_pos.x) > 150 or abs(target_pos.y) > 150:
		# Move towards player or tower?
		direction = target_pos.normalized()
		if slowed:
			direction = move_and_slide(direction * speed / 2)
		else:
			direction = move_and_slide(direction * speed)
	elif anim.current_animation == "Idle":
		if is_instance_valid(player):
			player.take_damage(damage)
			anim.play("Rest")

func take_damage(dam_type: int) -> void:
	if type == dam_type:
		hitpoints -= 1
	elif opposite_type(dam_type):
		hitpoints -= 4
	else:
		hitpoints -= 2
	
	if on_fire and dam_type == 1: #water
		hitpoints -= 1
	if wet and dam_type == 2: #earth
		hitpoints -= 1
	
	hp.value = hitpoints
	if hitpoints <= 0:
		die()

func opposite_type(dam_type) -> bool:
	#enum types {Fire, Water, Earth, Air}
	if (type == 0 and dam_type == 1) or (type == 1 and dam_type == 2) or (type == 2 and dam_type == 3) or (type == 3 and dam_type == 0):
		return true
	return false

func get_on_fire(time: int):
	if wet:
		wet = false
	on_fire = true
	debuff = time
	ionfire.set_visible(true)

func get_wet(time: int):
	if on_fire:
		on_fire = false
	wet = true
	debuff = time
	iwet.set_visible(true)

func get_slowed(time: int):
	slowed = true
	debuff_slow = time
	islow.set_visible(true)

func die() -> void:
	var exp_point = exp_path.instance()
	get_parent().add_child(exp_point)
	exp_point.position = global_position
	exp_point.value = exp_points
	exp_point.type = type
	exp_point.modulate = $Sprite.modulate
	queue_free()

func _on_animation_finished(anim_name):
	if anim_name == "Rest":
		anim.play("Idle")
