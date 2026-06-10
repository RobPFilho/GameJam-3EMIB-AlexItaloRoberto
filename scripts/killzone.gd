extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	await get_tree().physics_frame
	await get_tree().physics_frame

	if not is_instance_valid(body):
		return

	if not overlaps_body(body):
		return

	if body.has_method("morrer"):
		if "esta_invuln" in body and body.esta_invuln:
			_retry_kill(body)
			return

		$"../Diezone".queue_free()
		body.morrer()


func _retry_kill(body):
	await get_tree().create_timer(0.1).timeout
	
	if not is_instance_valid(body):
		return
	
	if not overlaps_body(body):
		return
	
	if "esta_invuln" in body and body.esta_invuln:
		_retry_kill(body)
		return

	$"../Diezone".queue_free()
	body.morrer()
