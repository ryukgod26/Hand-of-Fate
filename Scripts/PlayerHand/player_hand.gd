extends Node2D

const CARD_WIDTH = 200. #Subject to Change
const HAND_Y_POS = 890.

var player_hand = []
var center_screen_x: float

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	
	
	update_hand_positions()

func add_card_to_hand(card) -> void:
	player_hand.insert(0,card)

func update_hand_positions() -> void:
	for i in range(player_hand.size()):
		var new_pos = Vector2(calculate_card_position(i),HAND_Y_POS)
		var card = player_hand[i]
		animate_card_to_position(card,new_pos)

func calculate_card_position(idx) -> float:
	var total_width = (player_hand.size() - 1 )*CARD_WIDTH
	return center_screen_x + idx * CARD_WIDTH -  total_width / 2

func animate_card_to_position(card,pos):
	var tween = create_tween()
	tween.tween_property(card,"position",pos,0.3)
