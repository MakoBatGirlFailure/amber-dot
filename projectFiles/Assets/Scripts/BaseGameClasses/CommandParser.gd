extends Node 

#Each command must execute a function
#active cutscene scene address 
const SCENE_SCRIPTS = 'res://Assets/Scripts/BaseGameClasses/SceneScripts/'
const CONSOLE_SCRIPTS = 'res://Assets/Scripts/BaseGameClasses/ConsoleScripts/'
const DIALOGUE_DB = 'res://Assets/Scripts/DialogueDB/'

var active_cutscene = null
var active_hscene = null 

var command_library = {
	"ping" : Callable(self, "pong"),
	"console_script" : Callable(self, "run_script"),
	#CUTSCENE STUFF 
	
	"cs_move_actor" : Callable(self, "cs_move_actor"),
	"cs_dialog" : Callable(self, 'cs_dialog'),
	"cs_anim_change" : Callable(self, 'cs_anim_change'),
	"cs_anim_flip" : Callable(self, 'cs_anim_flip'),
	"cs_actor_wait" : Callable(self, 'cs_actor_wait'),
	"cs_camera_move" : Callable(self, 'cs_camera_move'),
	"cs_camera_shake" : Callable(self, 'cs_camera_shake'),
	
	#HCG STUFF
	"hcg_dialog" : Callable(self, 'hcg_dialog'),
	"hcg_visibility" : Callable(self, 'hcg_visibility'),
	"hcg_change_frame" : Callable(self, 'hcg_change_frame'),
	"hcg_change_variation" : Callable(self, 'hcg_change_variation'),
	"hcg_loop" : Callable(self, 'hcg_loop'),
	"hcg_wait_to" : Callable(self, 'hcg_wait_to'),
	"hcg_lewd_flash_fade_in" : Callable(self, 'hcg_lewd_flash_fade_in'),
	"hcg_lewd_flash_fade_out" : Callable(self, 'hcg_lewd_flash_fade_out'),
	"hcg_flash_fade_in" : Callable(self, 'hcg_flash_fade_in'),
	"hcg_flash_fade_out" : Callable(self, 'hcg_flash_fade_out'),
	"hcg_start_shaking" : Callable(self, 'hcg_start_shaking')
}


#return a dictionary that enumerates the command name, and its args 
func _get_command_args(command: String) -> Dictionary:
	var splited_string = command.split(" ")
	var command_name = splited_string[0]
	splited_string.remove_at(0)
	var args = splited_string
	return {"command_name": command_name, "args": args}

func _execute_string(command: String) -> String:
	var parsed_cmd = _get_command_args(command)
	var cmd_name = parsed_cmd['command_name']
	var args = parsed_cmd['args']
	if command_library.has(cmd_name):
		return await command_library[cmd_name].call(args)
	return "[color=red] Error! Unknown command with name: "+cmd_name+" found.[/color]"

#A simple command to test the execution
func pong(args: Array) -> String:
	print("pong", args)
	return "pong, args: " + str(args)

func run_script(_args: Array) -> String:
	if _args.size() < 1:
		return '[color=red]Invalid command[/color]'

	return await read_script_file(CONSOLE_SCRIPTS+str(_args[0])+'.txt')
	
# cs_move_actor <actor_id> <distance> 
func cs_move_actor(_args: Array) -> String:
	if active_cutscene != null:
		if _args.size() < 2:
			return "[color=red]Not enought arguments, expected 2 but it had "+ str(_args.size()) + " arguments[/color]"
		if float(_args[1]) is float:
			await active_cutscene.move_actor(_args[0], float(_args[1]))
			return "succefully moved character"
		return "[color=red]invalid input[/color]"
	
	return "[color=red]There's no active cutscene running"
	

func cs_anim_change(_args: Array) -> String:
	if active_cutscene != null:
		if _args.size() < 2:
			return "[color=red]Not enought arguments, expected 2 but it had "+ str(_args.size()) + " arguments[/color]"
		await active_cutscene.change_actor_animation(_args[0], _args[1])
		return "succefully changed animation"
		
	return "[color=red]There's no active cutscene running"


func cs_anim_flip(_args: Array) -> String:
	var flip_h: bool
	if active_cutscene != null:
		if _args.size() < 2:
			return "[color=red]Not enought arguments, expected 2 but it had "+ str(_args.size()) + " arguments[/color]"
		if _args[1] == '1':
			flip_h = true 
		else: 
			flip_h = false 
		await active_cutscene.flip_actor_animation(_args[0], flip_h)
		return "succefully fliped animation"
		
	return "[color=red]There's no active cutscene running"


func cs_actor_wait(_args: Array) -> String:
	if active_cutscene != null:
		if _args.size() < 2:
			return "[color=red]Not enought arguments, expected 2 but it had "+ str(_args.size()) + " arguments[/color]"
		await active_cutscene.wait_actor(_args[0], float(_args[1]))
		return "done waiting"
		
	return "[color=red]There's no active cutscene running"
	

