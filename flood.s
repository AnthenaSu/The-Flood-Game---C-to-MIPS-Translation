#######################################################################################
########################## COMP1521 25T2 ASSIGNMENT 1: Flood ##########################
##                                                                                   ##
## !!! IMPORTANT !!!                                                                 ##
## Before starting work on the assignment, make sure you set your tab-width to 8!    ##
## It is also suggested to indent with tabs only.                                    ##
## Instructions to configure your text editor can be found here:                     ##
##   https://cgi.cse.unsw.edu.au/~cs1521/current/resources/mips-editors.html         ##
## !!! IMPORTANT !!!                                                                 ##
##                                                                                   ##
## This program was written by ANTHENA SU (z5640267)                                 ##
## on 21.06.2025                                                               	     ##
##                                                                                   ##
## This is the first assignment for COMP1521. This program creates flood game,       ##
## where the player fills connected regions with colours, 			     ##
## aiming to complete the board optimally while tracking progress and steps, by using mips.
## precious style mark!!      >:O                                                    ##


########################################
## CONSTANTS: REQIURED FOR GAME LOGIC ##
########################################

TRUE = 1
FALSE = 0

UP_KEY = 'w'
LEFT_KEY = 'a'
DOWN_KEY = 's'
RIGHT_KEY = 'd'

FILL_KEY = 'e'

CHEAT_KEY = 'c'
HELP_KEY = 'h'
EXIT_KEY = 'q'

COLOUR_ONE = '='
COLOUR_TWO = 'x'
COLOUR_THREE = '#'
COLOUR_FOUR = '.'
COLOUR_FIVE = '*'
COLOUR_SIX = '`'
COLOUR_SEVEN = '@'
COLOUR_EIGHT = '&'

NUM_COLOURS = 8

MIN_BOARD_WIDTH = 3
MAX_BOARD_WIDTH = 12
MIN_BOARD_HEIGHT = 3
MAX_BOARD_HEIGHT = 12

BOARD_VERTICAL_SEPERATOR = '|'
BOARD_CROSS_SEPERATOR = '+'
BOARD_HORIZONTAL_SEPERATOR = '-'
BOARD_CELL_SEPERATOR = '|'
BOARD_SPACE_SEPERATOR = ' '
BOARD_CELL_SIZE = 3

SELECTED_ARROW_VERTICAL_LENGTH = 2

GAME_STATE_PLAYING = 0
GAME_STATE_LOST = 1
GAME_STATE_WON = 2

NUM_VISIT_DELTAS = 4
VISIT_DELTA_ROW = 0
VISIT_DELTA_COL = 1

MAX_SOLUTION_STEPS = 64

NOT_VISITED = 0
VISITED = 1
ADJACENT = 2

EXTRA_STEPS = 2

#################################################
## CONSTANTS: PLEASE USE THESE FOR YOUR SANITY ##
#################################################

SIZEOF_INT = 4
SIZEOF_PTR = 4
SIZEOF_CHAR = 1

##########################################################
## struct fill_in_progress {                            ##
##     int cells_filled;                                ##
##     char visited[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT]; ##
##     char fill_with;                                  ##
##     char fill_onto;                                  ##
## };                                                   ##
##########################################################

CELLS_FILLED_OFFSET = 0
VISITED_OFFSET = CELLS_FILLED_OFFSET + SIZEOF_INT
FILL_WITH_OFFSET = VISITED_OFFSET + MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT * SIZEOF_CHAR
FILL_ONTO_OFFSET = FILL_WITH_OFFSET + SIZEOF_CHAR

SIZEOF_FILL_IN_PROGRESS = FILL_ONTO_OFFSET + SIZEOF_CHAR

############################
## struct step_rating {   ##
##     int surface_area;  ##
##     int is_eliminated; ##
## };                     ##
############################

SURFACE_AREA_OFFSET = 0
IS_ELIMINATED_OFFSET = SURFACE_AREA_OFFSET + SIZEOF_INT

STEP_RATING_ALIGNMENT = 0

SIZEOF_STEP_RATING = IS_ELIMINATED_OFFSET + SIZEOF_INT + STEP_RATING_ALIGNMENT

###################################################################
## struct solver {                                               ##
##     struct step_rating step_rating_for_colour[NUM_COLOURS];   ##
##     int solution_length;                                      ##
##     char simulated_board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT];  ##
##     char future_board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT];     ##
##     char adjacent_to_cell[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT]; ##
##     char optimal_solution[MAX_SOLUTION_STEPS];                ##
## };                                                            ##
###################################################################

STEP_RATING_FOR_COLOUR_OFFSET = 0
SOLUTION_LENGTH_OFFSET = STEP_RATING_FOR_COLOUR_OFFSET + SIZEOF_STEP_RATING * NUM_COLOURS
SIMULATED_BOARD_OFFSET = SOLUTION_LENGTH_OFFSET + SIZEOF_INT
FUTURE_BOARD_OFFSET = SIMULATED_BOARD_OFFSET + MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT * SIZEOF_CHAR
ADJACENT_TO_CELL_OFFSET = FUTURE_BOARD_OFFSET + MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT * SIZEOF_CHAR
OPTIMAL_SOLUTION_OFFSET = ADJACENT_TO_CELL_OFFSET + MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT * SIZEOF_CHAR

SIZEOF_SOLVER = OPTIMAL_SOLUTION_OFFSET + MAX_SOLUTION_STEPS * SIZEOF_CHAR

###################
## END CONSTANTS ##
###################

########################################
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
########################################

######################
## GLOBAL VARIABLES ##
######################

	.data

###############################################
## char selected_arrow_horizontal[] = "<--"; ##
###############################################

selected_arrow_horizontal:
	.asciiz "<--"

##################################################
## char selected_arrow_vertical[] = {'^', '|'}; ##
##################################################

selected_arrow_vertical:
	.ascii "^|"

################################
## char cmd_waiting[] = "> "; ##
################################

cmd_waiting:
	.asciiz "> "

############################################################
## char colour_selector[NUM_COLOURS] = {                  ##
##    COLOUR_ONE, COLOUR_TWO, COLOUR_THREE, COLOUR_FOUR,  ##
##    COLOUR_FIVE, COLOUR_SIX, COLOUR_SEVEN, COLOUR_EIGHT ##
## };                                                     ##
############################################################

colour_selector:
	.byte COLOUR_ONE, COLOUR_TWO, COLOUR_THREE, COLOUR_FOUR
	.byte COLOUR_FIVE, COLOUR_SIX, COLOUR_SEVEN, COLOUR_EIGHT

#########################################################
## char game_board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT]; ##
#########################################################

game_board:
	.align 2
	.space MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT

##################################################################
## int visit_deltas[4][2] = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}; ##
##################################################################

visit_deltas:
	.word -1, 0
	.word 1, 0
	.word 0, -1
	.word 0, 1

#######################
## int selected_row; ##
#######################

selected_row:
	.align 2
	.space 4

##########################
## int selected_column; ##
##########################

selected_column:
	.align 2
	.space 4

######################
## int board_width; ##
######################

board_width:
	.align 2
	.space 4

#######################
## int board_height; ##
#######################

board_height:
	.align 2
	.space 4

################################################
## char optimal_solution[MAX_SOLUTION_STEPS]; ##
################################################

optimal_solution:
	.align 2
	.space MAX_SOLUTION_STEPS * SIZEOF_CHAR

########################
## int optimal_steps; ##
########################

optimal_steps:
	.align 2
	.space 4

######################
## int extra_steps; ##
######################

extra_steps:
	.align 2
	.space 4

################
## int steps; ##
################

steps:
	.align 2
	.space 4


#####################
## int game_state; ##
#####################

game_state:
	.align 2
	.space 4

###############################
## unsigned int random_seed; ##
###############################

random_seed:
	.align 2
	.space 4

######################################################
## struct fill_in_progress global_fill_in_progress; ##
######################################################

global_fill_in_progress:
	.align 2
	.space SIZEOF_FILL_IN_PROGRESS

##################################
## struct solver global_solver; ##
##################################

global_solver:
	.align 2
	.space SIZEOF_SOLVER

########################################
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
########################################

##########################
## END GLOBAL VARIABLES ##
##########################

####################
## STATIC STRINGS ##
####################

########################################
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
########################################

	.data

str_print_welcome_1:
	.asciiz "Welcome to flood!\n"

str_print_welcome_2:
	.asciiz "To move your cursor up/down, use "

str_print_welcome_3:
	.asciiz "To move your cursor left/right, use "

str_print_welcome_4:
	.asciiz "To see this message again, use "

str_print_welcome_5:
	.asciiz "To perform flood fill on the grid, use "

str_print_welcome_6:
	.asciiz "To cheat and see the 'optimal' solution, use "

str_print_welcome_7:
	.asciiz "To exit, use "


str_game_loop_win:
	.asciiz "You win!\n"

str_game_loop_lose:
	.asciiz "You lose :(\n"

str_initialise_game_enter_width:
	.asciiz "Enter the grid width: "

str_initialise_game_enter_height:
	.asciiz "Enter the grid height: "

str_initialise_game_invalid_width:
	.asciiz "Invalid width!\n"

str_initialise_game_invalid_height:
	.asciiz "Invalid height!\n"

str_initialise_game_enter_seed:
	.asciiz "Enter a random seed: "

str_do_fill_filled_1:
	.asciiz "Filled "

str_do_fill_filled_2:
	.asciiz " cells!\n"

str_print_board_steps:
	.asciiz " steps\n"

str_process_command_unknown:
	.asciiz "Unknown command: "

########################################
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
## DO NOT MODIFY THE .DATA SECTION!!! ##
########################################

########################
## END STATIC STRINGS ##
########################


############################################################
####                                                    ####
####   Your journey begins here, intrepid adventurer!   ####
####                                                    ####
############################################################

##############
## SUBSET 0 ##
##############

#####################
## int main(void); ##
#####################

################################################################################
# .TEXT <main>
	.text
main:
	# Subset:   0
	#
	# Frame:    [...]   <-- FILL THESE OUT!
	# Uses:     [...]
	# Clobbers: [...]
	#
	# Locals:           <-- FILL THIS OUT!
	#   - ...
	#
	# Structure:        <-- FILL THIS OUT!
	#   main
	#   -> [prologue]
	#       -> body
	#   -> [epilogue]

main__prologue:
	push	$ra

main__body:
	jal 	print_welcome
	jal		initialise_game
	jal 	game_loop

main__epilogue:
	pop		$ra
	li	$v0, 0
	jr	$ra

###########################
## void print_welcome(); ##
###########################
# This function prints welcome messages. 
################################################################################
# .TEXT <print_welcome>
	.text
print_welcome:
	# Subset:   0
	#
	# Frame:    []                   <-- No registers are saved/restored
	# Uses:     [$a0, $v0]           
	# Clobbers: [$a0, $v0]           
	#
	# Locals:
	#   - $a0: argument to syscall (string or character)
	#   - $v0: syscall code (4 for print string, 11 for print character)
	#
	# Structure:
	#   print_welcome
	#   -> [prologue] (none)
	#       -> body
	#           -> print string instructions
	#           -> print character keys (UP_KEY, etc.)
	#   -> [epilogue]

print_welcome__prologue:

print_welcome__body:
	li	$v0, 4
	la	$a0, str_print_welcome_1	# printf("Welcome to flood!\n");
	syscall 

	li	$v0, 4				# printf("To move your cursor up/down, use )
	la	$a0, str_print_welcome_2
	syscall 

	li	$v0, 11				# print char
	la	$a0, UP_KEY
	syscall 

	li	$v0, 11
	la	$a0, '/'
	syscall 

	li	$v0, 11
	la	$a0, DOWN_KEY
	syscall 

	li	$v0, 11
	la	$a0, '\n'
	syscall 

	li	$v0, 4				# print string
	la	$a0, str_print_welcome_3	# printf("To move your cursor left/right, use)
	syscall 

	li	$v0, 11
	la	$a0, LEFT_KEY
	syscall 

	li	$v0, 11
	la	$a0, '/'
	syscall 

	li	$v0, 11
	la	$a0, RIGHT_KEY
	syscall 

	li	$v0, 11
	la	$a0, '\n'
	syscall 

	li	$v0, 4
	la	$a0, str_print_welcome_4	# printf("To see this message again, use 
	syscall 

	li	$v0, 11
	la	$a0, HELP_KEY
	syscall

	li	$v0, 11
	la	$a0, '\n'
	syscall 

	li	$v0, 4
	la	$a0, str_print_welcome_5	# printf("To perform flood fill on the grid, use)
	syscall 

	li	$v0, 11
	la	$a0, FILL_KEY
	syscall

	li	$v0, 11
	la	$a0, '\n'
	syscall 

	li	$v0, 4
	la	$a0, str_print_welcome_6	# printf("To cheat and see the 'optimal' solution)
	syscall 

	li	$v0, 11
	la	$a0, CHEAT_KEY
	syscall

	li	$v0, 11
	la	$a0, '\n'
	syscall 

		li	$v0, 4
	la	$a0, str_print_welcome_7	# printf("To exit, use %c\n"
	syscall 

	li	$v0, 11
	la	$a0, EXIT_KEY
	syscall

	li	$v0, 11
	la	$a0, '\n'
	syscall 

