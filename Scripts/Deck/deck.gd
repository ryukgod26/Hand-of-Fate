extends Node2D

const CARDS_COUNT = 4

var card_scene = preload("res://Scenes/Cards/card.tscn")

var player_deck = ["joker","joker","joker"]

func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
	var new_card = card_scene.instantiate()
	%CardsManager.add_child(new_card)
	new_card.name = "Card"
	%PlayerHand.add_card_to_hand(new_card)
