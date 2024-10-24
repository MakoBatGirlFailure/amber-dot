extends EnemyBase

@onready var eye_sight = get_node("SensorsGroup").get_node("EyeSight")

#player distance control
const CLOSER_DISTANCE = 100

#some state triggers 
const DIST_PLAYER_FAR = 101
const DIST_PLAYER_TOO_FAR = 200
const DIST_PLAYER_IN_RANGE = 70

#state machine edges:
const PLAYER_FAR_AWAY = '1'
const PLAYER_TOO_FAR = '2'
const PLAYER_IN_RANGE = '3'
const PLAYER_LOST = '4'
const PLAYER_DETECTED = '5'
const PLAYER_OUT_OF_RANGE = '6'

@onready var label = $Label 
var player_closer = false  
var distance = 0.0


#overriding the default state machine functions:
func _loading_base_states():
	_state_mchn._add_state(IDLE, [PLAYER_TOO_FAR, PLAYER_IN_RANGE, PLAYER_LOST])
	_state_mchn._add_state(WALKING, [PLAYER_OUT_OF_RANGE, PLAYER_FAR_AWAY])
	_state_mchn._add_state(ATTACK, [PLAYER_DETECTED, PLAYER_IN_RANGE])
	_state_mchn.current_state = IDLE
	_state_mchn.new_state = IDLE
	pass

func _ready():
	CommandParser._execute_string("ping pong ping")
	_loading_base_states()
	_ready_overrides("AnimatedSprite2D")
	new_anim = "default"

func _draw():
	if GlobalScript.player_node != null:
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
func idle(_delta):
	new_anim = 'default'
	if distance < DIST_PLAYER_FAR:
		_state_mchn._transition(PLAYER_FAR_AWAY)
	elif distance < DIST_PLAYER_IN_RANGE:
		_state_mchn._transition(PLAYER_IN_RANGE)
	pass

func walking(_delta):
	new_anim = 'walking'
	if distance < CLOSER_DISTANCE:
		_state_mchn._transition(PLAYER_DETECTED)
	elif distance > DIST_PLAYER_TOO_FAR:
		_state_mchn._transition(PLAYER_TOO_FAR)
	
	
	pass

func attack(_delta):
	new_anim = 'attack'
	if distance >= DIST_PLAYER_TOO_FAR:
		_state_mchn._transition(PLAYER_LOST)

	

func _physics_process(_delta):
	#get the current state machine 
	var state = _state_mchn._get_current_state()
	_state_mchn._update_state()
	#debug stuff, it wouldn't be bothered with
	if GlobalScript.player_node != null:
		distance = self.global_position.distance_to(GlobalScript.player_node.global_position)
		label.text = "Distancia: " + str(distance) + "."
		
		player_closer = (distance < CLOSER_DISTANCE)

	if not is_on_floor():
		velocity.y += gravity * _delta

	if anim != new_anim:
		anim = new_anim

	
	if state == IDLE:
		idle(_delta)
	elif state == WALKING:
		walking(_delta)
	elif state == ATTACK:
		attack(_delta)

	if GlobalScript.player_node != null:
		var player_pos = self.to_local(GlobalScript.player_node.global_position)
		var enemy_pos = self.to_local(self.global_position)
		var direction = _get_object_vertical_orientation(player_pos, enemy_pos)
		self._anim_spr.flip_h = not direction
	get_anim_spr_node().play(anim)
	move_and_slide()
	queue_redraw()

func _on_eye_sight_body_entered(body):
	if body is PlayerBase:
		print('player detected')
	pass # Replace with function body.
