extends Node2D

var starting_position
var card_type
var attack
var card_slot

func play_flip_animation():
	$AnimationPlayer.play("card_flip")
