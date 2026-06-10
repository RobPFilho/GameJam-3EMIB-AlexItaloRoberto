extends Control

@onready var uh: AudioStreamPlayer2D = $RichTextLabel/Uh
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var animation_player: AnimationPlayer = $RichTextLabel/AnimationPlayer

var ultimo_caractere_visivel := 0

func _ready() -> void:
	pass

func showText(texto: String):
	rich_text_label.text = texto
	rich_text_label.visible_ratio = 0.0
	ultimo_caractere_visivel = 0
	animation_player.play("reveal")

func _process(delta: float) -> void:
	var total = rich_text_label.get_total_character_count()
	var atual = int(rich_text_label.visible_ratio * total)

	if atual > ultimo_caractere_visivel:
		uh.pitch_scale = randf_range(0.95, 1.05)
		uh.play()

	ultimo_caractere_visivel = atual

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "reveal":
		$RichTextLabel/Timer.start()

func _on_timer_timeout() -> void:
	animation_player.play("hide")
