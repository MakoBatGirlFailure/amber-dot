extends CanvasLayer

#node built in instances 
var output: RichTextLabel
var timer: Timer

#page control
var page_number = 0 

#text structure (placeholder)
var pages_data = [
]

var dialogue_data = {
	"pages" : pages_data 
}

signal dialogue_ended 

func _render_text(page_data):	
	var chara_color = page_data["chara_color"]
	var page_text = page_data["text"]
	var text = ""

	print(dialogue_data)
	if chara_color != "null":
		text = "[color="+chara_color+"]"+page_text+"[/color]"
	
	return text

# Called when the node enters the scene tree for the first time.
func _ready():
	#letting the globalScript know 
	connect("dialogue_ended", Callable(GlobalScript, "_on_dialogue_ended"))

	pages_data = dialogue_data['pages']

	output = get_node("RichTextLabel")
	timer = get_node("Timer")
	timer.start()
	
	#render text 

	output.text = _render_text(dialogue_data["pages"][page_number])
	output.visible_characters = 0 

	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("slashing"):
		if page_number < pages_data.size():
			if is_visible_characters_shown():
				#reset the dialogue box 
				page_number += 1
				if page_number >= pages_data.size():
					page_number -= 1 
					emit_signal("dialogue_ended")
				else: 
					output.visible_characters = 0 
					output.text = _render_text(pages_data[page_number])
			else: 
				output.visible_characters = pages_data[page_number]['text'].length()
	pass

func is_visible_characters_shown():
	return not(output.visible_characters < pages_data[page_number]['text'].length())

func _on_timer_timeout():
	if not is_visible_characters_shown():
		output.visible_characters += 1
	#print("timeout")
	pass # Replace with function body.