print_welcome__epilogue:
	jr	$ra

##############
## SUBSET 1 ##
##############

#########################################################
## int in_bounds(int value, int minimum, int maximum); ##
#########################################################
# This function checks if the value is in the range (max and min).
################################################################################
# .TEXT <in_bounds>
	.text
in_bounds:
	# Subset:   1
	#
	# Frame:    [$ra]               <-- Only $ra is pushed/popped
	# Uses:     [$a0, $a1, $a2, $v0] <-- Argument and return registers
	# Clobbers: [$v0]               <-- Return value is overwritten
	#
	# Locals:
	#   - $a0: int value
	#   - $a1: int minimum
	#   - $a2: int maximum
	#   - $v0: return value (0 = out of bounds, 1 = in bounds)
	#
	# Structure:
	#   in_bounds
	#   -> [prologue]
	#       -> [body]
	#           -> compare against minimum
	#           -> compare against maximum
	#           -> set return value accordingly
	#   -> [epilogue]

in_bounds__prologue:
	push 	$ra

in_bounds__body:
	blt  	$a0, $a1, in_bounds__return0	# value < minimum
	bgt  	$a0, $a2, in_bounds__return0	# value > minimum
	j 	in_bounds__return1

in_bounds__return0:
	li	$v0, 0
	j	in_bounds__epilogue

in_bounds__return1:
	li	$v0, 1				# return 1
	j	in_bounds__epilogue

in_bounds__epilogue:
	pop 	$ra
	jr	$ra 

#######################
## void game_loop(); ##
#######################
# This function processes the game loop until win / lose.
################################################################################
# .TEXT <game_loop>
	.text
game_loop:
	# Subset:   1
	#
	# Frame:    no
	# Uses:     [$a0, $t1, $v0]
	# Clobbers: [$ra]
	#
	# Locals:           
	#   - $a0:  address of gam_board
	#   - $t0:  address of game_state
	#   - $t1:  int game_state
	#
	# Structure:       
	#   game_loop
	#   -> [prologue]
	#       -> body
	#       	-> print board
	#       	-> game_loop__while_cond
	#       		-> process_command
	#       	-> game_loop__if_statement
	#       		-> if won
	#       		-> if lost
	#   -> [epilogue]

game_loop__prologue:
	push 	$ra
	
game_loop__body:
	la	$a0, game_board
	jal	print_board		# print_board(game_board)
	
game_loop__while_cond:
	la 	$t0, game_state		# load address of gamestate 
	lw	$t1, 0($t0)		# load int gamestate
	bne	$t1, GAME_STATE_PLAYING, game_loop__if_statement
	j       game_loop__while_body

game_loop__while_body:
	jal	process_command
	j	game_loop__while_cond

game_loop__if_statement: 	
	# game_state == GAME_STATE_WON
	beq	$t1, GAME_STATE_WON, game_loop__win
	# game_state == GAME_STATE_LOST	
	beq	$t1, GAME_STATE_LOST, game_loop__lost

game_loop__win:
	# print string
	li	$v0, 4			
	la	$a0, str_game_loop_win
	syscall
	j 	game_loop__epilogue	

game_loop__lost:
	# print string
	li	$v0, 4			
	la	$a0, str_game_loop_lose			
	syscall
	j 	game_loop__epilogue	

game_loop__epilogue:
	pop 	$ra
	jr	$ra

#############################
## void initialise_game(); ##
#############################
# This function prompts user to initalize the game board.
################################################################################
# .TEXT <initialise_game>
	.text
initialise_game:
	# Subset:   1
	#
	# Frame:    [$ra]
	# Uses:     $a0-$a2, $v0, $t0-$t9
	# Clobbers: $a0-$a2, $v0, $t0-$t9
	#
	# Locals:
	#   - $t0: loop control flag (continue), general temp
	#   - $t1: user_width
	#   - $t2: address of board_width
	#   - $t3: user_height
	#   - $t4: address of board_height
	#   - $t5: user_random_seed
	#   - $t6: address of random_seed / extra_steps
	#   - $t7: address of selected_row / extra_steps
	#   - $t8: address of selected_column / game_state
	#   - $t9: address of steps
	#
	# Structure:
	#   initialise_game
	#   -> [prologue]
	#       -> saves $ra
	#   -> [body]
	#       -> prompts user for board width and height in a loop
	#       -> validates dimensions using in_bounds()
	#       -> handles invalid input with error messages
	#       -> prompts for random seed
	#       -> initializes global variables
	#       -> calls initialise_board and find_optimal_solution
	#   -> [epilogue]
	#       -> restores $ra and returns

initialise_game__prologue:
	push 	$ra

initialise_game__body:
	li	$t0, 1				# int continue = 1 
	j	initialise_game__while_cond

initialise_game__while_cond:
	# if continue != 1 -> leave while loop
	bne 	$t0, 1, initialise_game__while_end	
	j 	initialise_game__while_body	# jump into the loop

initialise_game__while_body:
	li	$v0, 4
	la  	$a0, str_initialise_game_enter_width
	syscall 				# printf("Enter the grid width: ")
	
	li  	$v0, 5
	syscall 
	move 	$t1, $v0			# scanf(" %d", &user_width)

	la   	$t2, board_width		# load address of board_height
	sw   	$t1, 0($t2) 			# board_height = user_height
	
	move 	$a0, $t1
	li 	$a1, MIN_BOARD_WIDTH
	li	$a2, MAX_BOARD_WIDTH		# passing arguments 
	jal  	in_bounds

	# invalid
	bne	$v0, 1, initialise_game__if_invalid_width 
	
	# width is valid, now check height
	li	$v0, 4
	la  	$a0, str_initialise_game_enter_height
	syscall 				# printf("Enter the grid height: ")
	
	li  	$v0, 5
	syscall 
	move 	$t3, $v0			# scanf(" %d", &user_height)
	
	la   	$t4, board_height					
	sw   	$t3, 0($t4)			# board_height = user_height

	move 	$a0, $t3
	la 	$a1, MIN_BOARD_HEIGHT
	la	$a2, MAX_BOARD_HEIGHT		# passing arguments 
	jal  	in_bounds

	# invalid
	bne	$v0, 1, initialise_game__if_invalid_height 

	# both are OKAY -> end the while loop
	li	$t0, 1				# break
	j 	initialise_game__while_end

initialise_game__if_invalid_width:
	li	$v0, 4
	la  	$a0, str_initialise_game_invalid_width
	syscall 
	li	$t0, 1			       	# continue = 1
	j 	initialise_game__while_body    	# jump back to head of the loop

initialise_game__if_invalid_height:
	li	$v0, 4
	la  	$a0, str_initialise_game_invalid_height
	syscall 
	li	$t0, 1			       	# continue = 1
	j 	initialise_game__while_body    	# jump back to head of the loop

initialise_game__while_end:

initialise_game__seed:
	li 	$v0, 4
	la  	$a0, str_initialise_game_enter_seed
	syscall 			      	# printf("Enter a random seed: ");

	li 	$v0, 5
	syscall 
	move 	$t5, $v0			# scan user_random_seed

	la  	$t6, random_seed	
	sw  	$t5, 0($t6)			# store user_random_seed into random_seed

	li 	$t0, 0
	la  	$t7, selected_row
	sw  	$t0,  0($t7)			# selected_row = 0

	la  	$t8, selected_column
	sw  	$t0,  0($t8)			# selected_column = 0

	la  	$t9, steps
	sw  	$t0,  0($t9)			# steps = 0

	la  	$t6, extra_steps	
	sw  	$t0,  0($t6)			

	li  	$t0, EXTRA_STEPS
	la  	$t7, extra_steps
	sw  	$t0,  0($t7)			# extra_steps = EXTRA_STEPS

	li  	$t0, GAME_STATE_PLAYING
	la  	$t8, game_state
	sw  	$t0,  0($t8)			# game_state = GAME_STATE_PLAYING

	jal 	initialise_board		
	jal	find_optimal_solution

initialise_game__epilogue:
	pop 	$ra
	jr	$ra

#######################################################################
## int game_finished(char board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT]); ##
#######################################################################
# This function checks whether all cells on the board are the same colour, 
# indicating the game is finished.
################################################################################
# .TEXT <game_finished>
	.text
game_finished:
	# Subset:   1
	#
	# Frame:    [$ra]             
	# Uses:     $t0-$t7           
	# Clobbers: $t0-$t7           
	#
	# Locals:           <-- FILL THIS OUT!
	#   - $t0: expected_colour base address 
	#   - $t1: int row
	#   - $t2: int col
	#   - $t3: address of board[row][col]
	#   - $t4: board_height
	# 	- $t5: board_width
	#   - $t6: value of board[row][col]
	#   - $t7: value of board[0][0]
	#
	# Structure:        <-- FILL THIS OUT!
	#   game_finished
	#   -> [prologue]
	#       -> body 
#			-> [game_finished__loop_1_cond]
#			-> [game_finished__loop_2_cond]
#				-> get board[row][col]
#				-> compare board[row][col] and expected_colour
#					-> return false (if not equal)
#  			-> [game_finished__loop_1_step]
	#           -> [game_finished__loop_2_step]
	#       -> return true 
	#   -> [epilogue]

game_finished__prologue:
    	push 	$ra

game_finished__body:
	la   	$t0, game_board        		# $t0 = base address of board
	lw   	$t4, board_height      		# $t4 = board_height
	lw   	$t5, board_width       		# $t5 = board_width

	li   	$t1, 0                 		# int row = 0

game_finished__loop_1_cond:
	bge  	$t1, $t4, game_finished__return_true

	li   	$t2, 0                 		# int col = 0

game_finished__loop_2_cond:
	bge  	$t2, $t5, game_finished__loop_1_step

	# calculate index = row * width + col
	mul  	$t3, $t1, MAX_BOARD_WIDTH       # t3 = row * MAXwidth
	add  	$t3, $t3, $t2          		# t3 = index
	add  	$t3, $t3, $t0          		# address = base + index

	lb   	$t6, 0($t3)            		# current value
	lb   	$t7, 0($t0)            		# expected_colour = board[0][0]

	bne  	$t6, $t7, game_finished__return_false

	add  	$t2, $t2, 1             	# col++
	j    	game_finished__loop_2_cond

game_finished__loop_1_step:
	add  	$t1, $t1, 1            		# row++
	j    	game_finished__loop_1_cond

game_finished__return_false:
	li   	$v0, 0
	j    	game_finished__epilogue

game_finished__return_true:
    	li   	$v0, 1

game_finished__epilogue:
	pop  	$ra
	jr   	$ra

#####################
## void do_fill(); ##
#####################
# This function performs a fill operation from the top-left cell, 
# updates the game state, and prints the number of filled cells.
################################################################################
# .TEXT <do_fill>
	.text
do_fill:
	# Subset:   1
	#
	# Frame:    [$ra, $s0, $s1]
	# Uses:     $a0-$a3, $v0, $t1-$t9, $s0, $s1
	# Clobbers: $a0-$a3, $v0, $t1-$t9
	#
	# Locals:
	#   - $s0: base address of game_board
	#   - $s1: preserved copy of $a0 (global_fill_in_progress)
	#   - $t1: selected_row
	#   - $t2: selected_column / game_state address (reused)
	#   - $t3: board offset (row * width + col)
	#   - $t4: game_board[selected_row][selected_column]
	#   - $t5: game_board[0][0] / optimal_steps address (reused)
	#   - $t6: global_fill_in_progress address / optimal_steps value
	#   - $t7: cells_filled / extra_steps address or value
	#   - $t8: steps address / optimal + extra
	#   - $t9: steps value
	#
	# Structure:
	#   do_fill
	#   -> [prologue]
	#       -> saves $ra, $s0, $s1
	#   -> [body]
	#       -> computes board cell values
	#       -> calls initialise_fill_in_progress
	#       -> calls fill
	#       -> prints number of filled cells
	#       -> increments steps
	#       -> checks for win (game_finished)
	#       -> checks for loss (steps > optimal + extra)
	#   -> [epilogue]
	#       -> restores $s1, $s0, $ra and returns

