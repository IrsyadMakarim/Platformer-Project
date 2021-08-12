extends KinematicBody2D

var active = false
export var dialogNew = preload("res://Scene/Dialog.tscn")
export var pathUI = "World/NPC/UI"

onready var question = get_node("Question")

func _process(delta):
	question.visible = active

func _input(event):
	if event.is_action_pressed("interact") and active:
		var dialog = dialogNew.instance()
		get_tree().get_root().get_node(pathUI).add_child(dialog)
		#get_tree().set_current_scene(dialog)

func _on_DetectPlayer_body_entered(body):
	if body.name == "Player":
		active = true

func _on_DetectPlayer_body_exited(body):
	if body.name == "Player":
		active = false
