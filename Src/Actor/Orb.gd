extends KinematicBody2D

var velocity
var speed
var span_time = 5

func _physics_process(delta):
	span_time -= delta
	if span_time <= 0:
		queue_free()
	var _err = move_and_collide(velocity * delta * speed)

func _on_body_entered(body):
	body.take_damage()
	queue_free()