do_fill__prologue:
	push 	$ra 
	push 	$s0 
	push 	$s1

do_fill__body:
	la 	$a0, global_fill_in_progress    # address of global_fill_in_progress
	
	la 	$s0, game_board			# base address of board
	lw 	$t1, selected_row
	lw 	$t2, selected_column

	mul 	$t3, $t1, MAX_BOARD_WIDTH	# row & MAXwidth
	add 	$t3, $t3, $t2
	add 	$t3, $t3, $s0			# add base address

	lb  	$t4, 0($t3) 			# game_board[selected_row][selected_column]
	move  	$a1, $t4

	lb  	$t5, 0($s0)
	move  	$a2, $t5			# value of game_board[0][0]
	
	move 	$s1, $a0 
	jal 	initialise_fill_in_progress
	move 	$a0, $s1 

	# arguments: 
	move 	$a1, $s0			# &global_fill_in_progress
	li 	$a2, 0
	li 	$a3, 0
	jal  	fill

	li 	$v0, 4				# print string
	la 	$a0, str_do_fill_filled_1
	syscall 

	li 	$t6, global_fill_in_progress	# base address
	lw 	$t7, 0($t6)			# global_fill_in_progress.cells_filled

	li 	$v0, 1
	move 	$a0, $t7 			# print global_fill_in_progress.cells_filled
	syscall 

	li 	$v0, 4
	la 	$a0, str_do_fill_filled_2
	syscall 

	la	$t8, steps			# load address of steps 
	lw  	$t9, 0($t8)			# load value of steps 
	add 	$t9, $t9, 1			# steps ++ 
	sw  	$t9, 0($t8)			# store back to steps

do_fill__if_statement_1_cond:
	la  	$a0, game_board
	jal 	game_finished

	beq 	$v0, 1, do_fill__if_statement_1_body
	j 	do_fill__if_statement_2_cond

do_fill__if_statement_1_body: 
	la 	$t2, game_state			# load address of gamestate 
	li      $t3, GAME_STATE_WON
	sw	$t3, 0($t2)			# game_state = GAME_STATE_WON

do_fill__if_statement_2_cond:

	la  	$t5, optimal_steps		# load address of optimal_steps
	lw  	$t6, 0($t5)			# value of optimal_steps

	la  	$t7, extra_steps		# load address of extra_steps
	lw  	$t7, 0($t7)			# value of extra_steps

	add 	$t8, $t6, $t7		  	# ptimal_steps + extra_steps

	la	$t4, steps			# load address of steps 
	lw  	$t9, 0($t4)			# load value of steps 
	ble  	$t9, $t8, do_fill__epilogue

do_fill__if_statement_2_body:
	la 	$t2, game_state			# load address of gamestate 
	li      $t3, GAME_STATE_LOST
	sw	$t3, 0($t2)			# game_state = GAME_STATE_WON

do_fill__epilogue:
	pop 	$s1
	pop 	$s0
	pop 	$ra
	jr	$ra

##############
## SUBSET 2 ##
##############

########################################################################
## void initialise_fill_in_progress(struct fill_in_progress *init_me, ## 
##     char fill_with, char fill_onto);                               ##
########################################################################
# This function initialises by setting fill parameters, resetting the filled cell count, 
# and marking non-visited cells.
################################################################################
# .TEXT <initialise_fill_in_progress>
	.text
initialise_fill_in_progress:
	# Subset:   2
	#
	# Frame:    [$ra, $s0, $s1, $s2]  
	# Uses:     $a0, $a1, $a2 (args)
	# Clobbers: $t0-$t9, $s0-$s2, $ra
	#
	# Locals:           
	#   - $s0: pointer to struct fill_in_progress (init_me)
	#   - $s1: constant MAX_BOARD_WIDTH
	#   - $s2: (could be used for MAX_BOARD_HEIGHT, though not used here)
	#   - $t1: fill_with
	#   - $t2: fill_onto
	#   - $t3: temp for struct offset
	#   - $t4: row
	#   - $t5: col / offset pointer
	#   - $t6: board_height
	#   - $t7: board_width
	#   - $t8: linear offset into visited[][]
	#   - $t9: address of visited[row][col]

	# Structure:        
	#   initialise_fill_in_progress
	#   -> [prologue]
	#       -> body
	#           -> loop_init
	#               -> loop1_cond
	#                   -> loop2_cond
	#                       -> loop2_body
	#                       -> loop2_step
	#                   -> next_loop
	#       -> epilogue

initialise_fill_in_progress__prologue:
	push 	$ra
	push 	$s0
	push 	$s1
	push 	$s2

initialise_fill_in_progress__body:
	move 	$s0, $a0 		# address of fill_in_progress *init_me
	move	$t1, $a1		# char fill_with
	move 	$t2, $a2		# char fill_onto

	li   	$t3, MAX_BOARD_WIDTH
	li   	$t4, MAX_BOARD_HEIGHT
	mul  	$t3, $t3, $t4        	# t3 = MAX_Width * MAX_Height
	addi 	$t3, $t3, 4          	# offset = 4 + visited
	add  	$t5, $s0, $t3
	sb   	$t1, 0($t5)          	# init_me->fill_with = fill_with
	
	addi 	$t5, $t5, 1
    	sb   	$t2, 0($t5)          	# init_me->fill_onto = fill_onto
	
	sw   	$zero, 0($s0)		# init_me->cells_filled = 0

initialise_fill_in_progress__loop_init: 
	li   	$t4, 0			# row = 0
	li   	$t5, 0			# col = 0
	lw   	$t6, board_height	# get board_height
	lw   	$t7, board_width	# get board_width

initialise_fill_in_progress__loop1_cond:
	bge  	$t4, $t6, initialise_fill_in_progress__epilogue
	li   	$t5, 0			# col = 0

initialise_fill_in_progress__loop2_cond:
	bge  	$t5, $t7, initialise_fill_in_progress__next_loop
	
initialise_fill_in_progress__loop2_body:
	# (row * MAXwidth + col) * size + base
	li 	$s1, MAX_BOARD_WIDTH
	mul  	$t8, $t4, $s1
	add  	$t8, $t8, $t5
	add  	$t8, $t8, 4		# base address of init_me->visited[row][col]
	add  	$t9, $s0, $t8

	li   	$t0, NOT_VISITED
	sb   	$t0, 0($t9)

	j 	initialise_fill_in_progress__loop2_step

initialise_fill_in_progress__loop2_step:
	add  	$t5, $t5, 1		# col ++
	j    	initialise_fill_in_progress__loop2_cond

initialise_fill_in_progress__next_loop: 
	add  	$t4, $t4, 1		# row ++
	j 	initialise_fill_in_progress__loop1_cond

initialise_fill_in_progress__epilogue:
	pop 	$s2
	pop 	$s1
	pop 	$s0
	pop 	$ra
	jr	$ra

##############################
## void initialise_board(); ##
##############################
# This function initialized the board. 
################################################################################
# .TEXT <initialise_board>
	.text
initialise_board:
	# Subset:   2
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3, $s4]  
	# Uses:     $a0, $a1, $v0 (for random_in_range)
	# Clobbers: $t4, $t7, $t8, $t9
	#
	# Locals:
	#   - $s0: MAX_BOARD_HEIGHT
	#   - $s1: MAX_BOARD_WIDTH
	#   - $s2: col
	#   - $s3: row
	#   - $s4: NUM_COLOURS
	#   - $t4: colour_selector[colour_selector_index]
	#   - $t7: base address of colour_selector
	#   - $t8: base address of game_board
	#   - $t9: address of game_board[row][col]
	#
	# Structure:
	#   initialise_board
	#   -> [prologue]
	#       -> body
	#           -> body_init
	#           -> loop_row_cond
	#               -> loop_col_cond
	#                   -> loop_col_body
	#               -> loop_row_step
	#   -> [epilogue]

initialise_board__prologue:
	push 	$ra
	push 	$s0
	push 	$s1
	push 	$s2
	push 	$s3
	push 	$s4
initialise_board__body:

initialise_board__body_init:
	li  	$s3, 0			# int row = 0
	li  	$s0, MAX_BOARD_HEIGHT
	li  	$s1, MAX_BOARD_WIDTH
	li  	$s4, NUM_COLOURS

initialise_board__loop_row_cond:
	bge 	$s3, $s0, initialise_board__epilogue
	li  	$s2, 0			# int col = 0

initialise_board__loop_col_cond:
	bge 	$s2, $s1, initialise_board__loop_row_step

initialise_board__loop_col_body:

	li  	$a0, 0
	add 	$a1, $s4, -1		# NUM_COLOURS - 1
	jal 	random_in_range

	# colour_selector_index (t4) = random_in_range(0, NUM_COLOURS - 1)
	move  	$t4, $v0 	

	# game_board[row][col]
	la  	$t8, game_board		# base address of game_board
	mul 	$t9, $s3, $s1		# row * MAXwidth
	add 	$t9, $t9, $s2 		# + col 
	add 	$t9, $t9, $t8      	# base address of game_board[row][col]

	la  	$t7, colour_selector   	# base address of colour_selector
	add 	$t4, $t4, $t7          	# address of colour_selector[colour_selector_index]
	lb  	$t4, 0($t4)		# colour_selector[colour_selector_index]

	# game_board[row][col] = colour_selector[colour_selector_index]
	sb  	$t4, 0($t9)		

	add 	$s2, $s2, 1            	# col ++
	j   	initialise_board__loop_col_cond

initialise_board__loop_row_step:
	add 	$s3, $s3, 1             # row ++
	j   	initialise_board__loop_row_cond

initialise_board__epilogue:	
	pop 	$s4
	pop 	$s3
	pop 	$s2
	pop 	$s1
	pop 	$s0
	pop 	$ra
	jr	$ra

###################################
## void find_optimal_solution(); ##
###################################
# This function computes the optimal steps by simulating moves until the board is filled.
################################################################################
# .TEXT <find_optimal_solution>
	.text
find_optimal_solution:
	# Subset:   2
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3]
	# Uses:     $a0, $a1, $a2, $t1, $t3, $t4, $t5, $v0
	# Clobbers: $a0, $a1, $a2, $t1, $t3, $t4, $t5, $v0
	#
	# Locals:
	#   - $s0: base address of global_solver
	#   - $s1: MAX_BOARD_HEIGHT
	#   - $s2: MAX_BOARD_WIDTH
	#   - $s3: used for intermediate values (board size, solution_length)
	#
	# Structure:
	#   find_optimal_solution
	#   -> [prologue]                  
	#       -> body_1                  # initialise_solver
	#       -> while loop
	#            -> init condition     # compute board size & call game_finished
	#            -> body               # call solve_next_step
	#       -> body_2                  # copy optimal_solution and store result
	#   -> [epilogue]                  # restore registers and return

find_optimal_solution__prologue:
	push 	$ra
	push 	$s0
	push 	$s1
	push 	$s2
	push 	$s3

find_optimal_solution__body_1:
	la  	$a0, global_solver	# address of global_solver
	jal 	initialise_solver

find_optimal_solution_while_init:
	li  	$s1, MAX_BOARD_HEIGHT
	li  	$s2, MAX_BOARD_WIDTH
	mul 	$s3, $s1, $s2		# MAX_BOARD_HEIGHT * MAX_BOARD_WIDTH

	la  	$a0, global_solver    	# $s0 = &global_solver
	
	li  	$t1, 68 		# Offset for step_rating_for_colour 			
	add  	$a0, $a0, $t1         	# Add the offset to get the address of simulated_board
	jal  	game_finished		# Call game_finished(global_solver.simulated_board)

find_optimal_solution_while_cond:
	beq 	$v0, 1, find_optimal_solution__body_2    # end the loop

find_optimal_solution_while_body: 
	la  	$a0, global_solver	# address of global_solver
	jal 	solve_next_step
	j   	find_optimal_solution_while_init

