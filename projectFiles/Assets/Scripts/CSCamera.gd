extends Camera2D
class_name CSCamera
signal action_ended 

@onready var CSManager = get_parent()


var _camera_id : String 
var _state_mchn = StateMachine.new()

#camera movement parameters
#destination:
var _destination_point = Vector2(156,164)
var _cam_velocity = 200 

#camera shaking 
var shake_intensity = 10.0 
var shake_duration = 1.5 
var shake_timer = 0.0 
var original_position: Vector2

#states 
const MOVING_CAMERA = 'moving_camera' 
const IDLE_CAMERA = 'idle_camera'
const SHAKING_CAMERA = 'shaking_camera'

#edges 
const TRANSITION_MOVE = '1'
const TRANSITION_IDLE = '2'
const TRANSITION_SHAKE = '3'

#set shake parameters 
func _set_shake_params():
	original_position = position
	shake_timer = shake_duration

#connect to the parent node
func connect_to_parent():
	connect('action_ended', Callable(CSManager, '_on_action_ended'))

# Called when the node enters the scene tree for the first time.
func _set_states():
	_state_mchn._add_state(MOVING_CAMERA, [TRANSITION_MOVE])
	_state_mchn._add_state(IDLE_CAMERA, [TRANSITION_IDLE])
	_state_mchn._add_state(SHAKING_CAMERA, [TRANSITION_SHAKE])


func _get_angle_between_points(p1: Vector2, p2:Vector2) -> float:
	#get the delta between the points 
	var delta = p2 - p1

	return atan2(delta.y, delta.x)

# function that is being called on the frame within _process() ou _physics_process()
func apply_camera_shake(_delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= _delta

		# Generate a random offset that creates the illusion of shaking 
		var random_offset = Vector2(
			randf_range(-1.0, 1.0) * shake_intensity,
			randf_range(-1.0, 1.0) * shake_intensity
		)

		# Aplica o deslocamento à posição original da câmera
		position = original_position + random_offset

		# Se o tempo do shake acabar, reseta a posição da câmera
		if shake_timer <= 0:
			position = original_position
			emit_signal("action_ended")
			_state_mchn._transition(TRANSITION_IDLE)
	

func _ready():
	_set_states()
	self._camera_id = 'camera_1'
	pass # Replace with function body.

func _move_camera(_delta:float, moving_speed: float, angle: float):
	var direction = Vector2(cos(angle), sin(angle))
	direction = direction.normalized()

	self.position += moving_speed * direction * _delta
	pass

func moving_camera(_delta:float) -> void:
	var angle = _get_angle_between_points(self.position, self._destination_point)
	print(self.position.distance_to(self._destination_point))
		
	_move_camera(_delta, _cam_velocity, angle)
	if self.position.distance_to(self._destination_point) < 2.5:
		_state_mchn._transition(TRANSITION_IDLE)
		emit_signal("action_ended")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _state_mchn.new_state == SHAKING_CAMERA and _state_mchn.current_state != SHAKING_CAMERA:
		_set_shake_params()
	_state_mchn._update_state()
	var state = _state_mchn._get_current_state()
	#_move_camera(_delta, 200, rad_to_deg(_get_angle_between_points(self.position, self._destination_point)))

	if state == MOVING_CAMERA:
		moving_camera(_delta)
		pass
	elif state == IDLE_CAMERA:
		pass
	elif state == SHAKING_CAMERA:
		apply_camera_shake(_delta)
		pass

	pass
