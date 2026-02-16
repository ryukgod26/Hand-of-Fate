extends Node2D

var card_being_dragged: Node2D
var screen_size: Vector2
var is_hovering_on_card: bool

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card = raycast_check_for_card()
			if card:
				card_being_dragged = card
		else:
			card_being_dragged = null

func raycast_check_for_card() -> Node2D:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
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
	if not is_hovering_on_card:
		highlight_card(card,true)
		is_hovering_on_card = true

func _on_card_hovered_off(card: Node2D) -> void:
	highlight_card(card,false)
	var new_card_hovered = raycast_check_for_card()
	if new_card_hovered:
		highlight_card(new_card_hovered,true)
	else:
		is_hovering_on_card = false

func highlight_card(card:Node2D,hovered:bool):
	if hovered:
		card.scale = Vector2(1.09,1.09)
		card.z_index = 2
	else:
		card.scale = Vector2(1.,1.)
		card.z_index = 1

func get_card_with_highest_z_index(cards:Array) -> Node2D:
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1,cards.size()):
		var cur_card = cards[i].collider.get_parent()
		if cur_card.z_index > highest_z_index:
			highest_z_card = cur_card
			highest_z_index = cur_card.z_index
	
	return highest_z_card

func start_drag() -> void:
	pass

func finish_drag() -> void:
	pass