find_optimal_solution__body_2: 
	la   	$s0, global_solver	# address of global_solver
	li   	$t1, 500                # Offset of optimal_solution from global_solver
	add  	$a0, $s0, $t1           # $a0 = &global_solver.optimal_solution

	la  	$a1, optimal_solution
	
	li  	$t1, 64                 # Load the offset for solution_length 
	add 	$t3, $s0, $t1           # Add offset to the base address of global_solver
	lw  	$a2, 0($t3)             # Load the value of global_solver.solution_length   
	jal 	copy_mem

	la  	$s0, global_solver	# address of global_solver
	la  	$t4, optimal_solution   # Load the address of optimal_solution
	lw  	$s3, 64($s0)            # Load global_solver.solution_length into $s3
	add 	$t4, $t4, $s3           # Add base address of optimal_solution
	sb  	$zero, ($t4)            # = '\0'

	lw  	$s3, 64($s0)            # Load global_solver.solution_length into $s3
	la  	$t5, optimal_steps      # Load address of optimal_steps
	sw  	$s3, 0($t5)             # Store the solution length in optimal_steps
	
find_optimal_solution__epilogue:
	pop 	$s3
	pop 	$s2
	pop 	$s1
	pop 	$s0
	pop 	$ra
	jr	$ra

################################################################
## int invalid_step(struct solver *solver, int colour_index); ##
################################################################
# This function checks if the steps are valid or not.
################################################################################
# .TEXT <invalid_step>
	.text
invalid_step:
	# Subset:   2
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3, $s4, $s5]
	# Uses:     [$a0, $a1, $a2, $t0, $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9]
	# Clobbers: [$a0, $a1, $a2, $t0-$t9, $v0]
	#
	# Locals:
	#   - $s0: struct solver* 
	#   - $s1: base address of colour_selector[]
	#   - $s2: found 
	#   - $s3: int row
	#   - $s4: int col
	#   - $s5: int colour_index
	#
	# Structure:
	#   invalid_step
	#   -> [prologue]
	#       -> body
	#           -> check simulated_board[0][0] == colour
	#           -> initialise_adjacent_cells + find_adjacent_cells
	#           -> nested loop to check valid adjacent cell match
	#       -> set return value
	#   -> [epilogue]

invalid_step__prologue:
	push 	$ra
	push 	$s0
	push 	$s1
	push 	$s2
	push 	$s3
	push 	$s4
	push 	$s5

invalid_step__body: 

	move 	$s0, $a0 			# *solver
	lb   	$t0, 68($s0)			# get solver->simulated_board[0][0]

	move 	$s5, $a1       			# s5 stors colour_index
	la   	$s1, colour_selector
	add  	$t1, $a1, $s1  			# address of colour_selector[colour_index]
	lb   	$t2, 0($t1)   			# value of colour_selector[colour_index]

	beq  	$t0, $t2, invalid_step__true    # return true if invalid

	move 	$a0, $s0     			# solver
	jal  	initialise_solver_adjacent_cells	
	
	move 	$a0, $s0 
	li   	$a1, 0
	li   	$a2, 0
	jal  	find_adjacent_cells		# find_adjacent_cells(solver, 0, 0);

	li   	$s2, 0        			# int found = FALSE

invalid_step__loop_row_init: 
	li   	$s3, 0       			# int row = 0

invalid_step__loop_row_cond: 
	lw   	$t3, board_height	
	# row >= board_height -> leave for loop
	bge  	$s3, $t3, invalid_step__if_statement    

invalid_step__loop_col_init: 
	li   	$s4, 0        			# int col = 0

invalid_step__loop_col_cond: 
	lw   	$t4, board_width
	bge  	$s4, $t4, invalid_step__loop_row_step

invalid_step__loop_col_body: 

	mul  	$t5, $s3, MAX_BOARD_WIDTH  # row * MAX_BOARD_WIDTH
	add  	$t5, $t5, $s4              # row * MAX_BOARD_WIDTH + col
	add  	$t5, $t5, 68               # base address for solver->simulated_board
	add  	$t5, $t5, $s0              # final address
	lb   	$t9, 0($t5)                # value of solver->simulated_board[row][col]
    
	la   	$s1, colour_selector
	add  	$t1, $s5, $s1  		   # address of colour_selector[colour_index]
	lb   	$t2, 0($t1)    		   # value of colour_selector[colour_index]

	bne  	$t9, $t2, invalid_step__loop_col_step

	mul  	$t6, $s3, MAX_BOARD_WIDTH  # row * MAX_BOARD_WIDTH
	add  	$t6, $t6, $s4              # + col
	add  	$t6, $t6, 356              # offset for adjacent_to_cell
	add  	$t6, $t6, $s0              # full address = base + offset
	lb   	$t8, 0($t6)                # load value of adjacent_to_cell[row][col]

	li   	$t7, ADJACENT  
	bne  	$t7, $t8, invalid_step__loop_col_step

	# two parts are true -> return TRUE
	li   	$s2, 1       		     # found = TRUE


invalid_step__loop_row_step: 
	add  	$s3, $s3, 1   		      # row ++ 
	j    	invalid_step__loop_row_cond

invalid_step__loop_col_step: 
	add  	$s4, $s4, 1   		      # col ++ 
	j    	invalid_step__loop_col_cond

invalid_step__if_statement:
	beq  	$s2, 1, invalid_step__false   # If found, return FALSE
	j    	invalid_step__true            # Otherwise, return TRUE

invalid_step__true: 
	li  	$v0, 1
	j   	invalid_step__epilogue

invalid_step__false: 
	li  	$v0, 0
	j   	invalid_step__epilogue

invalid_step__epilogue:
	pop 	$s5
	pop 	$s4
	pop 	$s3
	pop 	$s2
	pop 	$s1
	pop 	$s0
	pop 	$ra
	jr	$ra

####################################
## void print_optimal_solution(); ##
####################################
# This function prints the optimal solution steps with commas, 
# and visually indicates the player's current progress with a `^`.
################################################################################
# .TEXT <print_optimal_solution>
	.text
print_optimal_solution:
	# Subset:   2
    #
    # Frame:    [$ra, $s0, $s1, $s2, $s3, $s4]
    # Uses:     $a0, $a1, $v0, $t1, $t2, $t3, $t4, $t5
    # Clobbers: $a0, $a1, $s0, $s1, $s2, $s3, $s4, $v0
    #
    # Locals:
    #   - $s0: pointer to the string
    #   - $s1: char value of *s
    #   - $s2: optimal_steps
    #   - $s3: steps 
    #
    # Structure:
    #   print_optimal_solution
    #   -> [prologue]                  # save registers
    #       -> body_1                  # process and print optimal_solution string
    #       -> body_2                  # handle printing steps and caret '^' logic
    #   -> [epilogue]                  # restore registers and return
print_optimal_solution__prologue:    
	push 	$ra
	push 	$s0
	push 	$s1
	push 	$s2
	push 	$s3
	push 	$s4

print_optimal_solution__body_1:
    	la  	$s0, optimal_solution    # char *s = optimal_solution

print_optimal_solution__while_cond: 
	lb  	$s1, 0($s0)         	 # Load *s
	beqz 	$s1, print_optimal_solution__body_2   # If *s == '\0', exit loop 

print_optimal_solution__while_body: 
	move  	$a0, $s1
	li    	$v0, 11           # putchar(*s)
	syscall 

	addi  	$s0, $s0, 1       # s++

	lb  	$s1, 0($s0)         # Check next character
	beqz 	$s1, print_optimal_solution__putchar_second  # If next char is null, print newline
	j   	print_optimal_solution__putchar_first       

print_optimal_solution__putchar_first:
	li  	$a0, ','           # Print comma
	li   	$v0, 11
	syscall

	li  	$a0, ' '           # Print space
	li  	$v0, 11
	syscall

	j   	print_optimal_solution__while_cond

print_optimal_solution__putchar_second:
	li   	$a0, '\n'          # Print newline
	li   	$v0, 11
	syscall
	j   	print_optimal_solution__body_2

print_optimal_solution__body_2: 
	la   	$s0, optimal_solution    # Reset s = optimal_solution
	li   	$s3, 0                   # int i = 0

print_optimal_solution__if_1_cond: 
	lw  	$t1, steps               # Load value of steps
	lw  	$t2, optimal_steps
	bgt  	$t1, $t2, print_optimal_solution__if_1_body  # if (steps > optimal_steps)

print_optimal_solution__while_2_cond: 
	lb   	$s1, 0($s0)         # Load *s
	beqz 	$s1, print_optimal_solution__epilogue    # If end of string, exit loop

print_optimal_solution__putchar_if_cond: 
	beq  	$s3, $t1, print_optimal_solution__putchar_1   # if (i == steps) 
	j    	print_optimal_solution__putchar_2

print_optimal_solution__putchar_1:
	li   	$a0, '^'            # Print caret '^' at step
	syscall 

	li   	$a0, ' '          
	syscall 

	li   	$a0, ' '           
	syscall 

	j    	print_optimal_solution__while_2_body

print_optimal_solution__putchar_2:
	li   	$a0, ' '            # Print space
	syscall 

	li   	$a0, ' '            # Print space
	syscall 

	li   	$a0, ' '            # Print space
	syscall 

	j    	print_optimal_solution__while_2_body

print_optimal_solution__while_2_body: 
	addi  	$s0, $s0, 1        # s++
	addi  	$s3, $s3, 1        # i++

	lb   	$s1, 0($s0)         # Load *s
	bne  	$s1, 0, print_optimal_solution__while_2_cond  # Continue loop

	li   	$a0, 10             # newline ('\n')
	li   	$v0, 11
	syscall

	j    	print_optimal_solution__while_2_cond

print_optimal_solution__if_1_body:
	li   $a0, 10             # ASCII code for newline ('\n')
	li   $v0, 11
	syscall

	j    	print_optimal_solution__epilogue

print_optimal_solution__epilogue:
	pop 	$s4
	pop 	$s3
	pop 	$s2
	pop 	$s1
	pop	$s0
	pop 	$ra
	jr   	$ra
##############
## SUBSET 3 ##
##############

################################################################
## void rate_choice(struct solver *solver, int colour_index); ##
################################################################
# This function rates a colour choice by checking if it would eliminate the colour and counting how many adjacent cells would be filled.
################################################################################
# .TEXT <rate_choice>
	.text
rate_choice:
	# Subset:   3
	#
	# Frame:    [$ra, $s0-$s5] saved on stack
	# Uses:     $a0, $a1, $t0-$t7, $s0-$s5
	# Clobbers: $t0-$t7
	#
	# Locals:
	#   - $s0: pointer to struct solver
	#   - $s1: colour_index
	#   - $s2: pointer to step_rating_for_colour[colour_index]
	#   - $s3: seen flag (0 or 1)
	#   - $s4: row index
	#   - $s5: column index
	#   - $t0: temp for boolean, constants
	#   - $t1-$t7: temporaries for memory access and computation
	#
	# Structure:
	#   rate_choice
	#   -> [prologue]
	#       -> save callee-saved registers and move args
	#   -> [body]
	#       -> initialize step_rating_for_colour fields
	#       -> loop over board: check simulated_board and adjacent_to_cell
	#       -> track if colour was seen and surface area
	#       -> set is_eliminated = FALSE if necessary
	#   -> [epilogue]
	#       -> restore registers and return


rate_choice__prologue:
	push $ra
	push $s0
	push $s1
	push $s2
	push $s3
	push $s4
	push $s5

rate_choice__body:
	# save arguments
	move	$s0, $a0		# s0 = *solver
	move	$s1, $a1 		# s1 = colour_index

	mul	$s2, $s1, 8 		# step_rating_for_colour[colour_index]
	add	$t1, $s2, $s0	      	# + base address (solver)

	li	$t0, 1
	sw	$t0, 4($t1)	      	# = TRUE	

	sw	$zero, 0($t1)	      	# surface_area = 0 

	li	$s3, 0			# int seen = FALSE

rate_choice__row_init:
	li	$s4, 0			# int row = 0

rate_choice__row_cond:
	lw	$t1, board_height	# get board_height
	bge	$s4, $t1, rate_choice__if_seen
	j	rate_choice__col_init

rate_choice__col_init:
	li	$s5, 0			# int col = 0

rate_choice__col_cond:
	lw	$t2, board_width	# get borad_width
	bge	$s5, $t2, rate_choice__row_step

rate_choice__col_body:
	j	rate_choice__if_colour_index

rate_choice__col_step:
	addi	$s5, $s5, 1		# col ++
	j	rate_choice__col_cond

rate_choice__row_step:
	add	$s4, $s4, 1		# row ++
	j	rate_choice__row_cond	# check row condition again


