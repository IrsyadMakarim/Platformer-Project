extends ProgressBar

func _ready():
	value = Global.dashTime
	Global.connect("fly_time_reduce", self, "update_fly_reduce")
	Global.connect("fly_time_tambah", self, "update_fly_tambah")

func update_fly_reduce(amount):
	value -= Global.dashTime

func update_fly_tambah(amount):
	value += Global.dashTime
