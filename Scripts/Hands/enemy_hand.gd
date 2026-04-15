extends Node2D

const CARD_WIDTH = 200. #Subject to Change
const HAND_Y_POS = 80.
const DEFAULT_CARD_DRAW_SPEED = .3

var player_hand = []
var center_screen_x: float

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2

func add_card_to_hand(card,speed) -> void:
	if card not in player_hand:
		player_hand.insert(0,card)
		update_hand_positions()
	else:
		animate_card_to_position(card,card.starting_position,speed)

func update_hand_positions() -> void:
	for i in range(player_hand.size()):
		var new_pos = Vector2(calculate_card_position(i),HAND_Y_POS)
		var card = player_hand[i]
		card.starting_position = new_pos
		animate_card_to_position(card,new_pos,DEFAULT_CARD_DRAW_SPEED)

func calculate_card_position(idx) -> float:
	var total_width = (player_hand.size() - 1 )*CARD_WIDTH
	return center_screen_x - idx * CARD_WIDTH +  total_width / 2

func animate_card_to_position(card,pos,speed):
	var tween = create_tween()
	tween.tween_property(card,"global_position",pos,speed)


func remove_card_from_hand(card):
	player_hand.erase(card)
	update_hand_positions()
