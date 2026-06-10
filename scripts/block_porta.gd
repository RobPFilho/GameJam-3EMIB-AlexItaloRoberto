extends Area2D
@onready var player = get_tree().get_first_node_in_group('player')


func _on_body_entered(body: Node2D) -> void:
	if body != player:
		return
	$"../TileMapLayer".set_cell(
	Vector2i(67, 0),
	0,
	Vector2i(9, 0),
	0
	)
	player.pode_porta = false
	queue_free()


func _on_trigger_final_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
