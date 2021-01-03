extends ProgressBar

func _ready():
	Global.connect("fly_time", self, "update_fly")
	value = Global.fly_time

func update_fly():
	value = Global.fly_time
