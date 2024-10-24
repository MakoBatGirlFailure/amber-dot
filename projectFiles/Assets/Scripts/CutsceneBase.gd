extends Node2D
#Cutscene manager 

var actors: Dictionary
var cameras: Dictionary
var pre_dialog_scene = preload("res://Assets/Scenes/UI/DialogScene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	CommandParser.active_cutscene = self
	var actors_array = _actor_object_list()
	var cameras_array = _camera_object_list()
	_get_camera_bank(cameras_array)
	_get_actors_bank(actors_array)
	
	await CommandParser._execute_string("console_script Test/test")
	#await _instantiate_dialog_scene('res://Assets/Scripts/DialogueDB/dialogueTest.txt')
	pass # Replace with function body.

func _instantiate_dialog_scene(dialog_data_path: String) -> void:
	var dialog_scene = pre_dialog_scene.instantiate()
	var dialog_data = GlobalScript.load_dialogue_from_file(dialog_data_path)
	print(dialog_data_path)
	print(dialog_data)
	dialog_scene.dialogue_data = dialog_data 
	add_child(dialog_scene)
	await dialog_scene.dialogue_ended
	dialog_scene.queue_free()
	pass

#CAMERA LISTING

func _camera_object_list() -> Array:
	var list_camera = []
	var children_node = get_children()
	for child in children_node: 
		if child is CSCamera:
			list_camera.append(child)
	
	return list_camera

func _get_camera_bank(camera_array) -> void:
	for camera in camera_array:
		_camera_add(camera)


func _camera_add(camera_obj: CSCamera) -> void: 
	var camera_id = camera_obj._camera_id 
	cameras[camera_id] = camera_obj
	pass

#ACTOR LISTING 

func _actor_object_list() -> Array:
	var list_actors = []
	var children_node = get_children()
	for child in children_node: 
		if child is CutsceneNPCBase:
			list_actors.append(child)
	
	return list_actors


func _get_actors_bank(actors_array) -> void:
	for actor in actors_array:
		_actor_add(actor)


func _actor_add(actor_obj: CutsceneNPCBase) -> void: 
	var actor_id = actor_obj.actor_id 
	print(actor_id)
	actors[actor_id] = actor_obj
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

#ACTOR ACTIONS PRIMITIVES

func move_actor(actor_id: String, distance: float) -> void:
	var actor_obj = actors[actor_id]
	print(actor_obj)
	actor_obj.dest_steps = distance 
	actor_obj.walked_steps = 0 
	actor_obj.state_mchn.current_state = actor_obj.WALK_TO
	actor_obj.state_mchn.new_state = actor_obj.WALK_TO
	
	#actor_obj.state_mchn._transition(actor_obj.TRANSITION_WALK)
	await actor_obj.action_ended
	pass

func change_actor_animation(actor_id: String, anim_name: String) -> void:
	var actor_obj = actors[actor_id]
	actor_obj._change_animation(anim_name)
	pass


func flip_actor_animation(actor_id: String, _state: bool) -> void:
	var actor_obj = actors[actor_id]
	actor_obj._flip(_state)
	pass

func wait_actor(actor_id: String, time_s: float) -> void:
	var actor_obj = actors[actor_id]
	await actor_obj._wait(time_s)
	pass


#CAMERA ACTIONS PRIMITIVES
func move_camera(camera_id: String, speed: float, destination: Vector2) -> void:
	var camera_obj = cameras[camera_id]
	camera_obj._destination_point = destination
	camera_obj._cam_velocity = speed

	camera_obj._state_mchn.current_state = camera_obj.MOVING_CAMERA
	camera_obj._state_mchn.new_state = camera_obj.MOVING_CAMERA
	await camera_obj.action_ended


func shake_camera(camera_id: String, shake_intensity: float, shake_duration: float):
	var camera_obj = cameras[camera_id]
	camera_obj.shake_intensity = shake_intensity
	camera_obj.shake_duration = shake_duration


	#camera_obj._state_mchn.current_state = camera_obj.SHAKING_CAMERA
	camera_obj._state_mchn.new_state = camera_obj.SHAKING_CAMERA
	
	await camera_obj.action_ended


#action primitives 
func move_actors(actors_id: Array, distance: float) -> void:
	pass 

func _on_action_ended():
	print("action ended")

