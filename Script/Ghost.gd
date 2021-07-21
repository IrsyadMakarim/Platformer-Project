extends Sprite

onready var alph_tween = get_node("Alpha_tween")

func _ready():
	alph_tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), 
	Color(1, 1, 1, 0), .6, Tween.TRANS_SINE, Tween.EASE_OUT)
	alph_tween.start()

func _on_Alpha_tween_tween_completed(object, key):
	queue_free()
