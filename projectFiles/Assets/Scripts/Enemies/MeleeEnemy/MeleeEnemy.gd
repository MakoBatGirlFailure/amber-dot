extends EnemyBase
class_name MeleeEnemy

#export var 
@export var max_hp = 100
@export var max_lust = 100 
@export var lust = 0 
@export var hp = 100

#enemy status control 
var stats = EnemyStatus.new()


#player distance control

@onready var wall_sensor = get_node("EnemyWallSensor")
@onready var floor_sensor = get_node('EnemyFloorSensor')

@onready var label = $Label 
var player_closer = false  
var distance = 0.0

#enemy states database 
var state_func = EnemyStateActions.new(_state_mchn, self)


func floor_colision_data() -> Dictionary:
	return floor_sensor.is_colliding()

func edge_detection():
	var data = floor_colision_data()
	return not(data['sensor_1'] and data['sensor_2'])
	
func wall_colliding() -> bool:
	var colision_data = wall_sensor.is_colliding()
	return colision_data['colision']


func get_wall_collider():
	return wall_sensor.get_colliders()

func get_wall_colision_data():

	return wall_sensor.is_colliding()

#overriding the default state machine functions:
func _loading_base_states():
	_state_mchn._add_state(state_func.MELLEE_PATROLING, [state_func.TRANS_MELEE_PATROLLING, state_func.TRANS_RETURNING_PATROL])
	_state_mchn._add_state(state_func.MELEE_WAITING, [state_func.TRANS_MELEE_WAITING])
	_state_mchn._add_state(state_func.CHANGING_PATROLING_DIRECTION, [state_func.TRANS_MELEE_CHANGING_DIR])
	
	_state_mchn.current_state = state_func.MELLEE_PATROLING
	_state_mchn.new_state = state_func.MELLEE_PATROLING
	pass

func get_stats(key_name: String):
	match key_name:
		'max_hit_points':
			return stats.get_max_hit_points()
		'max_lust_points':
			return stats.get_max_lust_points()
		'hit_points':
			return stats.get_hit_points()
		'lust_points':
			return stats.get_lust_points()

func set_stats(key_name: String, value):
	match key_name:
		'max_hit_points':
			stats.set_max_hit_points(value)
		'max_lust_points':
			stats.set_max_lust_points(value)
		'hit_points':
			stats.set_hit_points(value)
		'lust_points':
			stats.set_lust_points(value)



func set_default_stats(_max_hp: float, _max_lust: float, _hp: float, _lust = 0):
	stats.set_max_hit_points(_max_hp)
	stats.set_max_lust_points(_max_lust)
	stats.set_hit_points(_hp)
	stats.set_lust_points(_lust)

func _ready():
	set_default_stats(max_hp, max_lust, hp, lust)
	_loading_base_states()
	_ready_overrides("AnimatedSprite2D")
	new_anim = "default"

func _draw():
	if GlobalScript.player_node != null and false:
		var color = Color(1,0,0)
		if player_closer:
			color = Color(1,0,0)
		else:	
			color = Color(0,1,0)
		# Desenhar as bolinhas do jogador e inimigo
		var player_position = self.to_local(GlobalScript.player_node.global_position)
		var enemy_position = self.to_local(self.global_position)
		
		draw_circle(player_position, 5, Color(0, 1, 0)) # Verde no jogador
		draw_circle(enemy_position, 5, Color(1, 0, 0)) # Vermelho no inimigo

		# Desenhar a linha entre inimigo e jogador
		draw_line(enemy_position, player_position, color)
	pass

#each state machine and how they can react based on player's behavior

func _physics_process(_delta):
	state_func._enemy_physics_update(_delta)
	#debug stuff, it wouldn't be bothered with
	if GlobalScript.player_node != null:
		distance = self.global_position.distance_to(GlobalScript.player_node.global_position)
		label.text = "Distancia: " + str(distance) + "."
		
	
	#if GlobalScript.player_node != null:
		#var player_pos = self.to_local(GlobalScript.player_node.global_position)
		#var enemy_pos = self.to_local(self.global_position)
		#var direction = _get_object_vertical_orientation(player_pos, enemy_pos)
		#self._anim_spr.flip_h = not direction
	queue_redraw()

