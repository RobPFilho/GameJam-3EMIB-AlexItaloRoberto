extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("morrer"):
		# delay pq o alex é mt burro e morre mt
		await get_tree().physics_frame
		await get_tree().physics_frame
		$"../Diezone".queue_free()
		body.morrer()
