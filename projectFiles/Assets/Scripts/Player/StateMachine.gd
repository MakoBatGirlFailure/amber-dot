class_name StateMachine 
extends Node 

var transitions = {}    
var new_state = null 
var current_state = null 

func _add_state(state_name: String, state_transitions: Array):
	for transition in state_transitions:
		self.transitions[transition] = state_name

func _get_current_state():
	return self.current_state

func _set_current_state(state_name):
	self.current_state = state_name 

func _transition(transition_name):
	if self.transitions.has(transition_name): 
		self.new_state = self.transitions[transition_name]

func _update_state():
	if self.new_state != self.current_state:
		self.current_state = self.new_state
		
func _on_changed_state(transition_key: String):
	self._transition(transition_key)
