extends Node
class_name PlayerBehaviourControl

var __character_id: String 

#max stats 
var __max_hit_points: float 
var __max_armor_points: float 

#current stats 
var __hit_points: float 
var __armor_points: float 

func get_character_id() -> String:
	return self.__character_id

func set_character_id(value: String) -> void:
	self.__character_id = value 

func set_max_btl_stats_values(hp:float, armor:float) -> void:
	self.__max_hit_points = hp  
	self.__max_armor_points = armor 

func set_btl_stats_values(hp:float, armor:float) -> void:
	self.__hit_points = hp  
	self.__armor_points = armor 

#getter and setter for max values
func set_max_hit_points(value: float) -> void:
	self.__max_hit_points = value 

func set_max_armor_points(value: float) -> void:
	self.__armor_points = value 

func get_max_hit_points() -> float:
	return self.__max_hit_points

func get_max_armor_points() -> float:
	return self.__max_armor_points 

#getter and setter for current values

func set_hit_points(value: float) -> void:
	self.__hit_points = value 

func set_armor_points(value: float) -> void:
	self.__armor_points = value 

func get_hit_points() -> float:
	return self.__hit_points

func get_armor_points() -> float:
	return self.__armor_points 

