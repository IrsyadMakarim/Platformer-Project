extends Area2D

func _on_DeathArea_body_entered(body):
	get_tree().reload_current_scene()
	
func _on_DeathArea2_body_entered(body):
	get_tree().reload_current_scene()
