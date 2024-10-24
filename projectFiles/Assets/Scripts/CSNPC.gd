extends CharacterBody2D
class_name CutsceneNPCBase

@export var actor_id: String
@onready var CSManager = get_parent()
@onready var sprite = get_node("AnimatedSprite2D")

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const FRICTION = 200

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#states machine labels and edges
#labels 
const IDLE = 'idle'
const WALK_TO = 'walk_to'
#edges
const TRANSITION_WALK = '1'
const TRANSITION_IDLING = '1'

var state_mchn = StateMachine.new()
var anim: String
var new_anim: String 

#signals 
signal action_ended 

#destination steps for the character
var dest_steps: int 
var walked_steps: int 
var previous_position = Vector2(0,0)
var d_position = Vector2(0,0)

func _set_states():
	state_mchn._add_state(WALK_TO, [TRANSITION_WALK])
	state_mchn._add_state(IDLE, [TRANSITION_IDLING])

func connect_to_parent():
	connect('action_ended', Callable(CSManager, '_on_action_ended'))

func _ready():
	connect_to_parent()
	_set_states()
	actor_id = 'actor_1'
	anim = "idle"
	new_anim = anim 
	sprite.play(anim)

	state_mchn.current_state = IDLE
	state_mchn.new_state = IDLE
	pass

func _flip(value: bool):
	print('flip')
	sprite.flip_h = value 

func _change_animation(anim_name: String):
	new_anim = anim_name
	pass

#movement primitives 
func _walkto(_delta) -> void:
	var direction = sign(dest_steps)
	previous_position = Vector2(self.position.x, 0) 
	if walked_steps < abs(dest_steps):
		#print("walked_steps < dest_steps")
		horizontal_movement(_delta, direction)
	else:
		state_mchn._transition(TRANSITION_IDLING)
		emit_signal("action_ended")
	
pass


func horizontal_movement(_delta, direction):
	#if direction != 0:
	#	if direction == -1:
	#		animation_node.flip_h = true 
	#	else:  
	#		animation_node.flip_h = false
	#	velocity.x = direction * SPEED
	#else:
	#var d_pos_x = self.position.x 
	velocity.x = direction * SPEED
	velocity.x = move_toward(velocity.x, 0, FRICTION * _delta)
	#d_pos_x -= self.position.x 
	#print(d_pos_x)
	#print("Velocity X: ", velocity.x)  # Debugging movement


func _wait(time_s: float):
	print("waiting")
	var timer = Timer.new()
	get_parent().add_child(timer)
	timer.wait_time = time_s
	timer.one_shot = true 
	timer.start()
	await timer.timeout
	timer.queue_free()
	pass

func _physics_process(delta):
	if anim != new_anim:
		anim = new_anim
		sprite.play(anim)

	state_mchn._update_state()	
	var state = state_mchn._get_current_state()
	#print(state)
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if state == IDLE:
		velocity.x = 0
		velocity.y = 0
		pass
	elif state == WALK_TO:
		_walkto(delta)

	move_and_slide()
	d_position = self.position - previous_position
	#print(abs(d_position.x))
	
	
	#update walked steps 
	if abs(d_position.x) >= 0 and abs(velocity).x > 0:
		walked_steps += abs(d_position.x)

	#print(walked_steps)

	pass
