extends Node

var player_node = null 
var active_console = false 
var player_control = PlayerBehaviourControl.new()

func _ready():
	player_control.set_character_id('Ritsuko')
	player_control.set_max_btl_stats_values(100, 100)
	player_control.set_btl_stats_values(100, 100)

	self.process_mode = self.PROCESS_MODE_ALWAYS

#player control methods 
func get_player_stat(value: String):
	match value:
		'hit_points':
			return player_control.get_hit_points()
		'max_hit_points':
			return player_control.get_max_hit_points()
		'armor_points':
			return player_control.get_armor_points()
		'max_armor_points':
			return player_control.get_max_armor_points()

func set_player_stat(value: String, attr_value):
	match value:
		'hit_points':
			player_control.set_hit_points(attr_value)
		'max_hit_points':
			player_control.set_max_hit_points(attr_value)
		'armor_points':
			player_control.set_armor_points(attr_value)
		'max_armor_points':
			player_control.set_max_armor_points(attr_value)

#similar to the set but this time you'll sum or subtract the value	
func change_player_stat(value: String, attr_sum):
	match value:
		'hit_points':
			player_control.set_hit_points(player_control.get_hit_points() + attr_sum)
		'max_hit_points':
			player_control.set_max_hit_points(player_control.get_max_hit_points() + attr_sum)
		'armor_points':
			player_control.set_armor_points(player_control.get_armor_points() + attr_sum)
		'max_armor_points':
			player_control.set_max_armor_points(player_control.get_max_armor_points() + attr_sum)

func _input(event):
	if event.is_action_pressed("console_toggle"):
		if !active_console:
			Console._toggle_visibility()
			active_console = true 
		else:
			print("resume")
			Console._toggle_visibility()
			active_console = false 
		pass
	pass

func _pause_game():
	Engine.time_scale = 0
	get_tree().paused = true 

func _resume_game():
	Engine.time_scale = 1
	get_tree().paused = false 

func player_position() -> Vector2:
	return player_node.get_player_position()

func load_dialogue_from_file(file_path: String) -> Dictionary:
	var dialogue_data = {"pages": []}
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line != "":
				var page_data = parse_dialogue_line(line)
				dialogue_data["pages"].append(page_data)
		file.close()
	
	return dialogue_data
	
	
func parse_dialogue_line(line: String) -> Dictionary:
	var page_data = {}
	var parts = line.split(";")
	
	for part in parts:
		var key_value = part.split(":")
		if key_value.size() == 2:
			var key = key_value[0].strip_edges()
			var value = key_value[1].strip_edges()
			page_data[key] = value
	
	return page_data

func _on_dialogue_ended():
	print("dialogue ended")
	pass
