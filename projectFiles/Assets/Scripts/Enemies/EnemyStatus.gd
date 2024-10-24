extends Node 
class_name EnemyStatus

#max status value 
var __max_hit_points: float
var __max_lust_points: float 

#current status value 
var __hit_points: float
var __lust_points: float 

#setters 
func set_max_hit_points(value: float):
    self.__max_hit_points = value 

func set_max_lust_points(value: float):
    self.__max_lust_points = value 

func set_hit_points(value: float):
    self.__hit_points = value 

func set_lust_points(value: float):
    self.__lust_points = value 

#getters 
func get_max_hit_points():
    return self.__max_hit_points

func get_max_lust_points():
    return self.__max_lust_points

func get_hit_points():
    return self.__hit_points

func get_lust_points():
    return self.__lust_points

