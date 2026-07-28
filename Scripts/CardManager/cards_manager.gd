extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_SCALE = 1.2
const CARD_ENLARGED_SCALE = 1.27
const CARD_SMALLER_SCALE = 0.6

var card_being_dragged: Node2D
var screen_size: Vector2
var is_hovering_on_card: bool
var play_monster_card_this_turn := false
var selected_monster

func _ready() -> void:
	screen_size = get_viewport_rect().size

#func _input(event) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.is_pressed():
			#var card = raycast_check_for_card()
			#if card:
				#start_drag(card)
		#else:
			#if card_being_dragged:
				#finish_drag()

func raycast_check_for_card() -> Node2D:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#print(result[0].collider.get_parent())
		#return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x,0,screen_size.x),clamp(mouse_pos.y,0,screen_size.y))

func connect_card_signals(card: Node2D) -> void:
	card.connect("hovered",_on_card_hovered_on)
	card.connect("hovered_off",_on_card_hovered_off)

func _on_card_hovered_on(card: Node2D) -> void:
	if card.card_slot:
		return
	if not is_hovering_on_card:
		highlight_card(card,true)
		is_hovering_on_card = true

func _on_card_hovered_off(card: Node2D) -> void:
	if card.defeated:
		return
	if not card.card_slot:
		highlight_card(card,false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered,true)
		else:
			is_hovering_on_card = false

func highlight_card(card:Node2D,hovered:bool):
	if hovered:
		card.z_index = 2
		card.scale = Vector2(CARD_ENLARGED_SCALE,CARD_ENLARGED_SCALE)
	else:
		card.z_index = 1
		card.scale = Vector2(DEFAULT_CARD_SCALE,DEFAULT_CARD_SCALE)

func get_card_with_highest_z_index(cards:Array) -> Node2D:
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1,cards.size()):
		var cur_card = cards[i].collider.get_parent()
		if cur_card.z_index > highest_z_index:
			highest_z_card = cur_card
			highest_z_index = cur_card.z_index
	
	return highest_z_card

func start_drag(card:Node2D) -> void:
	card_being_dragged = card
	card.scale = Vector2(DEFAULT_CARD_SCALE,DEFAULT_CARD_SCALE)

func finish_drag() -> void:
	card_being_dragged.scale = Vector2(CARD_ENLARGED_SCALE,CARD_ENLARGED_SCALE)
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		
		if card_being_dragged.card_type.capitalize() == card_slot_found.card_slot_type.capitalize():
			if not play_monster_card_this_turn:
				card_being_dragged.scale = Vector2(CARD_SMALLER_SCALE,CARD_SMALLER_SCALE)
				card_being_dragged.card_slot = card_slot_found
				card_being_dragged.z_index = -1
				is_hovering_on_card = false
				%PlayerHand.remove_card_from_hand(card_being_dragged)
				card_being_dragged.position = card_slot_found.position
				#card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
				card_slot_found.card_in_slot = true
				card_slot_found.get_node("Area2D/CollisionShape2D").disabled = true
				%BattleManager.player_cards_on_battlefield.append(card_being_dragged)
				card_being_dragged = null
				return
	%PlayerHand.add_card_to_hand(card_being_dragged,%PlayerHand.DEFAULT_CARD_DRAW_SPEED)
	card_being_dragged = null

func card_clicked(card):
	if card.card_slot:
		if %BattleManager.is_opponent_turn == false:
			if %BattleManager.player_is_atacking == false:
				if card not in %BattleManager.player_cards_attacked_this_turn:
					if %BattleManager.opponent_cards_on_battlefield.size() == 0:
						%BattleManager.direct_attack(card, "Player")
						return
					else:
						select_card_for_battle(card)
	else:
		start_drag(card)

func unselect_selected_monster():
	if selected_monster:
		selected_monster.position.y += 20
		selected_monster = null

func select_card_for_battle(card):
	if selected_monster:
		if selected_monster == card:
			card.position.y += 20
			selected_monster = null
		else:
			selected_monster.position += 20
			selected_monster = card
			card.position.y -= 20
	else:
		selected_monster = card
		card.position.y -= 20

func raycast_check_for_card_slot() -> Node2D:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#print(result[0].collider.get_parent())
		#return result[0].collider.get_parent()
		return result[0].collider.get_parent()
	return null

func _on_input_manager_left_mouse_btn_pressed() -> void:
	#print("Input Manager Left Click Pressed")
	pass

func _on_input_manager_left_mouse_btn_released() -> void:
	if card_being_dragged:
		finish_drag()