# helper function for rate_choice
rate_choice__if_colour_index:
	mul	$t2, $s4, MAX_BOARD_WIDTH	# row * MAXwidth
	add	$t2, $t2, $s5			# + col
	add	$t2, $t2, 52			# simulated_board[row][col]
	add	$t3, $t2, $s0			# + base (solver) -> solver->simulated_board[row][col]
	lb	$t4, 0($t3)			# get value 

	lb	$t5, colour_selector($s1)	# value of colour_selector[colour_index]

	bne	$t4, $t5, rate_choice__if_not_visited
	li	$s3, 1				# seen = TRUE
	j	rate_choice__if_not_visited

# helper function for rate_choice
rate_choice__if_not_visited:
	mul	$t2, $s4, MAX_BOARD_WIDTH	# row * width
	add	$t2, $t2, $s5			# + col
	add	$t2, $t2, 252			# adjacent_to_cell[row][col]
	add	$t3, $t2, $s0			# + base (solver) -> solver->adjacent_to_cell[row][col]
	lb	$t4, 0($t3)			# get value 

	bne	$t4, NOT_VISITED, rate_choice__if_adjacent

	add	$t6, $s1, $s0			# solver->step_rating_for_colour[colour_index]
	sb	$zero, 4($t6)			# solver->step_rating_for_colour[colour_index].is_eliminated
	j	rate_choice__col_step

rate_choice__if_adjacent:
	bne	$t4, ADJACENT, rate_choice__col_step

	mul	$s2, $s1, 8 		# step_rating_for_colour[colour_index]
	add	$t1, $s2, $s0	      	# + base address (solver)

	lw	$t7, 0($t1)		# solver->step_rating_for_colour[colour_index]
	add	$t7, $t7, 1		# surface_area++
	sw	$t7, 0($t1)		# store back 
	j	rate_choice__col_step


rate_choice__if_seen:
	beq	$s3, 1, rate_choice__epilogue
	mul	$s2, $s1, 8 		# step_rating_for_colour[colour_index]
	add	$t1, $s2, $s0	      	# + base address (solver)

	sw	$zero, 4($t1)	      	# = TRUE	

rate_choice__epilogue:
	pop $s5
	pop $s4
	pop $s3
	pop $s2
	pop $s1
	pop $s0
	pop $ra
	jr  $ra

########################################################################
## void find_adjacent_cells(struct solver *solver, int row, int col); ##
########################################################################
# This function recursively marks all cells adjacent to the fill region in `simulated_board`, 
# distinguishing between visited and adjacent cells for solver analysis.
################################################################################
# .TEXT <find_adjacent_cells>
	.text
find_adjacent_cells:
	# Subset:   3
	#
	# Frame:    [$ra, $s0-$s7]   <-- FILL THESE OUT!
	# Uses:     $a0-$a2, $v0, $t0-$t8, $ra, $s0-$s7
	# Clobbers: $t0-$t8, $a0-$a2, $v0
	#
	# Locals:           <-- FILL THIS OUT!
	#   - $s0: solver
	#   - $s1: row
	#   - $s2: col
	#   - $s3: region colour
	#   - $s4: MAX_BOARD_WIDTH
	#   - $s5: MAX_BOARD_HEIGHT
	#   - $s6: NUM_COLOURS
	#   - $s7: WIDTH * HEIGHT (also reused for visit_deltas base)
	#
	# Structure:        <-- FILL THIS OUT!
	#   find_adjacent_cells
	#   -> [prologue]
	#       -> body
	#           -> check visited status
	#           -> check if same region colour
	#           -> mark as visited or adjacent
	#           -> iterate over all visit_deltas
	#           -> recursive calls if in bounds
	#       -> [epilogue]

find_adjacent_cells__prologue:
	push 	$ra
	push 	$s0
	push 	$s1
	push 	$s2
	push 	$s3
	push 	$s4
	push 	$s5
	push 	$s6
	push 	$s7

find_adjacent_cells__body:
	move	$s0, $a0	# solver
	move	$s1, $a1	# row
	move	$s2, $a2	# col

	li	$s4, MAX_BOARD_WIDTH
	li	$s5, MAX_BOARD_HEIGHT
	li	$s6, NUM_COLOURS
	mul	$s7, $s4, $s5	# WIDTH * HEIGHT

	# get simulated_board[0][0]
	mul	$t0, $s6, 8
	addi	$t0, $t0, 4
	add	$t0, $t0, $s0
	lb	$s3, 0($t0)

	# get &adjacent_to_cell[0][0]
	mul	$t1, $s6, 8
	addi	$t1, $t1, 4
	mul	$t2, $s7, 2
	add	$t1, $t1, $t2
	add	$t1, $t1, $s0

	# offset = row * width + col
	mul	$t3, $s1, $s4
	add	$t3, $t3, $s2
	add	$t1, $t1, $t3     # t1 = &adjacent_to_cell[row][col]

	lb	$t6, 0($t1)
	li	$t7, NOT_VISITED
	bne	$t6, $t7, find_adjacent_cells__epilogue

	# get simulated_board[row][col]
	mul	$t5, $s1, $s4
	add	$t5, $t5, $s2
	add	$t5, $t5, $t0
	lb	$t8, 0($t5)

	bne	$t8, $s3, find_adjacent_cells__not_fill_region_colour

	# VISITED
	li	$t4, VISITED
	sb	$t4, 0($t1)
	
find_adjacent_cells__for_inti:
	li	$t0, 0 		# int i = 0

find_adjacent_cells__for_cond:
	bge	$t0, NUM_VISIT_DELTAS, find_adjacent_cells__epilogue	 # i >= NUM_VISIT_DELTAS

find_adjacent_cells__for_body:
	la	$s7, visit_deltas	# address of visit_deltas[]

	la	$s3, board_height 	# address of board_height
	lw	$t5, 0($s3)		# value of board_height

	la	$s4, board_width 	# address of board_height
	lw	$t6, 0($s4)		# value of board_height

	# row_delta ($t2)
	mul	$t1, $t0, 2	# i * width (2)
	add	$t1, $t1, VISIT_DELTA_ROW	# add VISIT_DELTA_ROW
	mul	$t1, $t1, 4	# size = 4
	add	$t1, $t1, $s7 	# + base adress 
	lw	$t2, 0($t1)	# t2 = value visit_deltas[i][VISIT_DELTA_ROW]

	# col_delta ($t4)
	mul	$t3, $t0, 2	# i * width (2)
	add	$t3, $t3, VISIT_DELTA_COL	# add VISIT_DELTA_COL
	mul	$t3, $t3, 4	# size = 4
	add	$t3, $t3, $s7 	# + base adress 
	lw	$t4, 0($t3)	# t4 = value visit_deltas[i][VISIT_DELTA_COL]

	# if (!in_bounds(row + row_delta, 0, board_height - 1))
	add	$a0, $s1, $t2	# row + row_delta	
	li	$a1, 0
	add	$a2, $t5, -1	# board_height - 1

	jal 	in_bounds
	bne	$v0, 1, find_adjacent_cells__for_step

	# if (!in_bounds(col + col_delta, 0, board_width - 1))
	add	$a0, $s2, $t4	# col + col_delta
	li	$a1, 0
	add	$a2, $t6, -1	# board_width - 1

	jal 	in_bounds
	bne	$v0, 1, find_adjacent_cells__for_step

	# find_adjacent_cells(solver, row + row_delta, col + col_delta)
	move	$a0, $s0	# solver
	add	$a1, $s1, $t2	# row + row_delta
	add	$a2, $s2, $t4	# col + col_delta
	jal 	find_adjacent_cells

find_adjacent_cells__for_step:
	addi 	$t0, $t0, 1	# i++
	j	find_adjacent_cells__for_cond

find_adjacent_cells__not_fill_region_colour:
	li	$t3, ADJACENT
	sb	$t3, 0($t1)
	j	find_adjacent_cells__epilogue

find_adjacent_cells__epilogue:
	pop 	$s7
	pop 	$s6
	pop 	$s5
	pop 	$s4
	pop 	$s3
	pop 	$s2
	pop 	$s1
	pop 	$s0
	pop 	$ra
	jr  	$ra

##########################################################################
## void fill(struct fill_in_progress *fill_in_progress,                 ##
##    char board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT], int row, int col); ##
##########################################################################
# This function recursively fills connected cells matching the target colour and updates them to the new colour.
################################################################################
# .TEXT <fill>
	.text
fill:
	# Subset:   3
	#
	# Frame:    40 bytes (9 saved registers + $ra)
	# Uses:     [$s0-$s5, $s7, $t0-$t9, $a0-$a3, $v0]
	# Clobbers: [$t0-$t9, $a0-$a3, $v0]
	#
	# Locals:
	#   - $s0: fill_in_progress pointer
	#   - $s1: board base address
	#   - $s2: current row
	#   - $s3: current col
	#   - $s4: board_width address
	#   - $s5: board_height address
	#   - $s7: visit_deltas base address
	#   - $t0-t9: temporary calculations
	#
	# Structure:
	#   fill
	#   -> [prologue]
	#       -> body
	#           -> visited check
	#           -> fill_onto check
	#           -> fill_with check/update
	#           -> cells_filled increment
	#           -> flood fill loop
	#               -> bounds checking
	#               -> recursive call
	#   -> [epilogue]


fill__prologue:
	push 	$ra
	push 	$s0
	push 	$s1
	push 	$s2
	push 	$s3
	push 	$s4
	push 	$s5
	push 	$s7

fill__body:
	# store arguments
	move	$s0, $a0			# *fill_in_progress
	move	$s1, $a1			# char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH]
	move	$s2, $a2			# row
	move	$s3, $a3			# col

	# if (fill_in_progress->visited[row][col] == VISITED)
	mul	$t0, $s2, MAX_BOARD_WIDTH	# row * MAXwidth
	add	$t0, $t0, $s3 			# + col 
	addi	$t0, $t0, 4			# offset of visited
	add	$t0, $t0, $s0			# + base address fill_in_progress
	lb	$t1, 0($t0)			# value of fill_in_progress->visited[row][col]

	li      $t2, VISITED
	beq     $t1, $t2, fill__epilogue    	# if visited, return

	# Mark as visited
	sb      $t2, 0($t0)                	# visited[row][col] = VISITED

	# if (board[row][col] != fill_in_progress->fill_onto)
	mul	$t3, $s2, MAX_BOARD_WIDTH	# # row * MAXwidth
	add	$t3, $t3, $s3			# + col
	add 	$t3, $t3, $s1 			# &board[row][col]
	lb	$t5, 0($t3)			# get value board[row][col]

	add	$t2, $s0, FILL_ONTO_OFFSET	# address of fill_in_progress->fill_onto
	lb	$t6, 0($t2)			# value of fill_in_progress->fill_onto

	bne	$t5, $t6, fill__epilogue	# != -> return

	# if (board[row][col] != fill_in_progress->fill_with) 
	add	$t7, $s0, FILL_WITH_OFFSET	# address of fill_in_progress->fill_with
	lb	$t8, 0($t7)			# value of fill_in_progress->fill_with
	
	bne	$t5, $t8, fill__cells_filled_add

	# board[row][col] = fill_in_progress->fill_with
	sb	$t8, 0($t3)			# store to board[row][col] 

	j	fill__for_loop_init		

fill__cells_filled_add:
	addi	$t9, $s0, 0			# &fill_in_progress->cells_filled
	lw	$t0, 0($t9)			# get value
	addi	$t0, $t0, 1			# ++
	sw	$t0, 0($t9)			# store back 

	# board[row][col] = fill_in_progress->fill_with
	sb	$t8, 0($t3)			# store to board[row][col] 

	j       fill__for_loop_init

fill__for_loop_init:
	li	$t0, 0				# int i = 0

fill__for_loop_cond:
	# i >= NUM_VISIT_DELTAS -> leave loop
	bge	$t0, NUM_VISIT_DELTAS, fill__epilogue	

