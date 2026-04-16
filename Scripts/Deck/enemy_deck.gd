extends Node2D

const CARDS_COUNT = 4
const CARD_DRAWN_SPEED := 0.2
const STARTING_HAND_SIZE = 3

@onready var cards_database = preload("res://Scripts/CardManager/cards_database.gd")
var card_scene = preload("res://Scenes/Cards/Enemycard.tscn")
var enemy_deck = ["Knight","Archer","Demon","Knight","Archer","Demon"]

func _ready() -> void:
	enemy_deck.shuffle()
	$Label.text = str(enemy_deck.size())
	
	for i in range(STARTING_HAND_SIZE):
		draw_card()

func draw_card():
	
	var card_drawn = enemy_deck[0]
	enemy_deck.erase(card_drawn)
	
	if enemy_deck.size() == 0:
		#$Area2D/CollisionShape2D.disabled = true
		$".".visible = false
	$Label.text = str(enemy_deck.size())
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://assets/Aseprite/Cards/"+ card_drawn +".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.global_position = global_position
	new_card.attack =cards_database.CARDS[card_drawn][0] 
	new_card.get_node("Attack").text = str(cards_database.CARDS[card_drawn][0])
	new_card.get_node("Health").text = str(cards_database.CARDS[card_drawn][1])
	new_card.card_type = cards_database.CARDS[card_drawn][2]
	new_card.name = "Card"
	%CardsManager.add_child(new_card)
	%EnemyHand.add_card_to_hand(new_card,CARD_DRAWN_SPEED)
