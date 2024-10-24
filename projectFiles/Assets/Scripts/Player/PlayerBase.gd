extends CharacterBody2D
class_name PlayerBase

const SPEED = 180.0
const JUMP_VELOCITY = -400.0
const FRICTION = 2400
const DASH_SPEED_Y = -100
const DASH_SPEED = 550.0

const DASH_DURATION = 0.4  # Duração do dash em segundos
const SLASH_DURATION = 0.3 #Duração do slash em segundos 
const SLASH_DURATION_2 = 0.4
const SLASH_FALLING_DURATION = 0.45
const HARD_SALSH_DURATION = 0.55
const WALKING_DASH_DURATION = 0.2

const PRE_WALKING_SLASH_DURATION = 0.09 #the delay before the actual slash happen
const WALKING_SLASH_DURATION = 0.45 #the animation time 
const POST_WALKING_SLASH_DURATION = 0.10 #the time left before going to another state 

# Nodes
@onready var animation_node = get_node("AnimatedSprite2D")
@onready var sensors = get_node('Sensors')

# Animation variables
var anim = 'idle'
var new_anim = anim 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Player state machine 
var state_mchn = StateMachine.new()

# Internal player's signal emitter 
signal changed_state 

#vectorial stuff
var normal_velocity = Vector2(0,0)

# Constants 
const IDLE_TRANS = '1'
const WALKING_TRANS = '2'
const JUMPING_TRANS = '3'
const FALLING_TRANS = '4'
const DASHING_TRANS = '5'
const SLIDE_TRANS = '6'
const SLASHING_TRANS = '7'
const SLASHING_2_TRANS = "8"
const SLASHING_FALL_TRANS = '9'
const HARD_SLASH_TRANS = '10'
const PRE_WALKING_SLASH_TRANS = '11'
const WALKING_SLASH_TRANS = '12'
const POST_WALKING_SLASH_TRANS = '13'

const IDLE = "idle"
const WALKING = "walking"
const JUMPING = "jumping"
const FALLING = "falling"
const DASHING = "dashing"
const SLIDING = "sliding"
const SLASHING = "slashing" 
const SLASHING_2 = "slashing2"
const SLASHING_FALL = "slashing_fall"
const HARD_SLASH = 'hard_slash'
const PRE_WALKING_SLASH= 'pre_walking_slash'
const WALKING_SLASH = 'walking_slash'
const POST_WALKING_SLASH = 'post_walking_slash'

var dash_timer = 0.0
var slash_timer = 0.0 
var walking_dash_timer = 0.0
var pre_walking_slash_timer = 0.0
var walking_slash_timer = 0.0 
var post_walking_slash_timer = 0.0  

func get_player_position() -> Vector2:
	return self.global_position

# States dictionary:
func _ready():
	GlobalScript.player_node = self
	state_mchn._add_state(IDLE, [IDLE_TRANS])
	state_mchn._add_state(WALKING, [WALKING_TRANS])
	state_mchn._add_state(JUMPING, [JUMPING_TRANS])
	state_mchn._add_state(FALLING, [FALLING_TRANS])
	state_mchn._add_state(DASHING, [DASHING_TRANS])
	state_mchn._add_state(SLIDING, [SLIDE_TRANS])
	state_mchn._add_state(SLASHING, [SLASHING_TRANS])
	state_mchn._add_state(SLASHING_2, [SLASHING_2_TRANS])
	state_mchn._add_state(SLASHING_FALL, [SLASHING_FALL_TRANS])
	state_mchn._add_state(HARD_SLASH, [HARD_SLASH_TRANS])
	state_mchn._add_state(PRE_WALKING_SLASH, [PRE_WALKING_SLASH_TRANS])
	state_mchn._add_state(WALKING_SLASH, [WALKING_SLASH_TRANS])
	state_mchn._add_state(POST_WALKING_SLASH, [POST_WALKING_SLASH_TRANS])

	state_mchn.current_state = IDLE
	state_mchn.new_state = IDLE

func wall_collide() -> bool:
	var colision_data = sensors.is_colliding()
	return colision_data['colision']
	

func walking_state(delta):
	new_anim = 'walking'
	walking_dash_timer -= delta
	if walking_dash_timer >= 0:
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			start_dashing()

	if not is_on_floor():
		state_mchn._transition(FALLING_TRANS)
	elif velocity.x == 0 :
		state_mchn._transition(IDLE_TRANS)

	if Input.is_action_just_pressed("jumping") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		state_mchn._transition(JUMPING_TRANS)
	elif Input.is_action_just_pressed("dashing"):
		start_dashing()
	
	var direction = Input.get_axis("ui_left", "ui_right")
	horizontal_movement(delta, direction)


func horizontal_movement(_delta, direction):
	if direction != 0:
		if direction == -1:
			animation_node.flip_h = true 
		else:  
			animation_node.flip_h = false
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * _delta)
	#print("Velocity X: ", velocity.x)  # Debugging movement

func jump(_delta):
	new_anim = 'jump_loop'
	# Handle Jump.
	velocity.y += gravity * _delta
	if Input.is_action_just_pressed("slashing"):
		#print("slashing on air")
		start_slashing(3)
	if is_on_floor():
		state_mchn._transition(IDLE_TRANS)
	
	var direction = Input.get_axis("ui_left", "ui_right")
	horizontal_movement(_delta, direction)

