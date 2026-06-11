extends Node2D

signal hovered
signal hovered_off

var starting_position
var card_slot
var card_type
var health:
	set(new_val):
		health = new_val
		$Health.text = str(health)

func _ready() -> void:
	get_parent().connect_card_signals(self)
	starting_position = global_position

func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)

func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)

func play_flip_animation():
	$AnimationPlayer.play("card_flip")
