extends Node2D

const CARDS_COUNT = 4
const CARD_DRAWN_SPEED := 0.2

var card_scene = preload("res://Scenes/Cards/card.tscn")

var player_deck = ["joker","joker","joker"]

func _ready() -> void:
	$Label.text = str(player_deck.size())

func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$".".visible = false
	$Label.text = str(player_deck.size())
	var new_card = card_scene.instantiate()
	new_card.global_position = global_position
	%CardsManager.add_child(new_card)
	new_card.name = "Card"
	%PlayerHand.add_card_to_hand(new_card,CARD_DRAWN_SPEED)
