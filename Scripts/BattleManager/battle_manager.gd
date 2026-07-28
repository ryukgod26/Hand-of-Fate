extends Node

const SMALL_CARD_SCALE = 0.6
const CARD_MOVE_SPEED = 0.2
const INTIAL_HP: int = 10
const BATTLE_POS_OFFSET = 25

@onready var end_turn_btn:Button = %EndTurnBtn

var empty_monster_card_slots = []
var opponent_cards_on_battlefield = []
var player_cards_on_battlefield = []
var player_cards_attacked_this_turn = []

var player_hp: int
var enemy_hp: int

var is_opponents_turn := false
var player_is_atacking = false

func _ready() -> void:
	player_hp = INTIAL_HP
	enemy_hp = INTIAL_HP
	$"../PlayerHP".text = str(player_hp)
	$"../EnemyHP".text = str(enemy_hp)
	for card_slot in $"../EnemyCardSlots".get_children():
		empty_monster_card_slots.append(card_slot)

func _on_end_turn_btn_pressed() -> void:
	is_opponents_turn = true
	%CardsManager.unselect_selected_monster()
	player_cards_attacked_this_turn = []
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
			if player_cards_on_battlefield.size() != 0:
				var card_to_attack = player_cards_on_battlefield.pick_random()
				await attack(card, card_to_attack, "opponent")
			else:
				direct_attack(card,"Opponent")
	end_enemy_turn()

func attack(attacking_card, defending_card, attacker) -> void:
	if attacker == "Player":
		player_is_atacking = true
		%CardsManager.selected_monster = null
		player_cards_attacked_this_turn.append(attacking_card)
	
	attacking_card.z_index = 5
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + BATTLE_POS_OFFSET)
	var tween = create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	await get_tree().create_timer(0.15).timeout
	var tween2 = create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot.position, CARD_MOVE_SPEED)
	
	defending_card.health = max(0, defending_card.health - attacking_card.attack)
	attacking_card.health = max(0, attacking_card.health - defending_card.health)
	
	await get_tree().create_timer(1.0).timeout
	attacking_card.z_index = 0
	
	var card_destroyed = false
	if attacking_card.health <= 0:
		destroy_card(attacking_card, attacker)
		card_destroyed = true
	if defending_card.health <= 0:
		if attacker.to_lower() == "player":
			destroy_card(defending_card, "opponent")
		else:
			destroy_card(defending_card, "player")
		card_destroyed = true
	
	if attacker == "player":
		player_is_atacking = false

func destroy_card(card, card_owner: String):
	var new_pos
	if card_owner.to_lower() == "player":
		card.defeated = true
		card.get_node("Area2D/CollisionShape2D").disabled = false
		new_pos = $"../PlayerDiscard".position
		if card in player_cards_on_battlefield:
			player_cards_on_battlefield.erase(card)
		card.card_slot.get_node("Area2D/CollisionShape2D").disabled = false
	else:
		new_pos = $"../EnemyDiscard".position
		if card in opponent_cards_on_battlefield:
			opponent_cards_on_battlefield.erase(card)
	card.card_slot.card_in_slot = false
	card.card_slot = null
	var tween = create_tween()
	tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)

func direct_attack(attacking_card,attacker: String) -> void:
	var new_pos_y
	if attacker.to_lower() == "opponent":
		new_pos_y = 1080
	else:
		player_is_atacking = true
		new_pos_y = 0
		player_cards_attacked_this_turn.append(attacking_card)
	
	var new_pos = Vector2(attacking_card.position.x, new_pos_y)
	attacking_card.z_index = 5
	var tween = create_tween()
	tween.tween_property(attacking_card,"global_position",new_pos,CARD_MOVE_SPEED)
	
	await get_tree().create_timer(0.15).timeout
	
	if attacker.to_lower() == "opponent": 
		player_hp = max(0,player_hp - attacking_card.attack)
		$"../PlayerHP".text = str(player_hp)
	else:
		enemy_hp = max(0,enemy_hp - attacking_card.attack)
		$"../EnemyHP".text = str(enemy_hp)
	
	var tween2 = create_tween()
	tween2.tween_property(attacking_card,"global_position",attacking_card.card_slot.position,CARD_MOVE_SPEED)
	attacking_card.z_index = 5
	
	await get_tree().create_timer(1.0).timeout
	
	if attacker.to_lower() == "player":
		player_is_atacking = false

func try_max_dmg_play_card() -> void:
	var enemy_hand = %EnemyHand.enemy_hand
	if enemy_hand.size() == 0:
		end_enemy_turn()
	var random_empty_monster_card_slot = empty_monster_card_slots.pick_random()
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
	max_attack_card.card_slot = random_empty_monster_card_slot
	opponent_cards_on_battlefield.append(max_attack_card)
	await get_tree().create_timer(1.0).timeout

func end_enemy_turn() -> void:
	%Deck.reset_draw()
	is_opponents_turn = false
	end_turn_btn.visible = true
	end_turn_btn.disabled = false

func enemy_card_selected(defending_card):
	var attacking_card = %CardsManager.selected_monster
	if attacking_card:
		if defending_card in opponent_cards_on_battlefield:
			if player_is_atacking == false:
				attack(attacking_card,defending_card, "Player")