fill__for_loop_body:
	la	$s7, visit_deltas		# address of visit_deltas[]

	la	$s5, board_height 		# address of board_height
	lw	$t5, 0($s5)			# value of board_height

	la	$s4, board_width 		# address of board_width
	lw	$t6, 0($s4)			# value of board_width

	# row_delta ($t2)
	mul	$t1, $t0, 2			# i * width (2)
	add	$t1, $t1, VISIT_DELTA_ROW	# add VISIT_DELTA_ROW
	mul	$t1, $t1, 4			# size = 4
	add	$t1, $t1, $s7 			# + base adress 
	lw	$t2, 0($t1)			# t2 = value visit_deltas[i][VISIT_DELTA_ROW]

	# col_delta ($t4)
	mul	$t3, $t0, 2			# i * width (2)
	add	$t3, $t3, VISIT_DELTA_COL	# add VISIT_DELTA_COL
	mul	$t3, $t3, 4			# size = 4
	add	$t3, $t3, $s7 			# + base adress 
	lw	$t4, 0($t3)			# t4 = value visit_deltas[i][VISIT_DELTA_COL]


	# if (!in_bounds(row + row_delta, 0, board_height - 1))
	add	$a0, $s2, $t2			# row (s2) + row_delta (t2)	
	li	$a1, 0
	add	$a2, $t5, -1			# board_height - 1

	jal 	in_bounds
	bne	$v0, 1, fill__for_loop_step

	# if (!in_bounds(col + col_delta, 0, board_width - 1))
	add	$a0, $s3, $t4			# col + col_delta
	li	$a1, 0
	add	$a2, $t6, -1			# board_width - 1

	jal 	in_bounds
	bne	$v0, 1, fill__for_loop_step

	# fill(fill_in_progress, board, row + row_delta, col + col_delta)
	move	$a0, $s0			# fill_in_progress
	move 	$a1, $s1			# board
	add	$a2, $s2, $t2			# row (s2)+ row_delta
	add	$a3, $s3, $t4			# col (s3) + col_delta
	jal 	fill


fill__for_loop_step:
	addi	$t0, $t0, 1	# i++
	j	fill__for_loop_cond

fill__epilogue:
	pop 	$s7
	pop 	$s5
	pop 	$s4
	pop 	$s3
	pop 	$s2
	pop 	$s1
	pop 	$s0
	pop 	$ra
	jr  	$ra

##################################################
## void solve_next_step(struct solver *solver); ##
##################################################
# This function finds the next step.
################################################################################
# .TEXT <solve_next_step>
	.text
solve_next_step:
	# Subset:   3
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3, $s4]    
	# Uses:     $a0, $a1, $a2, $v0, $t0
	# Clobbers: $a0, $a1, $a2, $v0, $t0        
	#
	# Locals:          
	#   - $s0: Solver pointer (*solver)
	#   - $s1: Address of solver->future_board
	#   - $s2: Address of solver->simulated_board
	#   - $s3: Board size (MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT)
	#   - $s4: (not currently used, can remove if unused)
	#
	# Structure:        
	#   solve_next_step
	#   -> [prologue]
	#       -> save registers
	#   -> body
	#       -> copy simulated_board to future_board
	#       -> for i in 0..NUM_COLOURS-1
	#           -> check if invalid_step
	#           -> simulate_step
	#           -> initialise adjacent cells
	#           -> find adjacent cells
	#           -> rate choice
	#       -> copy future_board to simulated_board
	#   -> [epilogue]
	#       -> restore registers, return

solve_next_step__prologue:
	push 	$ra
	push 	$s0
	push 	$s1
	push 	$s2
	push 	$s3
	push 	$s4


solve_next_step__body:
	move 	$s0, $a0				# *solver

	add	$s1, $s0, SIMULATED_BOARD_OFFSET	# address of solver->future_board
	add	$s2, $s0, FUTURE_BOARD_OFFSET		# address of solver->simulated_board
	li	$s3, MAX_BOARD_HEIGHT
	mul	$s3, $s3, MAX_BOARD_WIDTH		# MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT

	move	$a0, $s1 
	move 	$a1, $s2
	move 	$a2, $s3				# arguments
	jal	copy_mem

solve_next_step__surface_area_init:
	li	$t0, 0					# int i = 0


solve_next_step__surface_area_cond:
	bge	$t0, NUM_COLOURS, solve_next_step__surface_area_end

solve_next_step__surface_area_body:
	add	$s1, $s0, SIMULATED_BOARD_OFFSET	# address of solver->future_board
	add	$s2, $s0, FUTURE_BOARD_OFFSET		# address of solver->simulated_board
	
	move	$a0, $s1 
	move 	$a1, $s2
	move 	$a2, $s3				# arguments
	jal	copy_mem

	move	$a0, $s0				# solver
	move	$a1, $t0				# i
	jal 	invalid_step				# invalid_step(solver, i)

	beq	$v0, 1, solve_next_step__surface_area_if_statement

	move	$a0, $s0				# solver
	move	$a1, $t0				# i
	jal	simulate_step				# simulate_step(solver, i)

	move	$a0, $s0				# solver
	jal	initialise_solver_adjacent_cells

	move	$a0, $s0				
	li	$a1, 0
	li	$a2, 0
	jal	find_adjacent_cells			# find_adjacent_cells(solver, 0, 0)

	move	$a0, $s0				
	move	$a1, $t0				# i
	jal	rate_choice

	j	solve_next_step__surface_area_step

solve_next_step__surface_area_if_statement:

	j	solve_next_step__surface_area_step
	

solve_next_step__surface_area_step:
	addi	$t0, $t0, 1				# i ++
	j	solve_next_step__surface_area_cond

solve_next_step__surface_area_end:
	add	$s1, $s0, SIMULATED_BOARD_OFFSET	# address of solver->future_board
	add	$s2, $s0, FUTURE_BOARD_OFFSET		# address of solver->simulated_board
	
	move	$a0, $s1 
	move 	$a1, $s2
	move 	$a2, $s3				# arguments
	jal	copy_mem


solve_next_step__epilogue:
	pop 	$s4
	pop 	$s3
	pop 	$s2
	pop 	$s1
	pop 	$s0
	pop 	$ra
	jr  	$ra

#########################################################
## void copy_mem(void *src, void *dst, int num_bytes); ##
#########################################################
# This function handles any remaining bytes that don't fit into an integer.
################################################################################
# .TEXT <copy_mem>
	.text
copy_mem:
	# Subset:   3
	#
	# Frame:    [$ra, $s0-$s2]                
	# Uses:     $a0-$a2, $t0-$t3, $t6, $s0-$s4    
	# Clobbers: $t0-$t6                   
	#
	# Locals:
	#   - $s0: src pointer (void *)
	#   - $s1: dst pointer (void *)
	#   - $s2: num_bytes
	#   - $t0: loop index i
	#   - $t1: num_bytes / 4
	#   - $t2: num_bytes % 4
	#   - $t3: word temporary
	#   - $t6: byte temporary
	#
	# Structure:
	#   copy_mem
	#   -> [prologue]
	#       -> save callee-saved registers
	#   -> [body]
	#       -> compute word and byte copy counts
	#       -> loop copying full words
	#       -> loop copying remaining bytes
	#   -> [epilogue]
	#       -> restore callee-saved registers and return

copy_mem__prologue:
	push	$ra
	push	$s0
	push	$s1
	push	$s2

copy_mem__body:
	move	$s0, $a0	# $s0 = src
	move	$s1, $a1	# $s1 = dst
	move	$s2, $a2	# $s2 = num_bytes

	li	$t4, SIZEOF_INT
	div	$s2, $t4
	mflo	$t3		# $t3 = num_bytes / 4
	mfhi	$t5		# $t5 = num_bytes % 4

	li	$t0, 0		# i = 0

copy_mem__loop_int:
	bge	$t0, $t3, copy_mem__loop_char

	lw	$t6, 0($s0)	# load word from src
	sw	$t6, 0($s1)	# store word to dst

	addi	$s0, $s0, 4	# src++
	addi	$s1, $s1, 4	# dst++
	addi	$t0, $t0, 1	# i++

	j	copy_mem__loop_int

copy_mem__loop_char:
	li	$t0, 0		# i = 0

copy_mem__loop_char_cond:
	bge	$t0, $t5, copy_mem__epilogue

	lb	$t6, 0($s0)	# load byte from src
	sb	$t6, 0($s1)	# store byte to dst

	addi	$s0, $s0, 1	# src++
	addi	$s1, $s1, 1	# dst++
	addi	$t0, $t0, 1	# i++

	j	copy_mem__loop_char_cond

copy_mem__epilogue:
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	jr	$ra


##############
## PROVIDED ##
##############

#######################################################################
## unsigned int random_in_range(unsigned int min, unsigned int max); ##
#######################################################################

################################################################################
# .TEXT <random_in_range>
	.text
random_in_range:
	# Subset:   provided
	#
	# Frame:    []
	# Uses:     [$t0, $t1, $t2, $v0]
	# Clobbers: [$t0, $t1, $t2, $v0]
	#
	# Locals:
	#   - $t0: int a;
	#   - $t1: int m;
	#   - $t2: (a * random_seed) % m
	#   - $v0: min + random_seed % (max - min + 1);
	#
	# Structure:
	#   initialise_solver
	#   -> [prologue]
	#       -> body
	#   -> [epilogue]
random_in_range__prologue:
random_in_range__body:
	li	$t0, 16807		# int a = 16807;
	li	$t1, 2147483647		# int m = 2147483647;
	lw	$t2, random_seed	# ... random_seed
	
	mul	$t2, $t2, $t0		# ... a * random_seed

	remu	$t2, $t2, $t1		# ... (a * random_seed) % m

	sw	$t2, random_seed	# random_seed = (a * random_seed) % m;

	move	$v0, $a1		# ... max
	sub	$v0, $v0, $a0		# ... max - min
	add	$v0, $v0, 1		# ... max - min + 1

	rem	$v0, $t2, $v0		# ... random_seed % (max - min + 1)
	add	$v0, $v0, $a0		# return min + random_seed % (max - min + 1);
random_in_range__epilogue:
	jr	$ra

####################################################
## void initialise_solver(struct solver *solver); ##
####################################################

################################################################################
# .TEXT <initialise_solver>
	.text
initialise_solver:
	# Subset:   provided
	#
	# Frame:    []
	# Uses:     [$a0, $a1, $a2]
	# Clobbers: [$a0, $a1, $a2]
	#
	# Locals:
	#   - $a0: game_board
	#   - $a1: solver->simulated_board
	#   - $a2: MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT
	#
	# Structure:
	#   initialise_solver
	#   -> [prologue]
	#       -> body
	#   -> [epilogue]

initialise_solver__prologue:
	push	$ra
initialise_solver__body:
	sw	$zero, SOLUTION_LENGTH_OFFSET($a0)	# solver->solution_length = 0;

	la	$a1, SIMULATED_BOARD_OFFSET($a0)	# copy_mem(game_board, solver->simulated_board, MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT);
	la	$a0, game_board				#
	li	$a2, MAX_BOARD_WIDTH			#
	mul	$a2, $a2, MAX_BOARD_HEIGHT		#
	jal	copy_mem				#

initialise_solver__epilogue:
	pop	$ra
	jr	$ra					# return;

##################################################################
## void simulate_step(struct solver *solver, int colour_index); ##
##################################################################

################################################################################
# .TEXT <simulate_step>
	.text
simulate_step:
	# Subset:   provided
	#
	# Frame:    [$s0]
	# Uses:     [$s0, $a0, $a1, $a2, $a3]
	# Clobbers: [$a0, $a1, $a2, $a3]
	#
	# Locals:
	#   - $s0: save argument struct solver *solver
	#   - $a0: &global_fill_in_progress
	#   - $a1: argument 2
	#   - $a2: 0
	#   - $a3: 0
	#
	# Structure:
	#   simulate_step
	#   -> [prologue]
	#       -> body
	#   -> [epilogue]

simulate_step__prologue:
	push	$ra
	push	$s0
simulate_step__body:
	move	$s0, $a0

	lb	$a2, SIMULATED_BOARD_OFFSET($a0)#
	la	$a0, global_fill_in_progress	# initialise_fill_in_progress(&global_fill_in_progress, 
	lb	$a1, colour_selector($a1)	#     colour_selector[colour_index], solver->simulated_board[0][0]);
	jal	initialise_fill_in_progress	#

	la	$a0, global_fill_in_progress	# fill(&global_fill_in_progress, solver->simulated_board, 0, 0);
	la	$a1, SIMULATED_BOARD_OFFSET($s0)#
	li	$a2, 0				#
	li	$a3, 0				#
	jal	fill				#
simulate_step__epilogue:
	pop	$s0
	pop	$ra
	jr	$ra				# return;

###################################################################
## void initialise_solver_adjacent_cells(struct solver *solver); ##
###################################################################

################################################################################
# .TEXT <initialise_solver_adjacent_cells>
	.text
