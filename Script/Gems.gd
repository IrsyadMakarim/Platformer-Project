extends Area2D

onready var icon = get_node("GemSprite")
onready var player = get_node("/root/World/Player")
onready var animPlayer = get_node("AnimationPlayer")

var dist : int
var haveGem = false

func _ready():
	animPlayer.play("Float")

func _process(delta):
	
	dist = 35 * player.direction
	
	if haveGem:
		animPlayer.stop(true)
		icon.global_position = icon.global_position.linear_interpolate(player.global_position + Vector2(dist, 0), 0.1)

func _on_Gems_body_entered(body):
	
	if body.name == "Player":
		haveGem = true