#cs_dialog <dialog_script_path>
func cs_dialog(_args: Array) -> String:
	if active_cutscene != null:
		if _args.size() < 1:
			return "[color=red]Not enought arguments, expected 1 but it had "+ str(_args.size()) + " arguments[/color]"
		await active_cutscene._instantiate_dialog_scene(DIALOGUE_DB + _args[0] + '.txt')
		return "dialog runned"
	return "[color=red]There's no active cutscene running"

func cs_camera_move(_args: Array) -> String:
	if active_cutscene != null:
		if _args.size() < 4:
			return "[color=red]Not enough arguments, expected 3 but it had "+ str(_args.size()) + " arguments[/color]"
		var dest_position = Vector2(float(_args[2]), float(_args[3]))
		await active_cutscene.move_camera(_args[0], float(_args[1]), dest_position)
		return "Camera moved succefully"
	return "[color=red]There's no active cutscene running"

func cs_camera_shake(_args: Array) -> String:
	if active_cutscene != null:
		if _args.size() < 3:
			return "[color=red]Not enough arguments, expected 1 but it had "+ str(_args.size()) + " arguments[/color]"
		await active_cutscene.shake_camera(_args[0], float(_args[1]), float(_args[2]))
		return "Camera shaked"
	return "[color=red]There's no active cutscene running"	

#--------------------------------
#HCG STUFF 
func hcg_visibility(_args:Array) -> String:
	var boolean_value = false 
	if active_hscene != null:
		if _args.size() < 1:
			return "[color=red]Not enough arguments, expected 1 but it had "+ str(_args.size()) + " arguments[/color]"
		if _args[0] == '1':
			boolean_value = true 
		active_hscene.hcg_visibility(boolean_value)
		return 'sucefully changed the visibility'
	return "[color=red]There's no active hscene running"

func hcg_change_frame(_args:Array) -> String:
	if active_hscene != null:
		if _args.size() < 1:
			return "[color=red]Not enough arguments, expected 1 but it had "+ str(_args.size()) + " arguments[/color]"
		active_hscene.hcg_change_frame(int(_args[0]))
		return 'sucefully changed frame'
	return "[color=red]There's no active hscene running"

func hcg_change_variation(_args:Array) -> String:
	if active_hscene != null:
		if _args.size() < 1:
			return "[color=red]Not enough arguments, expected 3 but it had "+ str(_args.size()) + " arguments[/color]"
		active_hscene.hcg_change_variation(_args[0])
		return 'sucefully changed the hcg variation'
	return "[color=red]There's no active hscene running"

func hcg_loop(_args:Array) -> String:
	if active_hscene != null:
		if _args.size() < 1:
			return "[color=red]Not enough arguments, expected 1 but it had "+ str(_args.size()) + " arguments[/color]"
		active_hscene.hcg_loop(_args[0])
		return 'set the hcg loop'
	return "[color=red]There's no active hscene running"

func hcg_wait_to(_args:Array) -> String:
	if active_hscene != null:
		if _args.size() < 1:
			return "[color=red]Not enough arguments, expected 1 but it had "+ str(_args.size()) + " arguments[/color]"
		await active_hscene.wait_to(float(_args[0]))
		return 'Sucefully waited to'
	return "[color=red]There's no active hscene running"

func hcg_lewd_flash_fade_in(_args:Array) -> String:
	if active_hscene != null:
		await active_hscene.lewd_flash_fade_in()
		return 'hcg flash fade in'
	return "[color=red]There's no active hscene running"

func hcg_lewd_flash_fade_out(_args:Array) -> String:
	if active_hscene != null:
		await active_hscene.lewd_flash_fade_out()
		return 'hcg flash fade out'
	return "[color=red]There's no active hscene running"

func hcg_flash_fade_out(_args:Array) -> String:
	if active_hscene != null:
		await active_hscene.flash_fade_out()
		return 'flash fade out'
	return "[color=red]There's no active hscene running"

func hcg_flash_fade_in(_args:Array) -> String:
	if active_hscene != null:
		await active_hscene.flash_fade_in()
		return 'flash fade in'
	return "[color=red]There's no active hscene running"

func hcg_dialog(_args: Array) -> String:
	if active_hscene != null:
		if _args.size() < 1:
			return "[color=red]Not enought arguments, expected 1 but it had "+ str(_args.size()) + " arguments[/color]"
		await active_hscene._instantiate_dialog_scene(DIALOGUE_DB + _args[0] + '.txt')
		return "dialog runned"
	return "[color=red]There's no active cutscene running"


func hcg_start_shaking(_args:Array) -> String:
	if active_hscene != null:
		if _args.size() < 2:
			return "[color=red]Not enough arguments, expected 2 but it had "+ str(_args.size()) + " arguments[/color]"
		await active_hscene.start_shaking(float(_args[0]), float(_args[1]))
		return 'screen shaking'
	return "[color=red]There's no active hscene running"



#load script 
func read_script_file(file_path: String) -> String:
	var result = ''
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file == null:
		return "Error opening file: " + file_path
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line != "":
			result += await _execute_string(line) + '\n'
			print(result)
	
	file.close()
	return result


