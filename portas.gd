extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player_dentro = false

func delete():
	$clear.play()
	animation_player.play("clear")

func _ready() -> void:
	animation_player.play("swirl")

func _process(delta: float) -> void:
	pass


	if player_dentro:
		if Input.is_action_just_pressed("interact"):
			$woosh.play()
			player.alternar_linha_do_tempo()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != player:
		return
	
	$Label.show()
	animated_sprite_2d.play("move")
	$creak1.play()
	player_dentro = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body != player:
		return

	$Label.hide()
	animated_sprite_2d.play_backwards("move")
	$creak2.play()
	player_dentro = false
