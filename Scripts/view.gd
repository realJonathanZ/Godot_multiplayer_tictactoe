class_name View

extends TileMapLayer

signal cell_selected(v:Vector2i)

var model:Model
var turn_label: Label

## Build relation that view is now reactive to some signal that omited from the model class.
## This func is called when _ready() inside controller.gd
func set_model(m:Model, label:Label) -> void:
	model = m
	turn_label = label
	model.connect("model_updated", Callable(self, "_on_model_update"))
	model.connect("game_over", Callable(self, "_on_game_over"))
	_on_model_update() # initial update

## Detection for the left click happened inside the game window.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# get_global_mouse_position() takes camera into account, returns the true postion inside the game world, 
			# instead of only the GameWindow-speific postion which previously offered by event.position
			var global_mouse_pos = get_global_mouse_position()  
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
	
func _on_game_over(winner: String):
	var msg = ""
	if winner == "Cat":
		msg = "Draw! Cat wins!"
	else:
		msg = "%s wins!" % winner

	var popup = ConfirmationDialog.new()
	add_child(popup)
	popup.dialog_text = msg
	popup.get_ok_button().text = "New Game"
	popup.popup_centered()
	popup.connect("confirmed", Callable(self, "_restart_game")) ## This signal is a built-in from ConfirmationDialog instance

func _restart_game():
	model.reset_board()
	
