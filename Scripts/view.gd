class_name View

extends TileMapLayer

var model:Model

signal cell_selected(v:Vector2i)

func set_model(m:Model) -> void:
	model = m
	model.connect("model_updated", on_model_update)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var global_mouse_pos = event.position
			var local_mouse_pos = to_local(global_mouse_pos)
			var selected_cell:Vector2i = local_to_map(local_mouse_pos)
			
			cell_selected.emit(selected_cell)

func on_model_update() -> void:
	var coords:Array[Vector2i] = model.get_coords()
	for c in coords:
		if model.get_tile_state(c):
			set_cell(c, 0, Vector2i(0,0))
		else:
			set_cell(c, 0, Vector2i(5,0))
