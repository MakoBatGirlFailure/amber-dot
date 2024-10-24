extends Node 
#responsible to handling the states
class_name EnemyStateFunctions

signal colider_changed

var state_manager: EnemyStateActions
var direction = 1
var distance = 0

#position calculus logic 
var current_position = Vector2(0,0)
var new_position = current_position

#state variables 
const WAITING_TIME = 2
var waiting_timer_1 = 0
var waiting_timer_2 = 0   

var current_wall_collider = [null, null]
var new_wall_collider = current_wall_collider

func compare_and_update_colliders():

	for i in range(current_wall_collider.size()):
		if current_wall_collider[i] != new_wall_collider[i]: 
			emit_signal('colider_changed')
			

func _init(_state_manager: EnemyStateActions):
	connect('colider_changed', Callable(self, '__on_colide_changed'))
	self.state_manager = _state_manager
	pass

func get_enemy() -> EnemyBase:
	return self.state_manager._enemy_obj

func patroling(_delta):
	var enemy = get_enemy()
	var colision_data = enemy.get_wall_colision_data() 
	var coliding = colision_data['colision']
	var edge_detection = enemy.edge_detection()
	var object_col = enemy.get_wall_collider()
	print(object_col[0] == null)
	enemy.new_anim = 'walking'
	
	#print(not (edge_detection[0] and edge_detection[1]))
	if coliding or edge_detection:	
		if coliding == true and not _is_valid_colision(object_col):
			print("ignoring because it's the player")
			pass
			
		else:	
			current_position = enemy.position
			waiting_timer_1 = WAITING_TIME 
			enemy._state_mchn._transition(state_manager.TRANS_MELEE_WAITING)
		
			direction *= -1 
			enemy.sprite_flip_h(!enemy.get_sprite_flip_h())
	enemy.velocity.x = (100 * direction)
	pass

#action function
func waiting(_delta):
	var enemy = get_enemy()
	enemy.new_anim = 'default'
	if waiting_timer_1 > 0:
		enemy.velocity.x = 0
		waiting_timer_1 -= _delta 
	else:
		#enemy.sprite_flip_h(!enemy.get_sprite_flip_h())
		enemy._state_mchn._transition(state_manager.TRANS_MELEE_CHANGING_DIR)
		
	pass

func wait_by(value: float):
	var enemy = get_enemy()
	var timer = Timer.new()
	timer.wait_time = value
	timer.one_shot = true 
	timer.autostart = true 
	enemy.add_child(timer)
	await timer.timeout
	timer.queue_free()

func change_patrol_direction(_delta):
	var enemy = get_enemy()
	enemy.new_anim = 'walking'
	
	new_position = enemy.position
	distance = new_position.distance_to(current_position)
	
	enemy.velocity.x = 100 * direction

	if distance >= 10.0:
		distance = 0 
		enemy._state_mchn._transition(state_manager.TRANS_RETURNING_PATROL)

func pursuing(_delta):
	
	pass

func attack(_delta):
	pass

func update(_delta):
	#print(get_enemy()._state_mchn._get_current_state())
	new_wall_collider = get_enemy().get_wall_collider()
	compare_and_update_colliders()

func __on_colide_changed():
	print("did it work?", get_enemy().velocity, current_wall_collider, new_wall_collider)

#check if one of the coliders isn't the player's object
func _is_valid_colision(colider_array: Array):
	if colider_array[0] != null or colider_array[1] != null:
		if not(colider_array[0] is PlayerBase) and not(colider_array[1] is PlayerBase):
			return true 
	return false 
