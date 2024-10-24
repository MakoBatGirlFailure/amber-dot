extends Node2D
@onready var sensor_1 = get_node('Sensor1')
@onready var sensor_2 = get_node('Sensor2')

@onready var rays = [sensor_1, sensor_2]

# Called when the node enters the scene tree for the first time.
func _ready():
	print(sensor_1)
	pass # Replace with function body.

func is_colliding():
	var result_array = []
	for ray in rays:
		result_array.append(ray.is_colliding())

	return {'colision': (result_array[0] || result_array[1]), 'sensor_1': result_array[0], 'sensor_2': result_array[1]}	

func get_colliders():
	var result_array = []
	for ray in rays:
		result_array.append(ray.get_collider())
	
	return result_array