initialise_solver_adjacent_cells:
	# Subset:   provided
	#
	# Frame:    []
	# Uses:     [$t0, $t1, $t2, $t3]
	# Clobbers: []
	#
	# Locals:
	#   - $t0: int row;
	#   - $t1: int col;
	#   - $t2: address calculation & reading globals
	#   - $t3: value storage for sw
	#
	# Structure:
	#   initialise_solver_adjacent_cells
	#   -> [prologue]
	#       -> body
	#       -> row
	#           -> row_init
	#           -> row_cond
	#           -> row_body
	#           -> column
	#               -> column_init
	#               -> column_cond
	#               -> column_body
	#               -> column_step
	#               -> column_end
	#           -> row_step
	#           -> row_end
	#   -> [epilogue]

initialise_solver_adjacent_cells__prologue:
initialise_solver_adjacent_cells__body:
initialise_solver_adjacent_cells__row_init:
	li	$t0, 0				# int row = 0;
initialise_solver_adjacent_cells__row_cond:
	lw	$t2, board_height		# while (row < board_height) {
	bge	$t0, $t2, initialise_solver_adjacent_cells__row_end
						#
initialise_solver_adjacent_cells__row_body:
initialise_solver_adjacent_cells__column_init:
	li	$t1, 0				#     int col = 0;
initialise_solver_adjacent_cells__column_cond:
	lw	$t2, board_width		#     while (col < board_width) {
	bge	$t1, $t2, initialise_solver_adjacent_cells__column_end
						#
initialise_solver_adjacent_cells__column_body:
	mul	$t2, $t0, MAX_BOARD_WIDTH	#         ... &[row]
	add	$t2, $t2, $t1			#         ... &[row][col]
	add	$t2, $t2, $a0			#         ... &solver[row][col]
	li	$t3, NOT_VISITED		#
	sb	$t3, ADJACENT_TO_CELL_OFFSET($t2)
						#         solver->adjacent_to_cell[row][col] = NOT_VISITED;
initialise_solver_adjacent_cells__column_step:
	add	$t1, $t1, 1			#         col++;
	b	initialise_solver_adjacent_cells__column_cond
						#     }
initialise_solver_adjacent_cells__column_end:
initialise_solver_adjacent_cells__row_step:
	add	$t0, $t0, 1			#     row++;
	b	initialise_solver_adjacent_cells__row_cond
						# }
initialise_solver_adjacent_cells__row_end:

initialise_solver_adjacent_cells__epilogue:
	jr	$ra				# return;
######################################################################
## void print_board(char board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT]); ##
######################################################################

################################################################################
# .TEXT <print_board>
	.text
print_board:
	# Subset:   provided
	#
	# Frame:    [$ra, $s0, $s1]
	# Uses:     [$s0, $s1, $t0, $a0, $v0]
	# Clobbers: [$t0, $a0, $v0]
	#
	# Locals:
	#   - $s0: char board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT]
	#   - $s1: int i;
	#   - $t0: loading globals
	#   - $a0: syscall argument
	#   - $v0: syscall number
	#
	# Structure:
	#   print_board
	#   -> [prologue]
	#       -> body
	#       -> row
	#           -> row_init
	#           -> row_cond
	#           -> row_body
	#           -> row_step
	#           -> row_end
	#   -> [epilogue]

print_board__prologue:
	push	$ra
	push	$s0
	push	$s1
print_board__body:
	move	$s0, $a0
print_board__print_row_init:
	li	$s1, 0				# int i = 0;
print_board__print_row_cond:
	lw	$t0, board_height		# while (i < board_height) {
	bge	$s1, $t0, print_board__print_row_end
						#
print_board__print_row_body:
	move	$a0, $s0			#     print_board_row(board, i);
	move	$a1, $s1			#
	jal	print_board_row			#
print_board__print_row_step:
	add	$s1, $s1, 1			#     i++;
	b	print_board__print_row_cond	# }
print_board__print_row_end:
	jal	print_board_seperator_line	# print_board_seperator_line();
	jal	print_board_bottom		# print_board_bottom();

	lw	$a0, steps			# printf("%d", steps);
	li	$v0, 1				#
	syscall					#

	li	$a0, '/'			# putchar('/');
	li	$v0, 11				#
	syscall					#

	lw	$a0, optimal_steps		# printf("%d", optimal_steps + EXTRA_STEPS);
	add	$a0, $a0, EXTRA_STEPS		#
	li	$v0, 1				#
	syscall					#

	la	$a0, str_print_board_steps	# printf(" steps\n);
	li	$v0, 4				#
	syscall					#
print_board__epilogue:
	pop	$s1
	pop	$s0
	pop	$ra
	jr	$ra				# return;

################################
## void print_board_bottom(); ##
################################

################################################################################
# .TEXT <print_board_bottom>
	.text
print_board_bottom:
	# Subset:   provided
	#
	# Frame:    []
	# Uses:     [$t0, $t1, $t2, $t3, $a0, $v0]
	# Clobbers: [$t0, $t1, $t2, $t3, $a0, $v0]
	#
	# Locals:
	#   - $t0: int i;
	#   - $t1: int j;
	#   - $t2: int k;
	#   - $t3: arithmetic & loading globals
	#   - $a0: syscall argument
	#   - $v0: syscall number
	#
	# Structure:
	#   print_board_bottom
	#   -> [prologue]
	#       -> body
	#       -> down
	#           -> down_init
	#           -> down_cond
	#           -> down_body
	#           -> down_step
	#           -> down_end
	#           -> across
	#               -> across_init
	#               -> across_cond
	#               -> across_body
	#               -> not_selected
	#                   -> not_selected_init
	#                   -> not_selected_cond
	#                   -> not_selected_body
	#                   -> not_selected_step
	#                   -> not_selected_end
	#               -> selected
	#                   -> selected1
	#                       -> selected1_init
	#                       -> selected1_cond
	#                       -> selected1_body
	#                       -> selected1_step
	#                       -> selected1_end
	#                   -> i
	#                       -> i_nonzero
	#                       -> i_end
	#                   -> selected2
	#                       -> selected2_init
	#                       -> selected2_cond
	#                       -> selected2_body
	#                       -> selected2_step
	#                       -> selected2_end
	#               -> across_step
	#               -> across_end
	#   -> [epilogue]

print_board_bottom__prologue:
print_board_bottom__body:
print_board_bottom__down_init:
	li	$t0, 0				# int i = 0;
print_board_bottom__down_cond:
	bge	$t0, SELECTED_ARROW_VERTICAL_LENGTH + 1, print_board_bottom__down_end
						# while (i < SELECTED_ARROW_VERTICAL_LENGTH + 1) {
print_board_bottom__down_body:
	li	$v0, 11				#     putchar(BOARD_SPACE_SEPERATOR);
	li	$a0, BOARD_SPACE_SEPERATOR	#
	syscall					#
print_board_bottom__across_init:
	li	$t1, 0				#     int j = 0;
print_board_bottom__across_cond:
	lw	$t3, board_width		#     while (j < board_width) {
	bge	$t1, $t3, print_board_bottom__across_end
						#
print_board_bottom__across_body:

	lw	$t3, selected_column		#         if (j != selected_column) {
	beq	$t1, $t3, print_board_bottom__across_selected
						#

print_board_bottom__not_selected_init:
	li	$t2, 0				#             int k = 0;
print_board_bottom__not_selected_cond:
	bge	$t2, BOARD_CELL_SIZE + 3, print_board_bottom__not_selected_end
						#             while (k < BOARD_CELL_SIZE + 3) {
print_board_bottom__not_selected_body:
	li	$a0, BOARD_SPACE_SEPERATOR	#                 putchar(BOARD_SPACE_SEPERATOR);
	li	$v0, 11				#
	syscall					#
print_board_bottom__not_selected_step:
	add	$t2, $t2, 1			#                 k++;
	b	print_board_bottom__not_selected_cond
						#             }
print_board_bottom__not_selected_end:
	b	print_board_bottom__across_step	#         } else {
print_board_bottom__across_selected:
print_board_bottom__across_selected1_init:
	li	$t2, 0				#             int k = 0;
print_board_bottom__across_selected1_cond:
	li	$t3, BOARD_CELL_SIZE + 1	#             while (k < (BOARD_CELL_SIZE + 1) / 2) {
	div	$t3, $t3, 2			#
	bge	$t2, $t3, print_board_bottom__across_selected1_end
						#
print_board_bottom__across_selected1_body:
	li	$a0, BOARD_SPACE_SEPERATOR	#                 putchar(BOARD_SPACE_SEPERATOR);
	li	$v0, 11				#
	syscall					#
print_board_bottom__across_selected1_step:
	add	$t2, $t2, 1			#                 k++;
	b	print_board_bottom__across_selected1_cond
						#             }
print_board_bottom__across_selected1_end:

	bnez	$t0, print_board_bottom__across_i_nonzero
						#             if (i == 0) {

	li	$a0, BOARD_SPACE_SEPERATOR	#                 putchar(BOARD_SPACE_SEPERATOR);
	li	$v0, 11				#
	syscall					#

	b	print_board_bottom__across_i_end
						#             } else {
print_board_bottom__across_i_nonzero:

	sub	$a0, $t0, 1			#                 putchar(selected_arrow_vertical[i - 1]);
	lb	$a0, selected_arrow_vertical($a0)
						#
	li	$v0, 11				#
	syscall					#

print_board_bottom__across_i_end:		#             }

print_board_bottom__across_selected2_init:
	li	$t2, 0				#             k = 0;
print_board_bottom__across_selected2_cond:
	li	$t3, BOARD_CELL_SIZE + 1	#             while (k < ((BOARD_CELL_SIZE + 1) / 2)) {
	div	$t3, $t3, 2			#
	bge	$t2, $t3, print_board_bottom__across_selected2_end
						#
print_board_bottom__across_selected2_body:
	li	$a0, BOARD_SPACE_SEPERATOR	#                 putchar(BOARD_SPACE_SEPERATOR);
	li	$v0, 11				#
	syscall					#

print_board_bottom__across_selected2_step:
	add	$t2, $t2, 1			#                 k++;
	b	print_board_bottom__across_selected2_cond
						#             }
print_board_bottom__across_selected2_end:

print_board_bottom__across_step:
	add	$t1, $t1, 1			#         j++;
	b	print_board_bottom__across_cond	#     }
print_board_bottom__across_end:

	li	$a0, BOARD_SPACE_SEPERATOR	#     putchar(BOARD_SPACE_SEPERATOR);
	li	$v0, 11				#
	syscall					#

	li	$a0, '\n'			#     putchar('\n');
	syscall					#

print_board_bottom__down_step:
	add	$t0, $t0, 1			#     i++;
	b	print_board_bottom__down_cond	# }
print_board_bottom__down_end:
print_board_bottom__epilogue:
	jr	$ra				# return;

#########################################################################
## void print_board_row(char board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT], ##
##     int row);                                                       ##
#########################################################################

################################################################################
# .TEXT <print_board_row>
	.text
print_board_row:
	# Subset:   provided
	#
	# Frame:    [$ra, $s0, $s1, $s2]
	# Uses:     [$s0, $s1, $s2, $t0, $t1, $a0, $a1, $a2]
	# Clobbers: [$t0, $t1, $a0, $a1, $a2]
	#
	# Locals:
	#   - $s0: char board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT]
	#   - $s1: int row
	#   - $s2: int i
	#   - $t0: i == BOARD_CELL_SIZE / 2
	#   - $t1: row == selected_row
	#   - $a0: char board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT]
	#   - $a1: int row
	#   - $a2: i == BOARD_CELL_SIZE / 2 && row == selected_row
	#
	# Structure:
	#   print_board_row
	#   -> [prologue]
	#       -> body
	#       -> each_row
	#           -> each_row_init
	#           -> each_row_cond
	#           -> each_row_body
	#           -> each_row_step
	#           -> each_row_end
	#   -> [epilogue]

print_board_row__prologue:
	push	$ra
	push	$s0
	push	$s1
	push	$s2
print_board_row__body:
	move	$s0, $a0
	move	$s1, $a1

	jal	print_board_seperator_line	# print_board_seperator_line();

print_board_row__each_row_init:
	li	$s2, 0				# int i = 0;
print_board_row__each_row_cond:
	bge	$s2, BOARD_CELL_SIZE, print_board_row__each_row_end
						# while (i < BOARD_CELL_SIZE) {
print_board_row__each_row_body:
	move	$a0, $s0			#
	move	$a1, $s1			#

	li	$t0, BOARD_CELL_SIZE		#
	div	$t0, $t0, 2			#
	seq	$t0, $t0, $s2			# ... i == BOARD_CELL_SIZE / 2

	lw	$t1, selected_row		#
	seq	$t1, $s1, $t1			# ... row == selected_row
	and 	$a2, $t0, $t1			# ... i == BOARD_CELL_SIZE / 2 && row == selected_row

	jal	print_board_inner_line		# print_board_inner_line(board, row, i == BOARD_CELL_SIZE / 2 && row == selected_row);
