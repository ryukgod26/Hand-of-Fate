extends Node2D

var starting_position
var card_type

func play_flip_animation():
	$AnimationPlayer.play("card_flip")
