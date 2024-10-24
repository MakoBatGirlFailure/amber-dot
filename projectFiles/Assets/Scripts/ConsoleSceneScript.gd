extends CanvasLayer

#node components
@onready var output = get_node("Control/RichTextLabel")
@onready var input = get_node("Control/LineEdit")
@onready var btn_exec = get_node("Control/Button")

var history = []
var hist_index = -1

#default string 
var intro_string = "Welcome to the AmberInstinct v0.0.0td Console"

# Called when the node enters the scene tree for the first time.
func _ready():
	output.text += "[color=green]" + intro_string + "[/color]"
	pass # Replace with function body.

func _toggle_visibility():
	self.visible = !self.visible

func _input(event):
	if history.size() > 0 and event.is_action_pressed("ui_down"):
		hist_index -= 1 
		if hist_index < 0:
			hist_index = history.size() - 1 
		hist_index = hist_index % history.size()
		input.text = history[hist_index]

	if history.size() > 0 and event.is_action_pressed("ui_up"):
		hist_index += 1 
		hist_index = hist_index % history.size()
		input.text = history[hist_index]

	if event.is_action_pressed("console_enter_btn") and input.text != "":
		execute_command()

func execute_command():
	history.push_back(input.text)
	if history.size() >= 20:
		history.pop_front()
	output.text += "\n"+ (await CommandParser._execute_string(input.text))
	input.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_button_pressed():
	execute_command()
	pass # Replace with function body.
