extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -550.0
const cena_porta = preload("res://scenes/porta.tscn")

@onready var jump: AudioStreamPlayer2D = $jump
@onready var die: AudioStreamPlayer2D = $die
@onready var step: AudioStreamPlayer2D = $step
@onready var vinheta: ColorRect = $CanvasLayer/Control/ColorRect
@onready var nivel_passado = get_tree().get_first_node_in_group("past")
@onready var nivel_presente = get_tree().get_first_node_in_group("present")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var timeline_cooldown := 0.0
var estava_no_chao := false
var passo_timer := 0.0
var no_passado = false
var morto = false
var pode_porta = true

func esta_dentro_de_parede() -> bool:
	var collision_shape = $CollisionShape2D

	if collision_shape == null:
		return false

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = collision_shape.global_transform
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query)

	for result in results:
		if result.collider != self:
			return true

	return false

func morrer():
	if morto:
		return
	morto = true
	die.play()
	var porta = get_tree().get_nodes_in_group("portas")
	if porta:
		for p in porta:
			p.delete()
		no_passado = false

	if no_passado:
		alternar_linha_do_tempo()
	Engine.time_scale = 0.5
	$AnimationPlayer.play("die")

func spawnar_porta():
	if !pode_porta:
		return
	if morto:
		return
	var porta = get_tree().get_nodes_in_group('portas')

	if !porta:
		$spawn.stop()
		$spawn.play()
		var instancia = cena_porta.instantiate()
		get_tree().root.add_child(instancia)
		instancia.global_position.x = global_position.x
		instancia.global_position.y = global_position.y-18
	else:
		for p in porta:
			p.delete()
		$spawn.stop()
		$spawn.play()
		var instancia = cena_porta.instantiate()
		get_tree().root.add_child(instancia)
		instancia.global_position.x = global_position.x
		instancia.global_position.y = global_position.y-18

func _process(delta: float) -> void:
	if morto:
		return
	if Input.is_action_just_pressed("portal"):
		spawnar_porta()
	
	var portaarray = get_tree().get_nodes_in_group("portas")
	if portaarray:
		if !pode_porta:
			for p in portaarray:
				p.delete()
	
	var porta = get_tree().get_first_node_in_group("portas")
	var alvo_opacidade := 0.0
	if porta:
		var distancia = global_position.distance_to(porta.global_position)
		var raio = 300.0

		var intensidade = pow(
			1.0 - clamp(distancia / raio, 0.0, 1.0),
			2.0
		)

		alvo_opacidade = intensidade * 0.8

	var opacidade_atual = vinheta.material.get_shader_parameter("opacity")

	opacidade_atual = lerp(
		opacidade_atual,
		alvo_opacidade,
		delta * 5.0
	)

	vinheta.material.set_shader_parameter(
		"opacity",
		opacidade_atual
	)
	if Input.is_action_just_pressed("clear"):
		var portas = get_tree().get_nodes_in_group("portas")
		for p in portas:
			p.delete()

func processar_no_linha_do_tempo(node: Node, ativo: bool):
	if morto:
		return
	if node.is_in_group("bg"):
		return

	node.process_mode = (
		Node.PROCESS_MODE_INHERIT
		if ativo
		else Node.PROCESS_MODE_DISABLED
	)

	if node is TileMapLayer:
		node.collision_enabled = ativo

	for child in node.get_children():
		processar_no_linha_do_tempo(child, ativo)

func alternar_linha_do_tempo():
	if morto:
		return

	no_passado = !no_passado

	if no_passado:
		$CanvasLayer/Control/Meter/NeedleAnim.play("passado")
	else:
		$CanvasLayer/Control/Meter/NeedleAnim.play("presente")

	nivel_passado.visible = no_passado
	nivel_presente.visible = !no_passado

	processar_no_linha_do_tempo(nivel_passado, no_passado)
	processar_no_linha_do_tempo(nivel_presente, !no_passado)
	empurrar_inimigos()
	await get_tree().physics_frame
	await get_tree().physics_frame

	if esta_dentro_de_parede():
		no_passado = !no_passado

		nivel_passado.visible = no_passado
		nivel_presente.visible = !no_passado

		processar_no_linha_do_tempo(nivel_passado, no_passado)
		processar_no_linha_do_tempo(nivel_presente, !no_passado)
		var porta = get_tree().get_nodes_in_group('portas')
		if porta:
			for p in porta:
				p.delete()
		$CanvasLayer/Control/Meter/NeedleAnim.play(
			"passado" if no_passado else "presente"
		)

func empurrar_inimigos():
	for inimigo in get_tree().get_nodes_in_group("enemy"):
		if inimigo.process_mode == Node.PROCESS_MODE_DISABLED:
			continue

		if global_position.distance_to(inimigo.global_position) < 48:
			var direcao = (inimigo.global_position - global_position).normalized()

			if direcao == Vector2.ZERO:
				direcao = Vector2.RIGHT

			inimigo.global_position += direcao * 64

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		if morto:
			return

	if is_on_floor() and !estava_no_chao:
		step.play()

	estava_no_chao = is_on_floor()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump.play()
		velocity.y = JUMP_VELOCITY

	var direcao := Input.get_axis("left", "right")

	if direcao:
		velocity.x = direcao * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direcao > 0:
		animated_sprite_2d.flip_h = false
	elif direcao < 0:
		animated_sprite_2d.flip_h = true

	if is_on_floor():
		if direcao == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("jump")
	
	if is_on_floor() and abs(velocity.x) > 10:
		passo_timer -= delta
		if passo_timer <= 0:
			step.play()
			passo_timer = 0.3
	else:
		passo_timer = 0.0
	
	move_and_slide()

func pauseGame():
	$CanvasLayer/Control/Pause.hide()
	$CanvasLayer/PauseMenu.show()
	get_tree().paused = true

func unpauseGame():
	$CanvasLayer/Control/Pause.show()
	$CanvasLayer/PauseMenu.hide()
	get_tree().paused = false

func interactPrompt(show: bool):
	if show:
		$ELabel.show()
	else:
		$ELabel.hide()

func dialog(Text: String):
	$CanvasLayer/Control/DialogText.showText(Text)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'die':
		Engine.time_scale = 1
		get_tree().reload_current_scene()


func _on_resume_button_up() -> void:
	$click.play()
	unpauseGame()

func _on_quit_button_up() -> void:
	$click.play()
	await $click.finished
	unpauseGame()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_pause_button_up() -> void:
	$click.play()
	pauseGame()


func _on_pause_mouse_entered() -> void:
	$hover.play()


func _on_pause_mouse_exited() -> void:
	$hover.play()


func _on_resume_mouse_exited() -> void:
	$hover.play()


func _on_resume_mouse_entered() -> void:
	$hover.play()


func _on_quit_mouse_exited() -> void:
	$hover.play()


func _on_quit_mouse_entered() -> void:
	$hover.play()
