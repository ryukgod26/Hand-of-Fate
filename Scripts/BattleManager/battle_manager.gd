extends Node

const SMALL_CARD_SCALE = 0.6
const CARD_MOVE_SPEED = 0.2

@onready var end_turn_btn:Button = %EndTurnBtn

var empty_monster_card_slots = []
var opponent_cards_on_battlefield = []
var player_cards_on_battlefield = []

func _ready() -> void:
	for card_slot in $"../EnemyCardSlots".get_children():
		empty_monster_card_slots.append(card_slot)


func _on_end_turn_btn_pressed() -> void:
	enemy_turn()

func enemy_turn() -> void:
	end_turn_btn.visible = false
	end_turn_btn.disabled = true
	await get_tree().create_timer(1.0).timeout
	if %EnemyDeck.enemy_deck.size() != 0:
		$"../EnemyDeck".draw_card()
		await get_tree().create_timer(1.0).timeout
	
	if empty_monster_card_slots.size() != 0:
		await try_max_dmg_play_card()
		
	if opponent_cards_on_battlefield.size() != 0:
		var enemy_cards_to_attack = opponent_cards_on_battlefield.duplicate()
		for card in enemy_cards_to_attack:
			pass
	
	end_enemy_turn()

func try_max_dmg_play_card() -> void:
	var enemy_hand = %EnemyHand.enemy_hand
	if enemy_hand.size() == 0:
		end_enemy_turn()
	var random_empty_monster_card_slot = empty_monster_card_slots[randi_range(0,empty_monster_card_slots.size())]
	empty_monster_card_slots.erase(random_empty_monster_card_slot)
	
	var max_attack_card = enemy_hand[0]
	for card in enemy_hand:
		if card.attack > max_attack_card.attack:
			max_attack_card = card
	
	var tween = create_tween()
	tween.parallel()
	tween.tween_property(max_attack_card,"global_position",random_empty_monster_card_slot.global_position,CARD_MOVE_SPEED)
	tween.tween_property(max_attack_card,"scale",Vector2(SMALL_CARD_SCALE,SMALL_CARD_SCALE),CARD_MOVE_SPEED)
	max_attack_card.play_flip_animation()
	
	%EnemyHand.remove_card_from_hand(max_attack_card)
	opponent_cards_on_battlefield.append(max_attack_card)
	await get_tree().create_timer(1.0).timeout
	

func end_enemy_turn() -> void:
	%Deck.reset_draw()
	end_turn_btn.visible = true
	end_turn_btn.disabled = false
