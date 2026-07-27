extends Node2D

const COLLISION_MASK_DECK = 4

@onready var cards_manager: Node2D = %CardsManager
@onready var deck: Node2D = %Deck

signal left_mouse_btn_pressed
signal left_mouse_btn_released

func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			left_mouse_btn_pressed.emit()
			raycast_check()
		else:
			left_mouse_btn_released.emit()

func raycast_check():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	#parameters.collision_mask = 4
	var result = space_state.intersect_point(parameters)
	#print("Test")
	#print(result)
	if result.size() > 0:
		var result_collidion_mask = result[0].collider.collision_mask
		if result_collidion_mask & cards_manager.COLLISION_MASK_CARD:
			#print("Dragging Card")
			var card_found = result[0].collider.get_parent()
			if card_found:
				cards_manager.card_clicked(card_found)
		elif result_collidion_mask & COLLISION_MASK_DECK:
			deck.draw_card()
