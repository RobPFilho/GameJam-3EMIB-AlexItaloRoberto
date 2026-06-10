extends Area2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var die: AnimationPlayer = $"../die"
var dying = false


func _on_body_entered(body: Node2D) -> void:
	if body != player:
		return
	if player.morto:
		return
	if dying:
		return
	player.velocity.y = -500
	die.play('die')
	dying = true
