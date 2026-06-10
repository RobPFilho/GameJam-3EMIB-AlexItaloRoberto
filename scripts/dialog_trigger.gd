extends Node2D
@onready var player = get_tree().get_first_node_in_group("player")
var player_dentro = false
@export var text = ''
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_dentro:
		if Input.is_action_just_pressed("dialog"):
			player.dialog(text)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != player:
		return
	player.interactPrompt(true)
	player_dentro = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body != player:
		return
	player.interactPrompt(false)
	player_dentro = false
