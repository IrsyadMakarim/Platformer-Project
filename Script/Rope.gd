extends Area2D

func _on_Rope_body_entered(body):
	if body.name == "Player":
		get_node("../../Player").ladder_on = true


func _on_Rope_body_exited(body):
	if body.name == "Player":
		get_node("../../Player").ladder_on = false
