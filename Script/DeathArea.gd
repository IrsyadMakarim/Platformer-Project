extends Area2D

func _on_DeathArea_body_entered(body):
	if body.name == "Player":
		get_tree().reload_current_scene()
	
func _on_DeathArea2_body_entered(body):
	if body.name == "Player":
		get_tree().reload_current_scene()

func _on_DeathArea3_body_entered(body):
	if body.name == "Player":
		get_tree().reload_current_scene()

func _on_DeathArea4_body_entered(body):
	if body.name == "Player":
		get_tree().reload_current_scene()

func _on_DeathArea5_body_entered(body):
	if body.name == "Player":
		get_tree().reload_current_scene()
