extends Area2D
@onready var player = get_tree().get_first_node_in_group('player')
@onready var trigger2 = get_tree().get_first_node_in_group('trigger_tutorial2')

func _on_body_entered(body: Node2D) -> void:
	if body != player:
		return
	trigger2.queue_free()
	self.queue_free()
