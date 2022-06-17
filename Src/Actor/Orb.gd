extends KinematicBody2D

var span_time = 15
var velocity
var speed
var type

func _physics_process(delta):
	global_rotation -= 0.05
	span_time -= delta
	if span_time <= 0:
		queue_free()
	var _err = move_and_collide(velocity * delta * speed)

func _on_body_entered(body):
	body.take_damage(type)
	queue_free()