print_board_row__each_row_step:
	add	$s2, $s2, 1			#     i++;
	b	print_board_row__each_row_cond	# }
print_board_row__each_row_end:

print_board_row__epilogue:
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra
	jr	$ra				# return;

################################################################################
## void print_board_inner_line(char board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT], ##
##     int row, int row_is_selected);                                         ##
################################################################################

################################################################################
# .TEXT <print_board_inner_line>
	.text
print_board_inner_line:
	# Subset:   provided
	#
	# Frame:    []
	# Uses:     [$t0, $t1, $t2, $t3, $a0, $v0]
	# Clobbers: [$t0, $t1, $t2, $t3, $a0, $v0]
	#
	# Locals:
	#   - $t0: char board[MAX_BOARD_WIDTH][MAX_BOARD_HEIGHT]
	#   - $t1: int i;
	#   - $t2: int j;
	#   - $t3: loading globals
	#   - $a0: syscall argument
	#   - $v0: syscall number
	#
	# Structure:
	#   print_board_inner_line
	#   -> [prologue]
	#       -> body
	#       -> cells
	#           -> cells_init
	#           -> cells_cond
	#           -> cells_body
	#           -> inner_cell
	#               -> inner_cell_init
	#               -> inner_cell_cond
	#               -> inner_cell_body
	#               -> inner_cell_step
	#               -> inner_cell_end
	#           -> cells_step
	#           -> cells_end
	#   -> [epilogue]

print_board_inner_line__prologue:
print_board_inner_line__body:
	move	$t0, $a0

	li	$a0, BOARD_VERTICAL_SEPERATOR	# putchar(BOARD_VERTICAL_SEPERATOR);
	li	$v0, 11				#
	syscall					#

print_board_inner_line__cells_init:
	li	$t1, 0				# int i = 0;
print_board_inner_line__cells_cond:
	lw	$t3, board_width		# while (i < board_width) {
	bge	$t1, $t3, print_board_inner_line__cells_end
						#
print_board_inner_line__cells_body:
	li	$a0, BOARD_SPACE_SEPERATOR	#     putchar(BOARD_SPACE_SEPERATOR);
	li	$v0, 11				#
	syscall					#

print_board_inner_line__inner_cell_init:
	li	$t2, 0				#     int j = 0;
print_board_inner_line__inner_cell_cond:
	bge	$t2, BOARD_CELL_SIZE, print_board_inner_line__inner_cell_end
						#     while (j < BOARD_CELL_SIZE) {
print_board_inner_line__inner_cell_body:
	mul	$a0, $a1, MAX_BOARD_WIDTH	#         ... &[row]
	add	$a0, $a0, $t0			#         ... &board[row]
	add	$a0, $a0, $t1			#         ... &board[row][col]
	lb	$a0, ($a0)			#         putchar(board[row][i]);
	li	$v0, 11				#
	syscall
print_board_inner_line__inner_cell_step:
	add	$t2, $t2, 1			#         j++;
	b	print_board_inner_line__inner_cell_cond
						#     }
print_board_inner_line__inner_cell_end:

	li	$a0, BOARD_SPACE_SEPERATOR	#     putchar(BOARD_SPACE_SEPERATOR);
	li	$v0, 11				#
	syscall					#

	lw	$t3, board_width		#     if (i != board_width - 1) {
	sub	$t3, $t3, 1			#
	beq	$t1, $t3, print_board_inner_line__cells_step
						#

	li	$a0, BOARD_CELL_SEPERATOR	#         putchar(BOARD_CELL_SEPERATOR);
	li	$v0, 11				#
	syscall					#

print_board_inner_line__cells_step:		#     }
	add	$t1, $t1, 1			#     i++;
	b	print_board_inner_line__cells_cond
						# }
print_board_inner_line__cells_end:

	li	$a0, BOARD_VERTICAL_SEPERATOR	# putchar(BOARD_VERTICAL_SEPERATOR);
	li	$v0, 11				#
	syscall					#

	beqz	$a2, print_board_inner_line__last_newline
						# if (row_is_selected) {

	li	$a0, BOARD_SPACE_SEPERATOR	#     putchar(BOARD_SPACE_SEPERATOR);
	li	$v0, 11				#
	syscall					#

	la	$a0, selected_arrow_horizontal	#     printf("%s", selected_arrow_horizontal);
	li	$v0, 4				#
	syscall					#

print_board_inner_line__last_newline:		# }
	li	$a0, '\n'			#
	li	$v0, 11				#
	syscall					#
print_board_inner_line__epilogue:
	jr	$ra				# return;

########################################
## void print_board_seperator_line(); ##
########################################

################################################################################
# .TEXT <print_board_seperator_line>
	.text
print_board_seperator_line:
	# Subset:   provided
	#
	# Frame:    []
	# Uses:     [$t0, $t1, $t2, $a0, $v0]
	# Clobbers: [$t0, $t1, $t2, $a0, $v0]
	#
	# Locals:
	#   - $t0: int i;
	#   - $t1: int j;
	#   - $t2: globals
	#   - $a0: syscall argument 
	#   - $v0: syscall number
	#
	# Structure:
	#   print_board_seperator_line
	#   -> [prologue]
	#       -> body
	#       -> line
	#           -> line_init
	#           -> line_cond
	#           -> line_body
	#           -> line_step
	#           -> line_end
	#           -> inner_line
	#               -> inner_line_init
	#               -> inner_line_cond
	#               -> inner_line_body
	#               -> inner_line_step
	#               -> inner_line_end
	#   -> [epilogue]

print_board_seperator_line__prologue:
print_board_seperator_line__body:
	li	$a0, BOARD_VERTICAL_SEPERATOR	# putchar(BOARD_VERTICAL_SEPERATOR);
	li	$v0, 11				#
	syscall					#

print_board_seperator_line__line_init:
	li	$t0, 0				# int i = 0;
print_board_seperator_line__line_cond:
	lw	$t2, board_width		#
	bge	$t0, $t2, print_board_seperator_line__line_end
						# while (i < board_width) {
print_board_seperator_line__line_body:

print_board_seperator_line__inner_line_init:
	li	$t1, 0				#     int j = 0;
print_board_seperator_line__inner_line_cond:
	bge	$t1, BOARD_CELL_SIZE + 2, print_board_seperator_line__inner_line_end
						#     while (j < BOARD_CELL_SIZE + 2) {
print_board_seperator_line__inner_line_body:
	li	$a0, BOARD_HORIZONTAL_SEPERATOR	#         putchar(BOARD_HORIZONTAL_SEPERATOR);
	li	$v0, 11				#
	syscall					#
print_board_seperator_line__inner_line_step:
	add	$t1, $t1, 1			#         j++;
	b	print_board_seperator_line__inner_line_cond
						#     }
print_board_seperator_line__inner_line_end:
	lw	$t2, board_width		#     if (i != board_width - 1) {
	sub	$t2, $t2, 1			#
	beq	$t2, $t0, print_board_seperator_line__line_step
						#

	li	$a0, BOARD_CROSS_SEPERATOR	#         putchar(BOARD_CROSS_SEPERATOR);
	li	$v0, 11				#
	syscall					#

print_board_seperator_line__line_step:		#     }
	add	$t0, $t0, 1			#     i++;
	b	print_board_seperator_line__line_cond
						# }
print_board_seperator_line__line_end:

	li	$a0, BOARD_VERTICAL_SEPERATOR	# putchar(BOARD_VERTICAL_SEPERATOR);
	li	$v0, 11				#
	syscall					#

	li	$a0, '\n'			# putchar('\n');
	syscall					#

print_board_seperator_line__epilogue:
	jr	$ra				# return;

#############################
## void process_command(); ##
#############################

################################################################################
# .TEXT <process_command>
	.text
process_command:
	# Subset:   provided
	#
	# Frame:    [$ra]
	# Uses:     [$t0, $t1, $a0, $v0]
	# Clobbers: [$t0, $t1, $a0, $v0]
	#
	# Locals:
	#   - $t0: char command;
	#   - $t1: globals
	#   - $a0: syscall argument
	#   - $v0: syscall number
	#
	# Structure:
	#   process_command
	#   -> [prologue]
	#       -> body
	#       -> good_parsing
	#           -> good_parsing_cond
	#           -> good_parsing_end
	#       -> up
	#           -> up
	#           -> up_in_bounds
	#       -> down
	#           -> down
	#           -> down_in_bounds
	#       -> right
	#           -> right
	#           -> right_in_bounds
	#       -> left
	#           -> left
	#           -> left_in_bounds
	#       -> quit
	#       -> fill
	#       -> help
	#       -> cheat
	#       -> unknown
	#       -> end_switch
	#   -> [epilogue]

process_command__prologue:
	push	$ra
process_command__body:
	la	$a0, cmd_waiting
	li	$v0, 4
	syscall

	li	$v0, 12
	syscall
	move	$t0, $v0
process_command__good_parsing_cond:
	bne	$t0, '\n', process_command__good_parsing_end
	li	$v0, 12
	syscall
	move	$t0, $v0
	b	process_command__good_parsing_cond
process_command__good_parsing_end:
	beq	$t0, 'w', process_command__up		# switch (command) {
	beq	$t0, 's', process_command__down		#
	beq	$t0, 'd', process_command__right	#
	beq	$t0, 'a', process_command__left		#
	beq	$t0, 'q', process_command__quit		#
	beq	$t0, 'e', process_command__fill		#
	beq	$t0, 'h', process_command__help		#
	beq	$t0, 'c', process_command__cheat	#
	b	process_command__unknown		#
process_command__up:					#     case 'w':
	lw	$t0, selected_row			#         selected_row = MAX(selected_row - 1, 0);
	sub	$t0, $t0, 1				#
	bge	$t0, 0, process_command__up_in_bounds	#
	li	$t0, 0					#
process_command__up_in_bounds:
	sw	$t0, selected_row			#
	b	process_command__end_switch		#         break;
process_command__down:					#     case 's':
	lw	$t0, selected_row			#         selected_row = MIN(selected_row + 1, board_height - 1);
	add	$t0, $t0, 1				#
	lw	$t1, board_height			#
	sub	$t1, $t1, 1				#
	ble	$t0, $t1, process_command__down_in_bounds
							#
	move	$t0, $t1				#
process_command__down_in_bounds:			#
	sw	$t0, selected_row			#
	b	process_command__end_switch		#         break;
process_command__right:					#     case 'd':
	lw	$t0, selected_column			#         selected_column = MIN(selected_column + 1, board_width - 1)
	add	$t0, $t0, 1				#
	lw	$t1, board_width			#
	sub	$t1, $t1, 1				#
	ble	$t0, $t1, process_command__right_in_bounds
							#
	move	$t0, $t1				#
process_command__right_in_bounds:			#
	sw	$t0, selected_column			#
	b	process_command__end_switch		#         break;
process_command__left:					#     case 'a':
	lw	$t0, selected_column			#         selected_column = MAX(selected_column - 1, 0);
	sub	$t0, $t0, 1				#
	bge	$t0, 0, process_command__left_in_bounds	#
	li	$t0, 0					#
process_command__left_in_bounds:			#
	sw	$t0, selected_column			#
	b	process_command__end_switch		#         break;
process_command__quit:					#     case 'q':
	li	$v0, 10					#         exit(0);
	syscall						#
process_command__fill:					#     case 'e':
	jal	do_fill					#         do_fill();
	b	process_command__end_switch		#         break;
process_command__help:					#     case 'h':
	jal	print_welcome				#         print_welcome();
	b	process_command__epilogue		#         return;
process_command__cheat:					#     case 'c':
	jal	print_optimal_solution			#         print_optimal_solution();
	b	process_command__epilogue		#         return;
process_command__unknown:				#     default:
	la	$a0, str_process_command_unknown	#         printf("Unknown command: ");
	li	$v0, 4					#
	syscall						#

	move	$a0, $t0				#         putchar(command);
	li	$v0, 11					#
	syscall						#

	li	$a0, '\n'				#         putchar('\n')
	syscall						#
	b	process_command__epilogue		#         return;
process_command__end_switch:				# }

	la	$a0, game_board
	jal	print_board				# print_board(game_board);

process_command__epilogue:
	pop	$ra
	jr	$ra					# return;
