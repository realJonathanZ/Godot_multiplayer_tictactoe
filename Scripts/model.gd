class_name Model
extends RefCounted

var tiles:Dictionary[Vector2i, bool]

var board_width:int
var view:View

signal model_updated()

func _init(w:int, v:View):
	board_width = w
	view = v
	
func reset_board() -> void:
	tiles.clear()
	for i in range(board_width):
		for j in range(board_width):
			tiles[Vector2i(i,j)] = false
	model_updated.emit()
			
func toggle_tile(coord:Vector2i) -> void:
	if not tiles.has(coord):
		push_error("tile not in range: " + str(coord))
		return
	tiles[coord] = not tiles[coord]
	model_updated.emit()
	
func get_coords() -> Array[Vector2i]:
	return tiles.keys()	

func get_tile_state(coord:Vector2i) -> bool:
	if tiles.has(coord):
		return tiles[coord]
	else:
		push_error("getting illegal tile")
		return false
		
