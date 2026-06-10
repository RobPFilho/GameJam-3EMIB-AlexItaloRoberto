extends Area2D
@onready var player = get_tree().get_first_node_in_group("player")
var player_dentro = false

func _process(delta: float) -> void:
	$Label.visible = player_dentro

func _on_body_entered(body: Node2D) -> void:
	if body != player:
		return
	player_dentro = true


func _on_body_exited(body: Node2D) -> void:
	if body != player:
		return
	player_dentro = false
