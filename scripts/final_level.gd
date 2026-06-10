extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
var player_dentro = false
@onready var nivel_atual = get_tree().current_scene.scene_file_path

func _ready() -> void:
	pass

func nxt_lvl():
	var nivel_index = levels.levels.find(nivel_atual)

	if nivel_index == -1:
		push_error("Nível atual não encontrado em levels.levels: " + nivel_atual)
		return

	if nivel_index >= levels.levels.size() - 1:
		print("Sem nível atual")
		return

	var proximo_nivel =levels.levels[nivel_index + 1]
	if player.no_passado:
		player.alternar_linha_do_tempo()
	get_tree().change_scene_to_file(proximo_nivel)

func _process(delta: float) -> void:
	if player.morto:
		return

	if player_dentro and Input.is_action_just_pressed("interact"):
		if $AnimationPlayer.is_playing():
			if $AnimationPlayer.current_animation == 'transition':
				return
			$AnimationPlayer.play("transition")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != player:
		return

	$Area2D/Label.show()
	player_dentro = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body != player:
		return

	$Area2D/Label.hide()
	player_dentro = false
