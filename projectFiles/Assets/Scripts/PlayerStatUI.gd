extends CanvasLayer

@onready var health_bar = get_node('HealthBar') 
@onready var armor_bar = get_node('ArmorBar')


func set_min_max_bar_values() -> void:
	health_bar.max_value = GlobalScript.get_player_stat('max_hit_points')
	health_bar.value = GlobalScript.get_player_stat('hit_points')
	
	armor_bar.max_value = GlobalScript.get_player_stat('max_armor_points')
	armor_bar.value = GlobalScript.get_player_stat('armor_points')
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	set_min_max_bar_values()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_min_max_bar_values()
	pass
