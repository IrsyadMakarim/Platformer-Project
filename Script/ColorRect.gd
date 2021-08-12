extends ColorRect

export (String) var dialogPath = "res://Dialog/Dialog.json"
export (float) var textSpeed = 0.05

var dialog
var phraseNum = 0
var finished = false

onready var timer = get_node("Timer")
onready var dialogName = get_node("Name")
onready var dialogues = get_node("Dialog")

func _ready():
	timer.wait_time = textSpeed
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			nextPhrase()
		else:
			dialogues.visible_characters = len(dialogues.text)

func getDialog() -> Array:
	
	var f = File.new()
	assert(f.file_exists(dialogPath), "File Path does not exist")
	
	f.open(dialogPath, File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return[]

func nextPhrase() -> void:
	
	if phraseNum >= len(dialog):
		queue_free()
		return
	
	finished = false
	
	dialogName.bbcode_text = dialog[phraseNum]["Name"]
	dialogues.bbcode_text = dialog[phraseNum]["Dialog"]
	
	dialogues.visible_characters = 0
	
	while dialogues.visible_characters < len(dialogues.text):
		dialogues.visible_characters += 2
		
		timer.start()
		yield(timer, "timeout")
	
	finished = true
	phraseNum += 1
	return
