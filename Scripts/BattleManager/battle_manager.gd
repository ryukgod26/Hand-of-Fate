extends Node

const SMALL_CARD_SCALE = 0.6
const CARD_MOVE_SPEED = 0.2
const INTIAL_HP: int = 10
const BATTLE_POS_OFFSET = 25

@onready var end_turn_btn:Button = %EndTurnBtn

var empty_monster_card_slots = []
var opponent_cards_on_battlefield = []
var player_cards_on_battlefield = []

var player_hp: int
var enemy_hp: int

func _ready() -> void:
	player_hp = INTIAL_HP
	enemy_hp = INTIAL_HP
	$"../PlayerHP".text = str(player_hp)
	$"../EnemyHP".text = str(enemy_hp)
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
			if player_cards_on_battlefield.size() != 0:
				var card_to_attack = player_cards_on_battlefield.pick_random()
				await attack(card, card_to_attack, "opponent")
			else:
				direct_attack(card,"Opponent")
	end_enemy_turn()

func attack(attacking_card, defending_card, attacker) -> void:
	attacking_card.z_index = 5
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + BATTLE_POS_OFFSET)
	var tween = create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	await get_tree().create_timer(0.15).timeout
	var tween2 = create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot, CARD_MOVE_SPEED)
	
	defending_card.health = max(0, defending_card.health - attacking_card.attack)
	attacking_card.health = max(0, attacking_card.health - defending_card.health)
	
	await get_tree().create_timer(1.0).timeout
	attacking_card.z_index = 0
	
	if attacking_card.health <= 0:
		destroy_card(attacking_card, attacker)
	if defending_card.health <= 0:
		if attacker.to_lower() == "player":
			destroy_card(defending_card, "opponent")
		else:
			destroy_card(defending_card, "player")

func destroy_card(card, card_owner):
	pass

func direct_attack(attacking_card,attacker: String) -> void:
	var new_pos_y
	if attacker.to_lower() == "opponent":
		new_pos_y = 1080
	else:
		new_pos_y = 0
	
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
	end_turn_btn.visible = true
	end_turn_btn.disabled = false
