class_name EnemyStateActions

var _state_mchn: StateMachine
var _enemy_obj: EnemyBase
var _update_functions = EnemyStateFunctions.new(self)
var _state_funcs = {
	'patroling' : Callable(_update_functions, 'patroling'),
	'pursuing' : Callable(_update_functions, 'pursuing'),
	'attack' : Callable(_update_functions, 'attack'),
	'change_patrol_direction' : Callable(_update_functions, 'change_patrol_direction'),
	'waiting' : Callable(_update_functions, 'waiting')
}


#state machine labels
const MELLEE_PATROLING = 'patroling'
const MELEE_WAITING = 'waiting' 
const CHANGING_PATROLING_DIRECTION = 'change_patrol_direction'
const MELLEE_PURSUING = 'pursuing'
const MELLEE_ATTACK = 'attack'

#state machine edges:
const TRANS_MELEE_PATROLLING = '0'
const TRANS_MELEE_CHANGING_DIR = '0.1'
const TRANS_MELEE_WAITING = '0.1.5'
const TRANS_RETURNING_PATROL = '0.2'
const TRANS_MELEE_PURSUING = '1'
const TRANS_MELEE_ATTACK = '2'

func _init(state_mchn: StateMachine, enemy_obj: EnemyBase):
	self._state_mchn = state_mchn
	self._enemy_obj = enemy_obj

func get_enemy():
	return self._enemy_obj


func _enemy_physics_update(_delta):
	#get the current state machine 
	var state = _state_mchn._get_current_state()
	if get_enemy().anim != get_enemy().new_anim:
		get_enemy().anim = get_enemy().new_anim

	
	get_enemy().get_anim_spr_node().play(get_enemy().anim)

	_state_mchn._update_state()
	#debug stuff, it wouldn't be bothered with		
		
	if not get_enemy().is_on_floor():
		get_enemy().velocity.y += get_enemy().gravity * _delta

	
	self._state_funcs[state].call(_delta)
	#use match instead of if/else structure
	match state:
		"":
			pass
	
	get_enemy().move_and_slide()
	_update_functions.update(_delta)
	pass
