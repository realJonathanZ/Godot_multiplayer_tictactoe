extends GutTest

var Model = preload("res://Scripts/model.gd") # preload class

var model: Model # model instance

## Happened before each test function
func before_each():
	model = Model.new()
	model.reset_board()
	
func test_initial_board_empty():
	for coord in model.board.keys():
		assert_eq(model.board[coord], "", "expected all tiles to be empty initially.")
	assert_eq(model.current_player, "X", "expected starting player to be X.")

func test_make_move_marks_tile_and_switches_player():
	var coord = Vector2i(1, 1)
	model.make_move(coord) # assume we make a move at (1,1), and the data board should be updated.
	assert_eq(model.board[coord], "X", "after first move, X should occupy tile.")
	assert_eq(model.current_player, "O", "turn should switch to O after valid move.")

func test_cannot_overwrite_tile():
	var coord = Vector2i(0, 0)
	model.make_move(coord) # X moves
	var prev_player = model.current_player
	model.make_move(coord) # O tries same spot (should be ignored)
	assert_eq(model.board[coord], "X", "tile should remain X after illegal overwrite attempt.")
	assert_eq(model.current_player, prev_player, "turn should not change after invalid move.")
	
func test_check_win():
	# simulates a win process
	model.board[Vector2i(0, 0)] = "X"
	model.board[Vector2i(1, 0)] = "X"
	model.board[Vector2i(2, 0)] = "X"
	assert_true(model.check_win("X"), "X should win on top row.")
	assert_false(model.check_win("O"), "O should not win.")
