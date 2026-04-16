extends Node2D

var starting_position
var card_type
var attack

func play_flip_animation():
	$AnimationPlayer.play("card_flip")
