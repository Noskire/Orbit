extends Sprite

onready var tween: Tween = get_node("Tween")
var value
var type

func _on_timeout():
	var player = get_parent().get_node("Mage")
	var _err = tween.interpolate_property(self, "position", position, player.position, 1.7, Tween.TRANS_SINE, Tween.EASE_IN)
	_err = tween.start()
	yield(tween, "tween_all_completed")
	get_parent().get_node("Gems").get_orb(value, type)
	queue_free()
