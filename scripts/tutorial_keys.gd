extends Node2D
@onready var player = get_tree().get_first_node_in_group('player')
@onready var dialogo = get_tree().get_first_node_in_group('trigger_tutorial1')
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != player:
		return
	if player.no_passado:
		return
	$AnimationPlayer.play('popup')
	$Area2D.queue_free()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if $Q.modulate.a > 0:
		$AnimationPlayer.play_backwards('popup')
		$Area2D2.queue_free()
	dialogo.queue_free()
