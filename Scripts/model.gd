class_name Model
extends RefCounted

var tiles:Dictionary[Vector2i, bool]

var view:View

signal model_updated() # Notify the view to redraw
signal game_over(winner) # winner = "X", "O" or "cat"

var board : Dictionary = {} # keys: Vector2i(x,y), values: "X", "O" or ""
var current_player : String = "X" # The first turn is always X? not bad

## Constructor of model instance
func _init():
	reset_board() # The controller will call model.new() when _ready()
	
## reset the board to its initial states (on datalevel), then send signal asking view to redraw
func reset_board() -> void:
	board.clear()
	for y in range (3):
		for x in range(3):
			board[Vector2i(x, y)] = ""   # empty tile
	current_player = "X"
	model_updated.emit() # view please redraw

## Given a vector2i which indicates the data at this place is changed due to a "move" from one player.
## After that, should check whether someone wins, or they got a tie(=cat wins).
## After that, it will be next player's move
## Note: it has ability to send out signal on certain conditions (win/draw detected after move)
func make_move(coord: Vector2i) -> void:
	if not board.has(coord) or board[coord] != "":
		return  # tile is invalid or already claimed, should do nothing, no need to notify view as well!

	board[coord] = current_player
	model_updated.emit()

	if check_win(current_player): # if the current player already wins(by making 3 entries in a line?)
		emit_signal("game_over", "Player took Capital " + current_player + " ")
	elif is_draw(): # if all the tiles are fulfilled and no winner..
		emit_signal("game_over", "Cat")
	else:
		toggle_player() # another player start his turn

## modifying the current player, inside this model class. It toggles from "X" or "O"		
func toggle_player() -> void:
	if current_player == "X":
		current_player = "O"
	elif current_player == "O":
		current_player = "X"
	else:
		print("Error: something wrong with toggle_player() inside model.gd")
		
## returning a boolean whcih is the current determination on whether someone already success in the game.
## Note: no signal sending out, just a function returning true/false.
func check_win(player: String) -> bool:
	# Rows
	for y in range(3):
		if board[Vector2i(0,y)] == player and board[Vector2i(1,y)] == player and board[Vector2i(2,y)] == player:
			return true
	# Columns
	for x in range(3):
		if board[Vector2i(x,0)] == player and board[Vector2i(x,1)] == player and board[Vector2i(x,2)] == player:
			return true
	# Diagonals
	if board[Vector2i(0,0)] == player and board[Vector2i(1,1)] == player and board[Vector2i(2,2)] == player:
		return true
	if board[Vector2i(2,0)] == player and board[Vector2i(1,1)] == player and board[Vector2i(0,2)] == player:
		return true
	return false	
	
## returning the true/false state on whether the board is fulfilled with "X" or "O" s.
## Mote: no signal coming out.
func is_draw() -> bool:
	for value in board.values():
		if value == "":
			return false
	return true
	



			

		
