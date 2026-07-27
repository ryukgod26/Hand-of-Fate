extends Node2D

var starting_position
var card_type
var card_slot
var health:
	set(new_val):
		health = new_val
		$Health.text = str(health)
var attack:
	set(new_val):
		attack = new_val
		$Attack.text = str(attack)

func play_flip_animation():
	$AnimationPlayer.play("card_flip")
