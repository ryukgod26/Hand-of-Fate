extends Node

@onready var end_turn_btn:Button = %EEndTurnBtn

var empty_monster_card_slots = []

func _ready() -> void:
	for card_slot in $"../OpponentCardSlots".get_children():
		empty_monster_card_slots.append(card_slot)


func _on_end_turn_btn_pressed() -> void:
	opponent_turn()

func opponent_turn() -> void:
	end_turn_btn.visible = false
	end_turn_btn.disabled = true
	$"../OpponentDeck".draw_card()
	await get_tree().create_timer(1.0).timeout
	
	if empty_monster_card_slots.size() == 0:
		end_opponent_turn()
		return

	end_opponent_turn()

func end_opponent_turn() -> void:
	end_turn_btn.visible = true
	end_turn_btn.disabled = false
