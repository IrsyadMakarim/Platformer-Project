extends Area2D

onready var player = get_node("/root/World/Player")

func _on_Rope_body_entered(body):
	if body.name == "Player":
		player.ladder_on = true

func _on_Rope_body_exited(body):
	if body.name == "Player":
		player.ladder_on = false
