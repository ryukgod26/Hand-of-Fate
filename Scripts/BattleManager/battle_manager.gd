extends Node

@onready var end_turn_btn:Button = %EndTurnBtn

var empty_monster_card_slots = []

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
	
	if empty_monster_card_slots.size() == 0:
		end_enemy_turn()
		return

	end_enemy_turn()

func end_enemy_turn() -> void:
	end_turn_btn.visible = true
	end_turn_btn.disabled = false
