class_name View

extends TileMapLayer

signal cell_selected(v:Vector2i)

var model:Model
var turn_label: Label

func set_model(m:Model, label:Label) -> void:
	model = m
	turn_label = label
	model.connect("model_updated", Callable(self, "_on_model_update"))
	model.connect("game_over", Callable(self, "_on_game_over"))
	_on_model_update() # initial update

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var global_mouse_pos = event.position
			var local_mouse_pos = to_local(global_mouse_pos)
			var cord_in_map:Vector2i = local_to_map(local_mouse_pos)
			if cord_in_map.x >= 0 and cord_in_map.x < 3 and cord_in_map.y >= 0 and cord_in_map.y < 3:
				emit_signal("cell_selected", cord_in_map)
			

func _on_model_update() -> void:
	for coord in model.board.keys():
		var tile_value = model.board[coord]
		if tile_value == "X":
			set_cell(coord, 0, Vector2i(1,0))
		elif tile_value == "O":
			set_cell(coord, 0, Vector2i(0,0))
		elif tile_value == "":
			set_cell(coord, 0, Vector2i(2,0))
		else:
			print("Error: sth wrong is in view._on_model_update()")
	turn_label.text = "Turn: %s" % model.current_player # updating turn label
