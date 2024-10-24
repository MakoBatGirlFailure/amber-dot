extends CharacterBody2D
class_name EnemyBase

#Default engine gravity
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#class members 
var _state_mchn = StateMachine.new()
var _anim_spr: AnimatedSprite2D
var _velocity: Vector2

#animation control class member 
var anim = ""
var new_anim = ""

#transition arests 
const IDLE_TRANS = '1'
const WALKING_TRANS = '2'
const ATTACK_TRANS = '3'

#states constants
const IDLE = 'idle'
const WALKING = 'walking'
const ATTACK = 'attack'

# Internal player's signal emitter 
signal changed_state 

#get the player's position, the values is:
#False if the obj1 is on the left to the obj2 
#True if the obj1 is on the right to the obj2
func _get_object_vertical_orientation(obj1_pos: Vector2, obj2_pos: Vector2) -> bool:
	return (obj1_pos.x > obj2_pos.x) 

#the same logic goes to the vertical orientation (prolly won't use it anyway but who cares)
func _get_object_horizontal_orientation(obj1_pos: Vector2, obj2_pos: Vector2) -> bool:
	return (obj1_pos.y > obj2_pos.y) 



#prepare the graph of transitions
func _loading_base_states():
	_state_mchn._add_state(IDLE, [IDLE_TRANS])
	_state_mchn._add_state(WALKING, [WALKING_TRANS])
	_state_mchn._add_state(ATTACK, [ATTACK_TRANS])


#set the AnimatedSprite2D child node 
func _set_anim_spr_node(node_path: String) -> void:
	#print(get_node(node_path))
	_anim_spr = get_node(node_path)

func get_anim_spr_node() -> AnimatedSprite2D:
	return _anim_spr

func set_enemy_velocity(x: float, y: float) -> void:
	_velocity.x = x 
	_velocity.y = y
	pass

func get_enemy_velocity() -> Vector2:
	return self._velocity

func draw_distance_point(from: Vector2, to: Vector2):
	print("from: ", from)
	print("to: ", to)
	draw_line(from, to, Color(1,0,0))
	pass

func sprite_flip_h(value: bool):
	_anim_spr.flip_h = value 
	pass

func get_sprite_flip_h():
	return _anim_spr.flip_h

#must be placed on _ready() function
func _ready_overrides(animated_spr_path: String) -> void:
	_set_anim_spr_node(animated_spr_path)
	_loading_base_states()
	set_enemy_velocity(0,0)

#ready function that calls _loading_base_states()
func _ready():

	pass