func idle(_delta):
	new_anim = 'idle'
	if not is_on_floor():
		#print("Changing state to fall")
		state_mchn._transition(FALLING_TRANS)
	elif Input.get_axis("ui_left", "ui_right") != 0:
		#print("Changing state to walk")
		new_anim = 'walking'
		walking_dash_timer = WALKING_DASH_DURATION
		state_mchn._transition(WALKING_TRANS)
	elif Input.is_action_just_pressed("jumping") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		state_mchn._transition(JUMPING_TRANS)
		#print("Jumping")
	elif Input.is_action_just_pressed("dashing"):
		start_dashing()
	elif Input.is_action_just_pressed("slashing"):
		start_slashing(1)
	elif Input.is_action_just_pressed("hardSlash"):
		start_slashing(4)
	
	velocity.x = move_toward(velocity.x, 0, FRICTION * _delta)

func falling(_delta):
	new_anim = 'jump_loop'
	# Add the gravity.
	if Input.is_action_just_pressed("slashing"):
		#print("slashing on air")
		start_slashing(3)
	if is_on_floor():
		state_mchn._transition(IDLE_TRANS)
	else:
		velocity.y += gravity * _delta
	#print("Falling. Y velocity: ", velocity.y)  # Debugging fall

	var direction = Input.get_axis("ui_left", "ui_right")
	horizontal_movement(_delta, direction)

func dashing(_delta):
	new_anim = "dashing"
	dash_timer -= _delta
	if dash_timer <= 0:
		velocity.x = 0
		state_mchn._transition(IDLE_TRANS if is_on_floor() else FALLING_TRANS)
	else:
		if animation_node.flip_h:
			velocity.x = -DASH_SPEED
		else:
			velocity.x = DASH_SPEED
	# Adiciona gravidade durante o dash

	if Input.is_action_just_released('dashing'):
		velocity.x = 0
		state_mchn._transition(IDLE_TRANS if is_on_floor() else FALLING_TRANS)

	if Input.is_action_just_pressed("jumping"):
		velocity.x = normal_velocity.x * DASH_SPEED
		velocity.y = (JUMP_VELOCITY + DASH_SPEED_Y) 
		state_mchn._transition(JUMPING_TRANS)
		#print("Jumping from dash")
	
	if not is_on_floor():
		velocity.y += gravity * _delta

func start_dashing():
	dash_timer = DASH_DURATION
	state_mchn._transition(DASHING_TRANS)

func start_pre_walk_slash():
	pre_walking_slash_timer = PRE_WALKING_SLASH_DURATION
	state_mchn._transition(PRE_WALKING_SLASH_TRANS)

func slashing(_delta):
	new_anim = 'slash_combo_1'
	slash_timer -= _delta 
	if Input.is_action_just_pressed("slashing"):
			#print("slash2")
			slash_timer = SLASH_DURATION_2
			start_slashing(2)
	elif slash_timer <= 0:
		state_mchn._transition(IDLE_TRANS)

func slashing_2(_delta):
	new_anim = 'slash_combo_2'
	slash_timer -= _delta 
	if slash_timer <= 0:
		state_mchn._transition(IDLE_TRANS)

func slashing_fall(_delta):
	new_anim = 'air_slash'
	slash_timer -= _delta
	if slash_timer <= 0:
		state_mchn._transition(IDLE_TRANS if is_on_floor() else FALLING_TRANS)
	elif is_on_floor():
		state_mchn._transition(IDLE_TRANS)
	
	velocity.y += gravity * _delta
	var direction = Input.get_axis("ui_left", "ui_right")
	horizontal_movement(_delta, direction)

func start_slashing(state):
	if state == 1:
		slash_timer = SLASH_DURATION
		state_mchn._transition(SLASHING_TRANS)
	elif state == 2:
		slash_timer = SLASH_DURATION
		state_mchn._transition(SLASHING_2_TRANS)
	elif state == 3:
		slash_timer = SLASH_FALLING_DURATION
		state_mchn._transition(SLASHING_FALL_TRANS)
	elif state == 4:
		slash_timer = HARD_SALSH_DURATION
		state_mchn._transition(HARD_SLASH_TRANS)
	elif state == 5:
		pre_walking_slash_timer = 0.0
		slash_timer = WALKING_SLASH_DURATION
		state_mchn._transition(WALKING_SLASH_TRANS)
	
func pre_walking_slash(delta):
	new_anim = 'walk_pre_slash'
	print(pre_walking_slash_timer)
	pre_walking_slash_timer -= delta
	if pre_walking_slash_timer <= 0:
		print("transition?")
		start_slashing(5)
	
	

func walking_slash(delta):
	print("Walking slash state triggered")
	new_anim = 'walk_slash'
	slash_timer -= delta
	if not is_on_floor():
		state_mchn._transition(FALLING_TRANS)
	if slash_timer <= 0:
		state_mchn._transition(IDLE_TRANS if is_on_floor() else FALLING_TRANS)
		
		pass

func hard_slash(delta):
	new_anim = 'hard_slash'
	slash_timer -= delta 
	if slash_timer <= 0:
		state_mchn._transition(IDLE_TRANS if is_on_floor() else FALLING_TRANS)
	

func _physics_process(delta):
	#if the console is running, don't do anything
	if GlobalScript.active_console:
		return 
	normal_velocity = velocity.normalized()
	#print(normal_velocity)
	state_mchn._update_state()
	var state = state_mchn._get_current_state()

	if anim != new_anim:
		anim = new_anim
		animation_node.play(anim)

	match state:
		IDLE:
			idle(delta)
		WALKING:
			walking_state(delta)
		JUMPING:
			jump(delta)
		FALLING:
			falling(delta)
		DASHING:
			dashing(delta)
		SLASHING:
			slashing(delta)
		SLASHING_2:
			slashing_2(delta)
		HARD_SLASH:
			hard_slash(delta)
		SLASHING_FALL:
			slashing_fall(delta)
	
	move_and_slide()


func _on_animated_sprite_2d_animation_finished():
	if animation_node.animation == 'dashing':
		state_mchn._transition(IDLE_TRANS)
		pass
	
	pass # Replace with function body.
