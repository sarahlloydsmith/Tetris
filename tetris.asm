################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Sarah Lloyd-Smith, 1008082860
# Student 2: Janna Alyssa Lim, 1009101455
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
PINK: 
    .word 0xff3c8c  # colour for T tetromino
BLUE:
    .word 0x00d4ff  # colour for J tetromino
GREEN:
    .word 0x00ff24  # colour for L tetromino
YELLOW:
    .word 0xfff300  # colour for Z tetromino
PURPLE:
    .word 0xce86ff  # colour for the S tetromino
INDIGO:
    .word 0x5d57ff  # colour for the I tetromino
ORANGE:
    .word 0xff8300  # colour for the O tetromino
STARTING_X_OFFSET:
    .word 0xf       # horizontal offset for the starting position
DARK_PURPLE:
    .word 0x1f124a # colour for wall
LIGHT_GREY:
    .word 0x303030 # colour for background
DARK_GREY:
    .word 0x202020 # colour for background
RED:
    .word 0xff0000 # colour for GAME OVER
WHITE:
    .word 0xffffff # colour for PAUSED

##############################################################################
# Mutable Data
##############################################################################

GRAVITY:
    .word 60       # Store increment value for gravity
GRAVITY_COUNTER:
    .word 0         # Store
ROTATION:
    .word 0         # Number to store what rotation the movable tetromino is on (from 0 (starting posision) to 3, is reset to 0 when new tetromino is made)
TETROMINO_TYPE:
    .word 116       # ASCII number corresponding to the type of the movable tetromino (starting tetromino is T)
T_TETROMINO:
    .space 16       # Array for the pixels for the T-tertromino (starting position is the second element)
T_TETROMINO_R1:
    .space 16       # Array for the pixels for the T-Tetromino after its first rotation (strting position is the third element)
T_TETROMINO_R2:
    .space 16       # Array for the pixels for the T-Tetromino after its second rotation (starting position is the third element)
T_TETROMINO_R3:
    .space 16       # Array for the pixels for the T-Tetromino after its third rotation (starting position is the second element)
J_TETROMINO:
    .space 16       # Array for the pixels for the J-Tetromino (starting position is the first element)
J_TETROMINO_R1:
    .space 16       # Array for the pixels for the J-Tetromino after its first rotation (starting position is the fourth element)
J_TETROMINO_R2:
    .space 16       # Array for the pixels for the J-Tetromino after its second rotaiton (starting position is the fourth element)
J_TETROMINO_R3:
    .space 16       # Array for the pixels for the J-Tetromino after its third rotation (startng position is the first element)
L_TETROMINO:
    .space 16       # Array for the pixels for the L-Tetromino (starting position is the first element)
L_TETROMINO_R1:
    .space 16       # Array for the pixels for the L-Tetromino after its first rotation (starting position is the thrid element)
L_TETROMINO_R2:
    .space 16       # Array for the pixels for the L-Tetromino after its second rotation (starting position is the fourth element)
L_TETROMINO_R3:
    .space 16       # Array for the pixels for the L-Tetromino after its third rotation (starting position is the second element)
Z_TETROMINO:
    .space 16       # Array for the pixels for the Z-Tetromino (starting position is the second element)
Z_TETROMINO_R1:
    .space 16       # Array for the pixels for the Z-Tetromino after its first rotation (starting position is the third element)
Z_TETROMINO_R2:
    .space 16       # Array for the pixels for the Z-Tetromino after its second rotation (starting position is the third element)
Z_TETROMINO_R3:
    .space 16       # Array for the pixels for the Z-Tetromino after its thrid rotation (starting position is the second element)
S_TETROMINO:
    .space 16       # Array for the pixels for the S-Tetromino (starting position is the first element)
S_TETROMINO_R1:
    .space 16       # Array for the pixels for the S-Tetromino after its first rotation (starting position is the third element)
S_TETROMINO_R2:
    .space 16       # Array for the pixels for the S-Tetromino after its second rotation (starting position is the fourth element)
S_TETROMINO_R3:
    .space 16       # Array for the pixels for the S-Tetromino after its third rotation (starting position is the second element)
I_TETROMINO:
    .space 16       # Array for the pixels for the I-Tetromino (starting position is the first element)
I_TETROMINO_R1:
    .space 16       # Array for the pixels for the I-Tetromino after its first rotation (starting position is the fourth element)
I_TETROMINO_R2:
    .space 16       # Array for the pixels for the I-Tetromino after its second rotation (starting position is the fourth element)
I_TETROMINO_R3:
    .space 16       # Array for the pixels for the I-Tetromino after its third rotation (starting position is the first element)
O_TETROMINO:
    .space 16       # Array for the pixels for the O-Tetromino (starting position is the first element)
O_TETROMINO_R1:
    .space 16       # Array for the pixels for the O-Tetromino after its first rotation (starting position is the second element)
O_TETROMINO_R2:
    .space 16       # Array for the pixels for the O-Tetromino after its second rotation (starting position is the fourth element)
O_TETROMINO_R3:
    .space 16       # Array for the pixels for the O-Tetromino after its third rotation (starting position is the third element)
BACKGROUND:
    .space 1024     # Array to store the background including the checkerboard and walls
    
BITMAP_COPY:
    .space 1024     # Array to store a copy of the bitmap, including the previously placed tetrominos
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
main:
    # Initialize the game
    jal draw_background     # Draw the background
    jal set_background      # Set the background
    jal set_bitmap_copy     # Set the bitmap copy
    
    addi $s7, $zero, 1000    # Maximum time
    addi $s4, $zero, 30     # Maximum gravity
    addi $s6, $zero, 1      # Current gravity
    addi $s5, $zero, 0      # Current time
    # Drawing the starting tetromino
    # $t0: starting x offset
    # $t1: starting y offset 
    # $t2: array address
    # $t3: value of GRAVITY_COUNTER
    # $t4: value of GRAVITY
    # $t5: address for GRAVITY_COUNTER
    # $t6: address for TETROMINO_TYPE
    # $t7: new value for TETROMINO_TYPE
    # $t9: colour
    
draw_new_tetromino:

    # Use random number generator to decide what type the tetromino will be
    li $v0, 42
    li $a0, 0
    li $a1, 7
    syscall                     # Will generate a random number between 0 and 6 (value stored in $a0)
    
    # Put parameters on the stack
    addi $t1, $zero, 0          # Initialize y offset
    lw $t0, STARTING_X_OFFSET   # Initialize x offset
    addi $sp, $sp, -4           # Update stack pointer
    sw $t1, 0($sp)              # Store y offset onto the stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t0, 0($sp)              # Store x offset into the stack
    
    beq $a0, 0, T_chosen        # If random number generated is 0, T-Tetromino is created
    beq $a0, 1, J_chosen        # If random number generated is 1, J-Tetromino is created
    beq $a0, 2, L_chosen        # If random number generated is 2, L-Tetromino is created
    beq $a0, 3, Z_chosen        # If random number generated is 3, Z-Tetromino is created
    beq $a0, 4, S_chosen        # If random number generated is 4, S-Tetromino is created
    beq $a0, 5, I_chosen        # If random number generated is 5, I-Tetromino is created
    beq $a0, 6, O_chosen        # If random number generated is 6, O-Tetromino is created
T_chosen:
    jal create_T_tetromino      # Create T-Tetromino
    lw $t9, PINK                # Store colour in $t9
    la $t2, T_TETROMINO         # Store tetromino address in $t2
    addi $t7, $zero, 116        # Store ascii value of t in $t7
    j finish_drawing            # Jump to rest of function
J_chosen:
    jal create_J_tetromino      # Create J-Tetromino
    lw $t9, BLUE                # Store colour in $t9
    la $t2, J_TETROMINO         # Store tetromino address in $t2
    addi $t7, $zero, 106        # Store ascii value of j in $t7
    j finish_drawing            # Jump to rest of function
L_chosen:
    jal create_L_tetromino      # Create L-Tetromino
    lw $t9, GREEN               # Store colour in $t9
    la $t2, L_TETROMINO         # Store tetromino address in $t2
    addi $t7, $zero, 108        # Store ascii value of l in $t7
    j finish_drawing            # Jump to rest of function
Z_chosen:
    jal create_Z_tetromino      # Create Z-Tetromino
    lw $t9, YELLOW              # Store colour in $t9
    la $t2, Z_TETROMINO         # Store tetromino address in $t2
    addi $t7, $zero, 122        # Store ascii value of z in $t7
    j finish_drawing            # Jump to rest of function
S_chosen:
    jal create_S_tetromino      # Create S-Tetromino
    lw $t9, PURPLE              # Store colour in $t9
    la $t2, S_TETROMINO         # Store tetromino address in $t2
    addi $t7, $zero, 115        # Store ascii value of s in $t7
    j finish_drawing            # Jump to rest of function
I_chosen:
    jal create_I_tetromino      # Create I-Tetromino
    lw $t9, INDIGO              # Store colour in $t9
    la $t2, I_TETROMINO         # Store tetromino address in $t2
    addi $t7, $zero, 105        # Store ascii value of i in $t7
    j finish_drawing            # Jump to rest of function
O_chosen:
    jal create_O_tetromino      # Create O-Tetromino
    lw $t9, ORANGE              # Store colour in $t9
    la $t2, O_TETROMINO         # Store tetromino address in $t2
    addi $t7, $zero, 111        # Store ascii value of o in $t7
    j finish_drawing            # Jump to rest of function

finish_drawing:
    la $t6 TETROMINO_TYPE       # Load address of TETROMINO_TYPE into $t6
    sw $t7, 0($t6)              # Store the new TETROMINO_TYPE value from $t7 in $t6

    addi $sp, $sp, -4           # Update stack pointer
    sw $t9, 0($sp)              # Store colour onto the stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t2, 0($sp)              # Store the array address onto the stack
    jal redraw_bitmap_copy
    jal draw_tetromino
    jal check_downward_collision    # Check if there is a collision
    j game_loop
    
game_loop:
	# 1a. Check if key has been pressed
	lw $t0, ADDR_KBRD              # Set $t0 to the address of the keyboard
	lw $t1, 0($t0)                 # Load the first word from the keyboard
	li $s4, 1000
	beq $t1, 1, key_pressed        # If key was pressed ($t1 == 1), jump to key_pressed
	
	# Code to increase speed of gravity
	beq $s5, $s7, if_current_time_equals_max_time
	else_current_time_dne_max_time:
	   addi $s5, $s5, 1
	   j pass
	if_current_time_equals_max_time:
	   li $s5, 0
	   beq $s6, $s4, pass
	   addi $s6, $s6, 5

	pass:
	j sleep                        # If key was not pressed, continue to rest of game_loop
    # 1b. Check which key has been pressed
key_pressed:
    lw $t2, 4($t0)                  # Load second word into $t2
    beq $t2, 97, pressed_a          # Check if a was pressed
    beq $t2, 115, pressed_s_start         # Check if s was pressed, if so check if there is a downward collision
    beq $t2, 100, pressed_d         # Check if d was pressed
    beq $t2, 119, pressed_w         # Check if w was pressed
    beq $t2, 113, pressed_q         # Check if q was pressed
    beq $t2, 112, pressed_p         # Check if p was pressed
    j sleep
    # 2a. Check for collisions (down-ward collisions are checked in the pressed_s branch)
    
    # When a is pressed, check if there is a collision on the left
    # When d is pressed, check if there is a collision on the right
    
    # For a and d, use TETROMINO and ROTATION to know the exact shape of the current tetromino being moved, therefore will know what index the left-most
    # or right-most pixel will be at, check if that pixel -4 for left is equal to wall colour or if pixel +4 for right is equal to wall colour. If 
    # equal to wall colour, do not update tetromino and go back to top of game_loop
    # Another strategy, current array address is provided, iterate through array, for left, check if every pixel - 4 is not the wall colour, for right,
    # check if every pixel + 4 is not the wall colour

    
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
sleep:
    lw $t3, GRAVITY_COUNTER          # Store current counter value
    la $t5, GRAVITY_COUNTER         # Load address to update later
    lw $t4, GRAVITY                 # Store value for GRAVITY in $t4
    
    li $v0, 32
    li $a0, 17
    syscall                            # Sleep for 17 milliseconds
    	
    bgt $t3, $t4, call_gravity         # When counter reaches value for GRAVITY, move tetromino down 1
    add $t3, $t3, $s6                   # Increase counter value by 1
    sw $t3, 0($t5)                     # Store updated value in GRAVITY_COUNTER
    b game_loop
	
call_gravity:
	jal pressed_s                      # move tetromino down
	lw $t3, GRAVITY_COUNTER          # Store current counter value
    la $t5, GRAVITY_COUNTER         # Load address to update later
	addi $t3, $zero, 0                 # Set counter back to 0
	sw $t3, 0($t5)                     # Reset counter back to 0

    #5. Go back to 1
     b game_loop
 
# --------------------------------------------------------------------------------------------------------------------------------------------------------
# Function to determine current array and corresponding colour
get_array_and_colour:
    # $t0: register to store TETRONIMO_TYPE
    # $t1: register to store ROTATION
    # $t2: register to store the colour
    # $v0: register to store the address to the array returned
    # $v1: register to store the array's starting position
    
    lw $t0, TETROMINO_TYPE          # Store the current tetromino type in $t0
    lw $t1, ROTATION                # Store the current tetromino type in $t1
    
    beq $t0, 116, T_tetromino       # Check if TETROMINO_TYPE is t
    beq $t0, 106, J_tetromino       # Check if TETROMINO_TYPE is j
    beq $t0, 108, L_tetromino       # Check if TETROMINO_TYPE is l
    beq $t0, 122, Z_tetromino       # Check if TETROMINO_TYPE is z
    beq $t0, 115, S_tetromino       # Check if TETROMINO_TYPE is s
    beq $t0, 105, I_tetromino       # Check if TETROMINO_TYPE is i
    beq $t0, 111, O_tetromino       # Check if TETROMINO_TYPE is o
    
T_tetromino:
    lw $t2, PINK                    # Store colour in $t2
    
    addi $sp, $sp, -4               # Update stack pointer
    sw $t2, 0($sp)                  # Store the colour on the stack
    
    beq $t1, 1, T_R1_tetromino      # Check if ROTATION is 1
    beq $t1, 2, T_R2_tetromino      # Check if ROTATION is 2
    beq $t1, 3, T_R3_tetromino      # Check if ROTATION is 3
    
    # Else, ROTATION is 0
    la $v0, T_TETROMINO             # Set $v0 to the T_TETROMINO array
    lw $v1, 4($v0)                  # Get starting position of T_TETROMINO (2nd element)
    jr $ra                          # Return
    
T_R1_tetromino:
    la $v0, T_TETROMINO_R1          # Set $v0 to the T_TETROMINO_R1 array
    lw $v1, 8($v0)                  # Get starting position of T_TETROMINO_R1 (3rd element)
    jr $ra                          # Return
T_R2_tetromino:
    la $v0, T_TETROMINO_R2          # Set $v0 to the T_TETROMINO_R2 array
    lw $v1, 8($v0)                  # Get starting position of T_TETROMINO_R2 (3rd element)
    jr $ra                          # Return
T_R3_tetromino:
    la $v0, T_TETROMINO_R3          # Set $v0 to the T_TETROMINO_R3 array
    lw $v1, 4($v0)                  # Get starting position of T_TETROMINO (2nd element)
    jr $ra                          # Return

J_tetromino:
    lw $t2, BLUE                    # Store colour in $t2
    
    addi $sp, $sp, -4               # Update stack pointer
    sw $t2, 0($sp)                  # Store the colour on the stack
    
    beq $t1, 1, J_R1_tetromino      # Check if ROTATION is 1
    beq $t1, 2, J_R2_tetromino      # Check if ROTATION is 2
    beq $t1, 3, J_R3_tetromino      # Check if ROTATION is 3
    
    # Else, ROTATION is 0
    la $v0, J_TETROMINO             # Set $v0 to the J_TETROMINO array
    lw $v1, 0($v0)                  # Get starting position of J_TETROMINO (1st element)
    jr $ra                          # Return
    
J_R1_tetromino:
    la $v0, J_TETROMINO_R1          # Set $v0 to the J_TETROMINO_R1 array
    lw $v1, 12($v0)                 # Get starting position of J_TETROMINO_R1 (4th element)
    jr $ra                          # Return
J_R2_tetromino:
    la $v0, J_TETROMINO_R2          # Set $v0 to the J_TETROMINO_R2 array
    lw $v1, 12($v0)                 # Get starting position of J_TETROMINO_R2 (4th element)
    jr $ra                          # Return
J_R3_tetromino:
    la $v0, J_TETROMINO_R3          # Set $v0 to the J_TETROMINO_R3 array
    lw $v1, 0($v0)                  # Get starting position of J_TETROMINO (1st element)
    jr $ra                          # Return

L_tetromino:
    lw $t2, GREEN                   # Store colour in $t2
    
    addi $sp, $sp, -4               # Update stack pointer
    sw $t2, 0($sp)                  # Store the colour on the stack
    
    beq $t1, 1, L_R1_tetromino      # Check if ROTATION is 1
    beq $t1, 2, L_R2_tetromino      # Check if ROTATION is 2
    beq $t1, 3, L_R3_tetromino      # Check if ROTATION is 3
    
    # Else, ROTATION is 0
    la $v0, L_TETROMINO             # Set $v0 to the L_TETROMINO array
    lw $v1, 0($v0)                  # Get starting poisition of L_TETROMINO (1st element)
    jr $ra                          # Return

L_R1_tetromino:
    la $v0, L_TETROMINO_R1          # Set $v0 to the L_TETROMINO_R1 array
    lw $v1, 8($v0)                  # Get starting position of L_TETROMINO_R1 (3rd element)
    jr $ra                          # Return
L_R2_tetromino:
    la $v0, L_TETROMINO_R2          # Set $v0 to the L_TETROMINO_R2 array
    lw $v1, 12($v0)                 # Get starting position of L_TETROMINO_R2 (4th element)
    jr $ra                          # Return
L_R3_tetromino:
    la $v0, L_TETROMINO_R3          # Set $v0 to the L_TETROMINO_R3 array
    lw $v1, 4($v0)                  # get starting position of L_TETROMINO_R3 (2nd element)
    jr $ra                          # Return

Z_tetromino:
    lw $t2, YELLOW                  # Store colour in $t2
    
    addi $sp, $sp, -4               # Update stack pointer
    sw $t2, 0($sp)                  # Store the colour on the stack
    
    beq $t1, 1, Z_R1_tetromino      # Check if ROTATION is 1
    beq $t1, 2, Z_R2_tetromino      # Check if ROTATION is 2
    beq $t1, 3, Z_R3_tetromino      # Check if ROTATION is 3
    
    # Else, ROTATION is 0
    la $v0, Z_TETROMINO             # Set $v0 to the Z_TETROMINO array
    lw $v1, 4($v0)                  # Get starting position for Z_TETROMINO (2nd element)
    jr $ra                          # Return

Z_R1_tetromino:
    la $v0, Z_TETROMINO_R1          # Set $v0 to the Z_TETROMINO_R1 array
    lw $v1, 8($v0)                  # Get starting position of Z_TETROMINO_R1 (3rd element)
    jr $ra                          # Return
Z_R2_tetromino:
    la $v0, Z_TETROMINO_R2          # Set $v0 to the Z_TETROMINO_R2 array
    lw $v1, 8($v0)                  # Get starting position of Z_TETROMINO_R2 (3rd element)
    jr $ra                          # Return
Z_R3_tetromino:
    la $v0, Z_TETROMINO_R3          # Set $v0 to the Z_TETROMINO_R3 array
    lw $v1, 4($v0)                  # Get starting position for Z_TETROMINO_R3 (2nd element)
    jr $ra                          # Return

S_tetromino:
    lw $t2, PURPLE                  # Store colour in $t2
    
    addi $sp, $sp, -4               # Update stack pointer
    sw $t2, 0($sp)                  # Store the colour on the stack
    
    beq $t1, 1, S_R1_tetromino      # Check if ROTATION is 1
    beq $t1, 2, S_R2_tetromino      # Check if ROTATION is 2
    beq $t1, 3, S_R3_tetromino      # Check if ROTATION is 3
    
    # Else, ROTATION is 0
    la $v0, S_TETROMINO             # Set $v0 to the S_TETROMINO array
    lw $v1, 0($v0)                  # Get starting position for S_TETROMINO (1st element)
    jr $ra                          # Return

S_R1_tetromino:
    la $v0, S_TETROMINO_R1          # Set $v0 to the S_TETROMINO_R1 array
    lw $v1, 8($v0)                  # Get starting position for S_TETROMINO_R1 (3rd element)
    jr $ra                          # Return
S_R2_tetromino:
    la $v0, S_TETROMINO_R2          # Set $v0 to the S_TETROMINO_R2 array
    lw $v1, 12($v0)                 # Get starting position for S_TETROMINO_R2 (4th element)
    jr $ra                          # Return
S_R3_tetromino:
    la $v0, S_TETROMINO_R3          # Set $v0 to the S_TETROMINO_R3 array
    lw $v1, 4($v0)                  # Get starting position for S_TETROMINO_R3 (2nd element)
    jr $ra                          # Return

I_tetromino:
    lw $t2, INDIGO                  # Store colour in $t2
    
    addi $sp, $sp, -4               # Update stack pointer
    sw $t2, 0($sp)                  # Store the colour on the stack
    
    beq $t1, 1, I_R1_tetromino      # Check if ROTATION is 1
    beq $t1, 2, I_R2_tetromino      # Check if ROTATION is 2
    beq $t1, 3, I_R3_tetromino      # Check if ROTATION is 3
    
    # Else, ROTATION is 0
    la $v0, I_TETROMINO             # Set $v0 to the I_TETROMINO array
    lw $v1, 0($v0)                  # Get starting position for I_TETROMINO (1st element)
    jr $ra                          # Return

I_R1_tetromino:
    la $v0, I_TETROMINO_R1          # Set $v0 to the I_TETROMINO_R1 array
    lw $v1, 12($v0)                 # Get starting position for I_TETROMINO_R1 (4th element)
    jr $ra                          # Return
I_R2_tetromino:
    la $v0, I_TETROMINO_R2          # Set $v0 to the I_TETROMINO_R2 array
    lw $v1, 12($v0)                 # Get starting position for I_TETROMINO_R2 (4th element)
    jr $ra                          # Return
I_R3_tetromino:
    la $v0, I_TETROMINO_R3          # Set $v0 to the I_TETROMINO_R3 array
    lw $v1, 0($v0)                  # Get starting position for I_TETROMINO_R3 (1st element)
    jr $ra                          # Return

O_tetromino:
    lw $t2, ORANGE                  # Store colour in $t2
    
    addi $sp, $sp, -4               # Update stack pointer
    sw $t2, 0($sp)                  # Store the colour on the stack
    
    beq $t1, 1, O_R1_tetromino      # Check if ROTATION is 1
    beq $t1, 2, O_R2_tetromino      # Check if ROTATION is 2
    beq $t1, 3, O_R3_tetromino      # Check if ROTATION is 3
    
    # Else, ROTATION is 0
    la $v0, O_TETROMINO             # Set $v0 to the O_TETROMINO array
    lw $v1, 0($v0)                  # Get starting position for O_TETROMINO (1st element)
    jr $ra                          # Return

O_R1_tetromino:
    la $v0, O_TETROMINO_R1          # Set $v0 to the O_TETROMINO_R1 array
    lw $v1, 4($v0)                  # Get starting position for O_TETROMINO_R1 (2nd element)
    jr $ra                          # Return
O_R2_tetromino:
    la $v0, O_TETROMINO_R2          # Set $v0 to the O_TETROMINO_R2 array
    lw $v1, 12($v0)                 # Get starting position for O_TETROMINO_R2 (4th element)
    jr $ra                          # Return
O_R3_tetromino:
    la $v0, O_TETROMINO_R3          # Set $v0 to the O_TETROMINO_R3 array
    lw $v1, 8($v0)                  # Get starting position for O_TETROMINO_R3 (3rd element)
    jr $ra                          # Return


#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Code to handle what key was pressed

rotate_sound_effect:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $v0, 31    # async play note syscall
    li $a0, 60    # midi pitch
    li $a1, 1000  # duration
    li $a2, 105     # instrument
    li $a3, 100   # volume
    syscall
    
end_rotate_sound_effect:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

key_pressed_in_paused:
    lw $t2, 4($t0)                  # Load second word into $t2
    beq $t2, 112, game_loop        # Check if p was pressed

pressed_p:
    jal draw_paused
    pressed_p_loop:
        lw $t0, ADDR_KBRD              
    	lw $t1, 0($t0)                
    	beq $t1, 1, key_pressed_in_paused
    	j pressed_p_loop
pressed_a:
    # $s0: register to store array address
    # $s1: register to store the colour of the pixel
    
    jal get_array_and_colour        # Get correct array and colour
    addi $s0, $v0, 0                # Set $s0 to be the array from the function
    lw $s1, 0($sp)                  # Remove the colour from the stack and store it in $s1
    addi $sp, $sp, 4                # Update stack pointer
    
    jal pre_left_collision_check
    
    # Update array to move one pixel to the left
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal move_left                   # Update the array to move one to the left
    
    addi $sp, $sp, -4               # Update stack pointer
    sw $s1, 0($sp)                  # Store colour onto the stack
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal redraw_background           # Redraw background
    jal redraw_bitmap_copy          # Redraw previously placed tetrominoes
    jal draw_tetromino              # Draw updated tetromino
    j game_loop

pressed_s_start:
    jal pressed_s
    j sleep
pressed_s:
    # $s0: register to store array address
    # $s1: register to store the colour of the pixel
    
    # Store $ra on the stack
    addi $sp, $sp, -4               # update stack pointer
    sw $ra, 0($sp)                  # Store $ra on stack pointer
    
    jal get_array_and_colour        # Get correct array and colour
    addi $s0, $v0, 0                # Set $s0 to be the array from the function
    lw $s1, 0($sp)                  # Remove the colour from the stack and store it in $s1
    addi $sp, $sp, 4                # Update stack pointer
    
    # Update array to move down one row
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal move_down                   # Update the array to move one row down
    
    
    addi $sp, $sp, -4               # Update stack pointer
    sw $s1, 0($sp)                  # Store colour onto the stack
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal redraw_background           # Redraw background
    jal redraw_bitmap_copy          # Redraw previously placed tetrominoes
    jal draw_tetromino              # Draw updated tetromino
    jal check_downward_collision    # Check if moved tetromino has collided
    lw $ra, 0($sp)                  # Remove $ra from stack pointer
    addi $sp, $sp, 4                # Update stack pointer
    jr $ra
    
    

pressed_d:
    # $s0: register to store array address
    # $s1: register to store the colour of the pixel
    
    jal get_array_and_colour        # Get correct array and colour
    addi $s0, $v0, 0                # Set $s0 to be the array from the function
    lw $s1, 0($sp)                  # Remove the colour from the stack and store it in $s1
    addi $sp, $sp, 4                # Update stack pointer
    
    jal pre_right_collision_check
    
    # Update array to move right by one pixel
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal move_right                  # Update the array to move one to the right
    
    addi $sp, $sp, -4               # Update stack pointer
    sw $s1, 0($sp)                  # Store colour onto the stack
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal redraw_background           # Redraw background
    jal redraw_bitmap_copy          # Redraw previously placed tetrominoes
    jal draw_tetromino              # Draw updated tetromino
    j game_loop
    
    
    
pressed_w:
    # $s0: register to store array address
    # $s1: register to store the colour of the pixel
    # $s2: register to store the starting position of the array stored in $s0
    # $t0: register to store the address for ROTATION
    # $t1: register to store the rotation number
    # $t2: register to store the address of the rotated tetromino
    # $t3: register to store the tetromino type
    # $t4: register to store the new rotation number
    
    jal get_array_and_colour        # Get correct array and colour
    addi $s0, $v0, 0                # Set $s0 to be the array from the function
    addi $s2, $v1, 0                # Set $s2 to be the starting position of the array stored in $s0
    lw $s1, 0($sp)                  # Remove the colour from the stack and store it in $s1
    addi $sp, $sp, 4                # Update stack pointer
    lw $t3, TETROMINO_TYPE          # Store value of TETROMINO_TYPE in $t3
    
    addi $sp, $sp, -4               # Update stack pointer
    sw $s2, 0($sp)                  # Put the starting position on the stack
    
    # Use ROTATION value to determine next tetromino position
    lw $t1, ROTATION                # Load the value of ROTATION into register $t1
    beq $t1, 0, go_to_R1            # Check if shape is at starting rotation position
    beq $t1, 1, go_to_R2            # Check if shape is at first rotation position
    beq $t1, 2, go_to_R3            # Check if shape is at second rotation position
    beq $t1, 3, go_to_R             # Check if shape is at third rotation position
    
go_to_R:
    addi $t4, $zero, 0              # Set new rotation value to be 0
    beq $t3, 116, T_R3_to_R         # Check if TETROMINO_TYPE is t
    beq $t3, 106, J_R3_to_R         # Check if TETROMINO_TYPE is j
    beq $t3, 108, L_R3_to_R         # Check if TETROMINO_TYPE is l
    beq $t3, 122, Z_R3_to_R         # Check if TETROMINO_TYPE is z
    beq $t3, 115, S_R3_to_R         # Check if TETROMINO_TYPE is s
    beq $t3, 105, I_R3_to_R         # Check if TETROMINO_TYPE is i
    beq $t3, 111, O_R3_to_R         # Check if TETROMINO_TYPE is o
T_R3_to_R:
    jal T_R3_to_R_tetromino         # Create T-Tetromino
    la $t2, T_TETROMINO             # Store address for T_TETROMINO in register $t2
    j pressed_w_continued           # Jump to the rest of the function
J_R3_to_R:
    jal J_R3_to_R_tetromino         # Create J-Tetromino
    la $t2, J_TETROMINO             # Store address for J_TETROMINO in register $t2
    j pressed_w_continued           # Jump to the rest of the function
L_R3_to_R:
    jal L_R3_to_R_tetromino         # Create L tetromino
    la $t2, L_TETROMINO             # Store address for L_TETROMINO in register $t2
    j pressed_w_continued           # Jump to the rest of the function
Z_R3_to_R:
    jal Z_R3_to_R_tetromino         # Create Z-Tetromino
    la $t2, Z_TETROMINO             # Store address for Z_TETROMINO in register $t2
    j pressed_w_continued           # Jump to the rest of the function
S_R3_to_R:
    jal S_R3_to_R_tetromino         # Create S-Tetromino
    la $t2, S_TETROMINO             # Store address for S_TETROMINO in register $t2
    j pressed_w_continued           # Jump to the rest of the function
I_R3_to_R:
    jal I_R3_to_R_tetromino         # Create I-Tetromino
    la $t2, I_TETROMINO             # Store address for I_TETROMINO in register $t2
    j pressed_w_continued           # Jump to the rest of the function
O_R3_to_R:
    jal O_R3_to_R_tetromino         # Create O-Tetromino
    la $t2, O_TETROMINO             # Store address for O_TETROMINO in register $t2
    j pressed_w_continued           # Jump to the rest of the function
    
go_to_R1:
    addi $t4, $zero, 1              # Set new rotation value to be 1
    beq $t3, 116, T_R_to_R1         # Check if TETROMINO_TYPE is t
    beq $t3, 106, J_R_to_R1         # Check if TETROMINO_TYPE is j
    beq $t3, 108, L_R_to_R1         # Check if TETROMINO_TYPE is l
    beq $t3, 122, Z_R_to_R1         # Check if TETROMINO_TYPE is z
    beq $t3, 115, S_R_to_R1         # Check if TETROMINO_TYPE is s
    beq $t3, 105, I_R_to_R1         # Check if TETROMINO_TYPE is i
    beq $t3, 111, O_R_to_R1         # Check if TETROMINO_TYPE is o
T_R_to_R1:
    jal create_T_R1_tetromino       # Create T-Tetromino after first rotation
    la $t2, T_TETROMINO_R1          # Store address for T_TETROMINO_R1 in register $t2
    j pressed_w_continued           # Jump to rest of function
J_R_to_R1:
    jal create_J_R1_tetromino       # Create J-Tetromino after its first rotation
    la $t2, J_TETROMINO_R1          # Store address for J_TETROMINO_R1 in register $t2
    j pressed_w_continued           # Jump to rest of function
L_R_to_R1:
    jal create_L_R1_tetromino       # Create L-Tetromino after its first rotation
    la $t2, L_TETROMINO_R1          # Store address for L_TETROMINO_R1 in register $t2
    j pressed_w_continued           # Jump to rest of funtion
Z_R_to_R1:
    jal create_Z_R1_tetromino       # Create Z-Tetromino after its first rotation
    la $t2, Z_TETROMINO_R1          # Store address for Z_TETROMINO_R1 in register $t2
    j pressed_w_continued           # Jump to rest of function
S_R_to_R1:
    jal create_S_R1_tetromino       # Create S-Tetromino after its first rotation
    la $t2, S_TETROMINO_R1          # Store address for S_TETROMINO_R1 in register $t2
    j pressed_w_continued           # Jump to rest of function
I_R_to_R1:
    jal create_I_R1_tetromino       # Create I-Tetromino after its first rotation
    la $t2, I_TETROMINO_R1          # Store address for I_TETROMINO_R1 in register $t2
    j pressed_w_continued           # Jump to rest of function
O_R_to_R1:
    jal create_O_R1_tetromino       # Create O-Tetromino after its first rotation
    la $t2, O_TETROMINO_R1          # Store address for O_TETROMINO_R1 in register $t2
    j pressed_w_continued           # Jump to rest of function
    
go_to_R2:
    addi $t4, $zero, 2              # Set new rotation value to be 2
    beq $t3, 116, T_R1_to_R2         # Check if TETROMINO_TYPE is t
    beq $t3, 106, J_R1_to_R2         # Check if TETROMINO_TYPE is j
    beq $t3, 108, L_R1_to_R2         # Check if TETROMINO_TYPE is l
    beq $t3, 122, Z_R1_to_R2         # Check if TETROMINO_TYPE is z
    beq $t3, 115, S_R1_to_R2         # Check if TETROMINO_TYPE is s
    beq $t3, 105, I_R1_to_R2         # Check if TETROMINO_TYPE is i
    beq $t3, 111, O_R1_to_R2         # Check if TETROMINO_TYPE is o
T_R1_to_R2:
    jal create_T_R2_tetromino       # Create T-Tetromino after its second rotation
    la $t2, T_TETROMINO_R2          # Store address for T_TETROMINO_R2 in register $t2
    j pressed_w_continued           # Jump to rest of function
J_R1_to_R2:
    jal create_J_R2_tetromino       # Create J-Tetromino after its second rotation
    la $t2, J_TETROMINO_R2          # Store address for J_TETROMINO_R2 in register $t2
    j pressed_w_continued           # Jump toi rest of function
L_R1_to_R2:
    jal create_L_R2_tetromino       # Create L-Tetromino after its second rotation
    la $t2, L_TETROMINO_R2          # Store address for L_TETROMINO_R2 in register $t2
    j pressed_w_continued           # Jump to rest of function
Z_R1_to_R2:
    jal create_Z_R2_tetromino       # Create Z-Tetromino after its second rotation
    la $t2, Z_TETROMINO_R2          # Store address for Z_TETROMINO_R2 in register $t2
    j pressed_w_continued           # Jump to rest of function
S_R1_to_R2:
    jal create_S_R2_tetromino       # Create S-Tetromino after its second rotation
    la $t2, S_TETROMINO_R2          # Store address for S_TETROMINO_R2 in register $t2
    j pressed_w_continued           # Jump to rest of function
I_R1_to_R2:
    jal create_I_R2_tetromino       # Create I-Tetromino after its second rotation
    la $t2, I_TETROMINO_R2          # Store address for I_TETROMINO_R2 in register $t2
    j pressed_w_continued           # Jump to rest of function
O_R1_to_R2:
    jal create_O_R2_tetromino       # Create O-Tetromino after its second rotation
    la $t2, O_TETROMINO_R2          # Store address for O_TETROMINO_R2 in register $t2
    j pressed_w_continued           # Jump to rest of function

go_to_R3:
    addi $t4, $zero, 3              # Set new rotation value to be 3
    beq $t3, 116, T_R2_to_R3         # Check if TETROMINO_TYPE is t
    beq $t3, 106, J_R2_to_R3         # Check if TETROMINO_TYPE is j
    beq $t3, 108, L_R2_to_R3         # Check if TETROMINO_TYPE is l
    beq $t3, 122, Z_R2_to_R3         # Check if TETROMINO_TYPE is z
    beq $t3, 115, S_R2_to_R3         # Check if TETROMINO_TYPE is s
    beq $t3, 105, I_R2_to_R3         # Check if TETROMINO_TYPE is i
    beq $t3, 111, O_R2_to_R3         # Check if TETROMINO_TYPE is o
T_R2_to_R3:
    jal create_T_R3_tetromino       # Create T-Tetromino after its third rotation
    la $t2, T_TETROMINO_R3          # Store address for T_TETROMINO_R3 in register $t2
    j pressed_w_continued           # Jump to rest of function
J_R2_to_R3:
    jal create_J_R3_tetromino       # Create J-Tetromino after its third rotatin
    la $t2, J_TETROMINO_R3          # Store address for J_TETROMINO in register $t2
    j pressed_w_continued           # Jump to rest of function
L_R2_to_R3:
    jal create_L_R3_tetromino       # Create L-Tetromino after its third rotatino
    la $t2, L_TETROMINO_R3          # Store address for L_TETROMINO_R3 in register $t2
    j pressed_w_continued           # Jump to rest of function
Z_R2_to_R3:
    jal create_Z_R3_tetromino       # Create Z-Tetromino after its third rotation
    la $t2, Z_TETROMINO_R3          # Store address for Z_TETROMINO_R3 in register $t2
    j pressed_w_continued           # Jump to rest of function
S_R2_to_R3:
    jal create_S_R3_tetromino       # Create S-Tetromino after its third rotation
    la $t2, S_TETROMINO_R3          # Store address for S_TETROMINO_R3 in register $t2
    j pressed_w_continued           # Jump to rest of function
I_R2_to_R3:
    jal create_I_R3_tetromino       # Create I-Tetromino after its third rotation
    la $t2, I_TETROMINO_R3          # Store address for I_TETROMINO_R3 in register $t2
    j pressed_w_continued           # Jump to rest of function
O_R2_to_R3:
    jal create_O_R3_tetromino       # Create O-Tetromino after its thirfd rotation
    la $t2, O_TETROMINO_R3          # Store address for O_TETROMNO_R3 in register $t2
    j pressed_w_continued           # Jump to rest of function

pressed_w_continued:   
    # Need to save value in $t2 and $t4 by putting on the stack
    addi $sp, $sp, -4               # Update stack pointer
    sw $t2, 0($sp)                  # Store value of $t2 on the stack
    addi $sp, $sp, -4               # Update stack pointer
    sw $t4, 0($sp)                  # Store value of $t4 on the stack
    # Put parameter on the stack
    addi $sp, $sp, -4               # Update stack popinter
    sw $t2, 0($sp)                  # Store the address of the rotated tetromino on the stack
    jal check_rotation_collision    # Check if there is any collision when rotating, continue if there is not
    jal rotate_sound_effect
    # Retrieve saved values from the stack
    lw $t4, 0($sp)                  # Load value back into $t4
    addi $sp, $sp, 4                # Update stack pointer
    lw $t2, 0($sp)                  # Load value back into $t2
    addi $sp, $sp, 4                # Update stack pointer
    la $t0, ROTATION                # Store address of ROTATION
    sw $t4, 0($t0)                  # Store value in $t4 as the new rotation number
    addi $sp, $sp, -4               # Update stack pointer
    sw $s1, 0($sp)                  # Store the colour on the stack
    addi $sp, $sp, -4               # Update stack pointer
    sw $t2, 0($sp)                  # Store the value of $t2 on the stack
    jal redraw_background           # Redraw background
    jal redraw_bitmap_copy          # Redraw previously placed tetrominoes
    jal draw_tetromino              # Draw tetromino
    j game_loop
    


pressed_q:
    li $v0, 10                      # Quit gracefully
	syscall
	
	
	
move_right:
    # $a0: register to store the original array's address
    # $t0: register to store the address at the current index
    # $t1: register to store the index
    # $t2: register to store the original value at element
    # $t3: register to store the updated address
    
    # Get parameters from the stack
    lw $a0, 0($sp)              # Get array address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    add $t0, $zero, $a0         # Set $t0 to starting array address
    addi $t1, $zero, 0          # Set index to 0
    
    # Iterate through the array provided
move_right_start:
    add $t0, $a0, $t1                   # Add index offset to the original address
    lw $t2, 0($t0)                      # Load value of array's current element
    addi $t3, $t2, 4                    # Add 4 to the original value and store it in $t2
    sw $t3, 0($t0)                      # Store the updated value in the array
    addi $t1, $t1, 4                    # Increment the index by 4
    beq $t1, 16, move_right_end         # If $t1 == 16, array has been fully iterated through, exit loop
    j move_right_start                  # If array has not been fully iterated through, go back to top of loop
move_right_end:
    jr $ra
    
    

move_left:
    # $a0: register to store the original array's address
    # $t0: register to store the address at the current index
    # $t1: register to store the index
    # $t2: register to store the original value at element
    # $t3: register to store the updated address
    
    # Get parameters from the stack
    lw $a0, 0($sp)              # Get array address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    add $t0, $zero, $a0         # Set $t0 to starting array address
    addi $t1, $zero, 0          # Set index to 0
    
    # Iterate through the array provided
move_left_start:
    add $t0, $a0, $t1                   # Add index offset to the original address
    lw $t2, 0($t0)                      # Load value of element at array's current index
    addi $t3, $t2, -4                   # Subtract 4 from the original value and store it in $t2
    sw $t3, 0($t0)                      # Store the updated value in the array
    addi $t1, $t1, 4                    # Increment the index by 4
    beq $t1, 16, move_left_end          # If $t1 == 16, array has been fully iterated through, exit loop
    j move_left_start                   # If array has not been fully iterated through, go back to top of loop
move_left_end:
    jr $ra



move_down:
    # $a0: register to store the original array's address
    # $t0: register to store the address at the current index
    # $t1: register to store the index
    # $t2: register to store the original value at element
    # $t3: register to store the updated address
    
    # Get parameters from the stack
    lw $a0, 0($sp)              # Get array address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    add $t0, $zero, $a0         # Set $t0 to starting array address
    addi $t1, $zero, 0          # Set index to 0
    
    # Iterate through the array provided
move_down_start:
    add $t0, $a0, $t1           # Add index offset to the original address
    lw $t2, 0($t0)              # Load value of element of array's current index
    addi $t3, $t2, 128          # Add 128 to the original value and store it in $t3
    sw $t3, 0($t0)              # Store the updated value in the array
    addi $t1, $t1, 4            # Increment the index by 4
    beq $t1, 16, move_down_end  # If $t1 == 16, array has been fully iterated through, exit loop
    j move_down_start           # If array has not been fully iterated through, go back to top of loop
move_down_end:
    jr $ra
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
# Collision Functions
check_downward_collision:
    # $t0: register to store the value of ROTATION
    # $t1: register to store the vale of TETROMINO_TYPE
    # $t2: register to store the address of the array of the current tetromino
    # $t3: register to store the value at the specified offset of the given array
    # $t4: register to store the address of the pixel below
    # $t5: register to store the colour at the specified address
    # $t6: register to store the address + index offset
    # $t9: register to store the address of ROTATION
    
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on store
    
    lw $t0, ROTATION            # Store the value of ROTATION in $t0
    lw $t1, TETROMINO_TYPE      # Store the value of TETROMINO_TYPE in $t1
    
    # Check rotation value and tetromino type to determine current tetromino
    beq $t1, 116, T             # If tetromino type is t, go to T section
    beq $t1, 106, J             # If tetromino type is j, go to J section
    beq $t1, 108, L             # If tetromino type is l, go to L section
    beq $t1, 122, Z             # If tetromino type is z, go to Z section
    beq $t1, 115, S             # If tetromino type is s, go to S section
    beq $t1, 105, I             # If tetromino type is i, go to I section
    beq $t1, 111, O             # If tetromino type is o, go to O section

T:
    beq $t0, 1, T_R1            # If rotation is 1, go to T_R1
    beq $t0, 2, T_R2            # If rotation is 2, go to T_R2
    beq $t0, 3, T_R3            # If rotation is 3, go to T_R3
    la $t2, T_TETROMINO         # Load the address of T tetromino in $t2
    # For normal T-Tetromino, the first, third and fourth are all pixels at the bottom, therefore need to check if they collide    
    addi $t6, $t2, 0            # Set $t6 to be addres + index offset of 0, to get first pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 8            # Set $t6 to be address + index offset of 8, to get third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be address + index offset of 12, to get fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached there is no collision   
T_R1:
    la $t2, T_TETROMINO_R1      # Load the address of the T_TETROMINO_R1 in $t2
    # For T_R1 tetromino, the second and fourth pixels are the ones on the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4, to get second pixel
    jal check_pixel_below       # Check if the pixel below is part of the checkerboard
    add $t6, $t2, 12            # Set $t6 to be the address + index offset of 12, to get fourth pixel
    jal check_pixel_below       # Check if pixel below is part of the checkerboard
    j no_collision              # If this is reached, there is no collision    
T_R2:
    la $t2, T_TETROMINO_R2      # Load the address of the T_TETROMINO_R2 in $t2
    # For T_R2 tetromino, the second, third and fourth pixels are the ones on the bottom of the tertromino, therefore need to check if they collide
    
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4 to get the second pixel
    jal check_pixel_below       # Check if the pixel below is part of the checkerboard
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below if part of the checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below if part of the checkerboard
    j no_collision              # If this is reached, there is no collision   
T_R3:
    la $t2, T_TETROMINO_R3      # Load the address of the T_TETROMINO_R3 in $t2
    # For T_R3 tetronimo, the thrid and fourth pixels are the ones on the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of the checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of the checkerboard
    j no_collision              # If this is reached, there is no collision
    
J:
    beq $t0, 1, J_R1            # If rotation is 1, go to J_R1
    beq $t0, 2, J_R2            # If rotation is 2, go to J_R2
    beq $t0, 3, J_R3            # If rotation is 3, go to J_R3
    la $t2, J_TETROMINO         # Load the address of J_TETROMINO in $t2
    # For J_TETROMINO, the third and fourth are the pixels at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8, to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached there is no collision
J_R1:
    la $t2, J_TETROMINO_R1      # Load the address of J_TETROMINO_R1 in $t2
    # For J_TETROMINO_R1, the second, third and fourth are the pixels at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4 to get the second pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth index
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
J_R2:
    la $t2, J_TETROMINO_R2      # Load the address of J_TETROMINO_R2 in $t2
    # For J_TETROMINO_R2, the second and fourth are the pixels at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4 to geth the second pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
J_R3:
    la $t2, J_TETROMINO_R3      # Load the address of J_TETROMINO_R3 in $t2
    # For J_TETROMINO_R3, the first, second, and fourth are the pixels at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 0            # Set $t6 to be the address + index offset of 0 to get the first pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 4            # Set $t6 to be the address + index ffset of 4 to get the second pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth index
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision

L:
    beq $t0, 1, L_R1            # If rotation is 1, go to L_R1
    beq $t0, 2, L_R2            # If rotation is 2, go to L_R2
    beq $t0, 3, L_R3            # If rotation is 3, go to L_R3
    la $t2, L_TETROMINO         # Load the address of L_TETROMINO in $t2
    # For L_TETROMINO, the third and fourth are the pixels at the bottom of the tretromino, therefore need to check if they collide
    
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
    
L_R1:
    la $t2, L_TETROMINO_R1      # Load the address of L_TETROMINO_R1 in $t2
    # For L_TETROMINO_R1, the second, third and fourth are the pixels at the bottom of the tretromino, therefore need to check if they collide
    
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4 to get the second pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # if this is reached, there is no collision
L_R2:
    la $t2, L_TETROMINO_R2      # Load the address of L_TETROMINO_R2 in $t2
    # For L_TETROMINO_R2, the first and fourth are the pixels at the bottom of the tretromino, therefore need to check if they collide
    
    addi $t6, $t2, 0            # Set $t6 to be the address + index offset of 0 to get the first pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
L_R3:
    la $t2, L_TETROMINO_R3      # Load the address of L_TETROMINO_R3 in $t2
    # For L_TETROMINO_R3, the second, third and fourth are the pixels at the bottom of the tretromino, therefore need to check if they collide
    
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4 to get the second pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # if this is reached, there is no collision

Z:
    beq $t0, 1, Z_R1            # If rotation is 1, go to Z_R1
    beq $t0, 2, Z_R2            # If rotation is 2, go to Z_R2
    beq $t0, 3, Z_R3            # If rotation is 3, go to Z_R3
    la $t2, Z_TETROMINO         # Load the address of Z_TETROMINO in $t2
    # For Z_TETROMINO, the first, third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 0            # Set $t6 to be address + index offset of 0, to get first pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 8            # Set $t6 to be address + index offset of 8, to get third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be address + index offset of 12, to get fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached there is no collision   
Z_R1:
    la $t2, Z_TETROMINO_R1      # Load the address of Z_TETROMINO_R1 in $t2
    # For Z_TETROMINO_R1, the third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
Z_R2:
    la $t2, Z_TETROMINO_R2      # Load the address of Z_TETROMINO_R2 in $t2
    # For Z_TETROMINO_R2, the first, third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 0            # Set $t6 to be address + index offset of 0, to get first pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 8            # Set $t6 to be address + index offset of 8, to get third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be address + index offset of 12, to get fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached there is no collision   
Z_R3:
    la $t2, Z_TETROMINO_R3      # Load the address of Z_TETROMINO_R3 in $t2
    # For Z_TETROMINO, the third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision

S:
    beq $t0, 1, S_R1            # If rotation is 1, go to S_R1
    beq $t0, 2, S_R2            # If rotation is 2, go to S_R2
    beq $t0, 3, S_R3            # If rotation is 3, go to S_R3
    la $t2, S_TETROMINO         # Load the address of S_TETROMINO in $t2
    # For S_TETROMINO, the second, third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4 to get the second pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # if this is reached, there is no collision
S_R1:
    la $t2, S_TETROMINO_R1      # Load the address of S_TETROMINO_R1 in $t2
    # For S_TETROMINO_R1, the second and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4 to geth the second pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
S_R2:
    la $t2, S_TETROMINO_R2      # Load the address of S_TETROMINO_R2 in $t2
    # For S_TETROMINO_R2, the second, third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4 to get the second pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # if this is reached, there is no collision
S_R3:
    la $t2, S_TETROMINO_R3      # Load the address of S_TETROMINO_R3 in $t2
    # For S_TETROMINO_R3, the second and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4 to geth the second pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision

I:
    beq $t0, 1, I_R1            # If rotation is 1, go to I_R1
    beq $t0, 2, I_R2            # If rotation is 2, go to I_R2
    beq $t0, 3, I_R3            # If rotation is 3, go to I_R3
    la $t2, I_TETROMINO         # Load the address of I_TETROMINO in $t2
    # For I_TETROMINO, the fourth is the pixel that is at the bottom of the tetromino, therefore need to check if it collides
    
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
I_R1:
    la $t2, I_TETROMINO_R1      # Load the address of I_TETROMINO_R1 in $t2
    # For I_TETROMINO_R1, the first, second, third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 0            # Set $t6 to be the address + index offset of 0 to get the first pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4 to get the second pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
I_R2:
    la $t2, I_TETROMINO_R2      # Load the address of I_TETROMINO_R2 in $t2
    # For I_TETROMINO_R2, the fourth is the pixel that is at the bottom of the tetromino, therefore need to check if it collides
    
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
I_R3:
    la $t2, I_TETROMINO_R3      # Load the address of I_TETROMINO_R3 in $t2
    # For I_TETROMINO_R3, the first, second, third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    addi $t6, $t2, 0            # Set $t6 to be the address + index offset of 0 to get the first pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 4            # Set $t6 to be the address + index offset of 4 to get the second pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision

O:
    beq $t0, 1, O_R1            # If rotation is 1, go to O_R1
    beq $t0, 2, O_R2            # If rotation is 2, go to O_R2
    beq $t0, 3, O_R3            # If rotation is 3, go to O_R3
    la $t2, O_TETROMINO         # Load the address of O_TETROMINO in $t2
    # For O_TETROMINO, third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
O_R1:
    la $t2, O_TETROMINO_R1      # Load the address of O_TETROMINO_R1 in $t2
    # For O_TETROMINO_R1, third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
O_R2:
    la $t2, O_TETROMINO_R2      # Load the address of O_TETROMINO_R2 in $t2
    # For O_TETROMINO_R2, third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
O_R3:
    la $t2, O_TETROMINO_R3      # Load the address of O_TETROMINO_R3 in $t2
    # For O_TETROMINO_R3, third, and fourth are the pixels that are at the bottom of the tetromino, therefore need to check if they collide
    
    addi $t6, $t2, 8            # Set $t6 to be the address + index offset of 8 to get the third pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    addi $t6, $t2, 12           # Set $t6 to be the address + index offset of 12 to get the fourth pixel
    jal check_pixel_below       # Check if pixel below is part of checkerboard
    j no_collision              # If this is reached, there is no collision
    
check_pixel_below:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    lw $t3, 0($t6)              # Store the bitmap address of the first pixel of the tetromino in $t3
    addi $t4, $t3, 128          # Add 128 to the pixel's address to get the pixel below
    lw $t5, 0($t4)              # Store the colour of the pixel in $t5
    jal check_first             # Check if colour matches checkerboard
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
check_first:
    bne $t5, 0x303030, check_second
    jr $ra
check_second:
    bne $t5, 0x202020, handle_collision
    jr $ra
handle_collision:
    # Play sound effect during collision
    li $v0, 31    # async play note syscall
    li $a0, 60    # midi pitch
    li $a1, 1000  # duration
    li $a2, 113     # instrument
    li $a3, 100   # volume
    syscall
    
    jal set_bitmap_copy             # Create a copy of the bitmap
    jal check_for_complete_lines    # Check to see if any lines have been completed and need clearing
    jal is_game_over                # Check if any tetrominoes reach the top
    la $t9, ROTATION                # Get address to write to ROTATION
    sw $zero, 0($t9)                # Change value of ROTATION to 0
    j draw_new_tetromino            # If there is a collision, create a new tetromino
no_collision:
    lw $ra, 0($sp)              # Remove $ra from stack pointer
    addi $sp, $sp, 4            # Update stack pointer
    jr $ra
    
    
    
check_for_complete_lines:
    # $a0: register to store the starting BITMAP_COPY address
    # $t0: register to store the offset from the start of the bitmap to the curent line
    # $t1: register to store the offset from the start of the line to the current pixel
    # $t2: register to store the current pixel location
    # $t3: register to hold the colour of the current pixel
    
    addi $sp, $sp, -4                   # Update stack pointer
    sw $ra, 0($sp)                      # Store $ra on the stack
    
check_for_complete_lines_again:         # Starting place for checking the lines after one has been cleared
    la $a0, BITMAP_COPY                 # Store the starting address for BITMAP_COPY in $a0
    addi $t0, $zero, 3844               # Set offset for start of bitmap to star of line to make the starting line the line just above the floor
    addi $t1, $zero, 0                  # Set current offset from current pixel to start of line to 0
    
check_for_complete_lines_start:
    add $t2, $a0, $t0                   # Add first offset to BITMAP_COPY starting address
    add $t2, $t2, $t1                   # Add second offset to $t2
    lw $t3, 0($t2)                      # Get colour at address $t2 and store it in $t3
    # Check what colour it is:
    beq $t3, 0x1f124a, same_as_wall     # Check if colour is the same as the wall
    beq $t3, 0x303030, checkerboard     # Check if colour is the same as the first checkerboard colour
    beq $t3, 0x202020, checkerboard     # Check if colour is the same as the second checkerboard colour
    # Else the colour of the pixel is one of the tetromino colours
    addi $t1, $t1, 4                    # Increment the offset from start of line to current pixel by 4 to get to the next pixel
    j check_for_complete_lines_start    # Jump back to top of loop
    
same_as_wall:
    addi $sp, $sp, -4                   # Update stack pointer
    sw $t0, 0($sp)                      # Put the offset from the start of the bitmap to the current line on the stack
    jal remove_line                     # Line is full and needs to be removed, lines are then re-checked

checkerboard:
    addi $t0, $t0, -128                 # Subtract 128 from the start to starting line offset to go to the next line above
    addi $t1, $zero, 0                  # Set offset from beggining of line to current pixel
    beq $t0, -124, finished             # When offset id equal to -124, all lines have been checked
    j check_for_complete_lines_start    # Else, have not finished checking lines, go back to beginning of loop
    
finished:
    lw $ra, 0($sp)                      # Remove value of $ra from the stack
    addi $sp, $sp, 4                    # Update stack pointer
    jr $ra

remove_line:
    # $a0: register to store the starting BITMAP_COPY address
    # $a1: register to store the starting BACKGROUND address
    # $t0: register to store the offset from the start of the bitmap to the curent line
    # $t1: register to store the offset from the start of the line to the current pixel
    # $t2: register to store the current pixel location for the current line
    # $t3: register to hold the colour of the current pixel on the line above
    # $t4: register to store the offset from the start of the bitmap to the line above
    # $t5: register to store the current pixel location for the line above
    # $t6: register to store the current address being accessed in BACKGROUND
    # $t7: register to store the colour from BACKGROUND
    
    lw $t0, 0($sp)                      # Load the offset value off the stack into $t0
    addi $sp, $sp, 4                    # Update stack pointer
    
    la $a0, BITMAP_COPY                 # Store starting address for BITMAP_COPY in $a0
    la $a1, BACKGROUND                  # store starting address for BACKGROUND in $a1
    addi $t4, $t0, -128                 # Subtract 128 from the offset of the current line to get the offset for the line above
    addi $t1, $zero, 0                  # Set offset from start of line to current pixel to 0
    
remove_line_start:
    add $t2, $a0, $t0                   # Add first offset to get to the correct line
    add $t2, $t2, $t1                   # Add second offset to get to the correct pixel
    
    add $t5, $a0, $t4                   # Add first offset to get to the line above the current lin
    add $t5, $t5, $t1                   # Add second offset to have same horizontal offset as the current line
    lw $t3, 0($t5)                      # Store the colour if the pixel in the line above in register $t3
    # Check the colour stored in $t3:
    beq $t3, 0x1f124a, finished_line    # If same colour as the wall, the line has been fully traversed, need to move to the next line above
    beq $t3, 0x303030, not_tetromino    # If the colour is the same as the first checkerboard colour need to use BACKGROUND to find correct colour
    beq $t3, 0x202020, not_tetromino    # If the colour is the same as the second checkerboard colour need to use BACKGROUND to find correct colour
    # Else, the colour of the pixel is a tetromino colour
    sw $t3, 0($t2)                      # Set the current pixel for the current line to be the colour stored in $t3
    addi $t1, $t1, 4                    # Increment the horizontal offset by 4 to go to the next pixel
    j remove_line_start                 # Jump to the start of the loop
 
not_tetromino:
    add $t6, $a1, $t0                   # Add the first offset to get the current line
    add $t6, $t6, $t1                   # Add the second offset to get the pixel
    lw $t7, 0($t6)                      # Get the colour stored at $t6 and store it in $t7
    sw $t7, 0($t2)                      # Store the colour from $t7 in the address stored in $t2
    addi $t1, $t1, 4                    # Increment the horizontal offset by 4 to go to the next pixel
    j remove_line_start                 # Jump to the start of the loop
    
finished_line:
    addi $t1, $zero, 0                  # Set horizontal offset to 0
    addi $t0, $t0, -128                 # Subtract 128 from current line to get to the line above
    addi $t4, $t4, -128                 # Subtract 128 from the above line's offset to get the offset of the line above the new current line
    beq $t4, -124, finished_removal     # Check if the line above is a valid line on the bitmap
    j remove_line_start                 # If not finished, go back to start of loop for the new line

finished_removal:
    # Play clear line sound effect
    li $v0, 31    # async play note syscall
    li $a0, 60    # midi pitch
    li $a1, 2000  # duration
    li $a2, 60     # instrument
    li $a3, 100   # volume
    syscall
    
    j check_for_complete_lines_again    # Re-check the lines
    
is_game_over:
    # $a0: register to store the starting address for BITMAP_COPY
    # $t0: register to store the horizontal offset
    # $t1: register to store the address for the current pixel
    # $t2: register to store the colour of the current pixel
    
    la $a0, BITMAP_COPY                 # Store the starting address for BITMAP_COPY in $a0
    addi $t0, $zero, 4                  # Set initial horizontal offste to 4 to get the first pixel after the left wall
    
is_game_over_start:
    add $t1, $a0, $t0                   # Add starting address to offsetr to get the current pixel
    lw $t2, 0($t1)                      # Get the colour from $t1 and store it in $t2
    # Check the colour of the pixel
    beq $t2, 0x1f124a, game_not_over    # Check if colour is the wall to see when line is over, game is not over
    beq $t2, 0xff3c8c, game_over        # Check if colour is PINK
    beq $t2, 0x00d4ff, game_over        # Check if colour is BLUE
    beq $t2, 0x00ff24, game_over        # Check if colour is GREEN
    beq $t2, 0xfff300, game_over        # Check if colour is YELLOW
    beq $t2, 0xce86ff, game_over        # Check if colour is PURPLE
    beq $t2, 0x5d57ff, game_over        # Check if colour is INDIGO
    beq $t2, 0xff8300, game_over        # Check if colour is ORANGE
    addi $t0, $t0, 4                    # Else, increment $t0 by 4 to get to the next pixel
    j is_game_over_start                # Jump back to top of loop

game_not_over:
    jr $ra                              # Game is not over

restart:
    lw $t3, 4($t0)
    beq $t3, 113, pressed_q
    beq $t3, 114, main              # Check if r was pressed, then restart
    
game_over:
    li $v0, 31    # async play note syscall
    li $a0, 60    # midi pitch
    li $a1, 1000  # duration
    li $a2, 18   # instrument
    li $a3, 100   # volume
    syscall
    
    lw $t0, ADDR_DSPL
    lw $t1, RED
    
    jal draw_game_over
    game_over_loop:
        lw $t0, ADDR_KBRD
        lw $t2, 0($t0)
        beq $t2, 1, restart         # Check for keyboard input
        
        li $v0, 32
        li $a0, 300
        syscall                            # Sleep for 300 milliseconds
        
        # Draw flashing line under R
        lw $t0, ADDR_DSPL
        lw $t1, WHITE
        addi $t0, $t0, 3972
        addi $t2, $zero, 0
        addi $t3, $zero, 5
        jal draw_horizontal_line
        
        li $v0, 32
        li $a0, 300
        syscall                            # Sleep for 300 milliseconds
        
        lw $t0, ADDR_DSPL
        lw $t1, DARK_PURPLE
        addi $t0, $t0, 3972
        addi $t2, $zero, 0
        addi $t3, $zero, 5
        jal draw_horizontal_line
        
        j game_over_loop
    
check_rotation_collision:
    # $a0: starting address for tetromino array given
    # $t0: index for iterating through the array stored in $a0
    # $t1: current array address being looked at
    # $t2: value stored in address stored by $t1
    # $t3: colour of pixel at $t7
    # $t4: starting address for bitmap
    # $t5: offset between current pixel address ($t2) and starting address for bitmap ($t4)
    # $t6: Starting address for BITMAP_COPY
    # $t7: current address being looked at in BITMAP_COPY
    
    lw $a0, 0($sp)                      # Load address of array into register $a0
    addi $sp, $sp, 4                    # Update stack pointer
    addi $t0, $zero, 0                  # Set index to 0
    la $t6, BITMAP_COPY                 # Store starting address of BITMAP_COPY in $t6
    lw $t4, ADDR_DSPL                   # Store starting address for bitmap in $t4
    
check_rotation_collision_start:
    add $t1, $a0, $t0                   # Add index to starting address to get current address
    lw $t2, 0($t1)                      # Store bitmap address of tetromino pixel in $t2
    subu $t5, $t2, $t4                  # Subtract starting bitmap address from current address to get offset
    bltz $t5, game_loop                 # If result from subtraction is less than 0, rotation will go out of bitmap bounds, therefore cannot rotate
    add $t7, $t6, $t5                   # Add offset calculated to starting address
    lw $t3, 0($t7)                      # Store colour of current pixel in $t3
    # Check colour, if one pixel is the colour of the wall or a tetromino, then a collision will occur, so do not rotate, go back to beginning of game_loop
    beq $t3, 0xff3c8c, game_loop        # Check if pixel on bitmap is PINK
    beq $t3, 0x00d4ff, game_loop        # Check if pixel on bitmap is BLUE
    beq $t3, 0x00ff24, game_loop        # Check if pixel on bitmap is GREEN
    beq $t3, 0xfff300, game_loop        # Check if pixel on bitmap is YELLOW
    beq $t3, 0xce86ff, game_loop        # Check if pixel on bitmap is PURPLE
    beq $t3, 0x5d57ff, game_loop        # Check if pixel on bitmap is INDIGO
    beq $t3, 0xff8300, game_loop        # Check if pixel on bitmap is ORANGE
    beq $t3, 0x1f124a, game_loop        # Check if pixel on bitmap is part of the wall
    # Else, pixel on bitmap is the bakcground so no collision for this pixel, move on to next pixel
    addi $t0, $t0, 4                                # Increment index by 4 to get to the next pixel
    bne $t0, 16, check_rotation_collision_start     # If $t0 is not equal to 16, jump back to start of loop
    jr $ra                                          # If this is reached, all pixel is clear of any collision, can rotate
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
# Functions for general drawing and setting  
set_rectangle:
    # Make a rectangle but instead of drawing to the bitmap, store into the given array
    
    # $a0: register to store original x offset
    # $a1: register to store original y offset
    # $t0: register for starting address
    # $t1: register to store x offset
    # $t2: register to store y offset
    # $t3: register to store width in pixels
    # $t4: register to store the length in pixels
    # $t5: register to store current address
    # $t6: register to store current array index
    # $t7: register to store the address of array[i]
    # $t9: register to store array[0]
    
    lw $t0, ADDR_DSPL           # set $t0 to starting address
    lw $a0, 0($sp)              # Get x offset from the stack
    addi $sp, $sp, 4            # Update stack pointer 
    addi $t1, $a0, 0            # Set $t1 to $a0
    lw $a1, 0($sp)              # Get y offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    addi $t2, $a1, 0            # Set $t2 to $a1
    lw $t3, 0($sp)              # Get width from the stack
    addi $sp, $sp, 4            # Update stack pointer
    lw $t4, 0($sp)              # Get length from the stack
    addi $sp, $sp, 4            # Update stack pointer
    lw $t6, 0($sp)              # Get starting index from the stack
    addi $sp, $sp, 4            # Update the stack
    lw $t9, 0($sp)              # Get array from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # Index offset
    sll $t6, $t6, 2             # Calculate off set of index
    
    # Horizontal offset and width
    sll $t1, $a0, 2             # Calculate horizontal offset (x offset * 4)
    sll $t3, $t3, 2             # Convert the width from pixels to bytes (multiply by 4)
    add $t3, $t3, $t1           # Add original starting point to width to get end width
    
    # Vertical offset and length
    sll $t2, $t2, 7             # Calculate vertical offset (y offset * 128)
    sll $t4, $t4, 7             # Convert the length from pixels to bytes (multiply by 128)
    add $t4, $t4, $t2           # Add original starting point to the length to get the end length
    
set_rectangle_top:
    sll $t1, $a0, 2             # Calculate horizontal offset (x offset * 4)
    add $t5, $t1, $t2           # Update current offset value where the pixel will be drawn
    
set_line_top:
    add $t5, $t1, $t2                   # Calculate total offset
    add $t5, $t5, $t0                   # Add offset to starting address
    add $t7, $t9, $t6                   # $t7 holds the array at index offset i
    sw $t5, 0($t7)                      # Store the value of $t5 in array at index i
    addi $t6, $t6, 4                    # Increment index
    addi $t1, $t1, 4                    # Increment horizontal offset
    beq $t1, $t3, set_line_end          # Check if offset == width, if so exit loop
    j set_line_top                      # Jump back to top of loop
    
set_line_end:
    addi $t2, $t2, 128                  # Increment the vertical offset
    beq $t2 ,$t4, set_rectangle_end     # Check if length offset == end length, if so exit loop
    j set_rectangle_top                # Jump back to top of loop
    
set_rectangle_end:
    jr $ra                      # return


draw_tetromino:
    # $a0: register to store the original array's address
    # $a1: register to store the colour
    # $t0: register to store the value the ith element in the array
    # $t1: register to store the index
    # $t2: register to store value of current array element
    
    # Get parameters from the stack
    lw $a0, 0($sp)              # Get array address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    lw $a1, 0($sp)              # Get colour from the stack
    addi, $sp, $sp, 4           # Update stack pointer
    
    add $t0, $zero, $a0         # Set $t0 to starting array address
    addi $t1, $zero, 0          # Set index to 0
    
    # Iterate through the array provided
draw_tetromino_start:
    add $t0, $a0, $t1                   # Add index offset to original address
    lw $t2, 0($t0)                      # Store bitmap address in $t2
    sw $a1, 0($t2)                      # Draw pixel on bitmap
    add $t1, $t1, 4                     # Increment index by 4
    beq $t1, 16, draw_tetromino_end     # If $t1 == 16, array has been fully iterated through, exit loop
    j draw_tetromino_start              # If array has not been fully iterates through, go back to top of loop
draw_tetromino_end:
    jr $ra                      # return
    
    
    
set_bitmap_copy:
    # $t0: register to store the starting address for the bitmap
    # $t1: register to store the address for BITMAP_COPY
    # $t2: register to store the current address of BITMAP_COPY being written to
    # $t3: register to store the current bitmap address being accessed
    # $t4: register to store the current index offset
    # $t5: register to store the colour value at $
    # $t6: register to store the end index offset value (1024 * 4)
    
    lw $t0, ADDR_DSPL       # Store the display starting address in $t0
    la $t1, BITMAP_COPY      # Store the starting address for BITMAP_COPY array
    
    addi $t4, $zero, 0      # Set index offset to 0
    addi $t6, $zero, 1024   # Set end index offset value to be 1024
    sll $t6, $t6, 2         # Multiply index offset by 4

set_bitmap_start:
    add $t2, $t1, $t4                   # Set current address being written to to be the starting address + index offset
    add $t3, $t0, $t4                   # Set current address of bitmap being accessed to be the starting address + index offset
    lw $t5, 0($t3)                      # Store the colour at the current bitmap address in $t3
    sw $t5, 0($t2)                      # Write the colour stored in $t5 to the current address location in BITMAP_COPY array
    addi $t4 $t4, 4                     # Increment the index offset by 4 to go to the next array element
    beq $t4, $t6, set_bitmap_end        # Check if index offset has reached the end of the bitmap
    j set_bitmap_start                  # Jump back to top of loop
set_bitmap_end:
    jr $ra
    


redraw_bitmap_copy:
    # $t0: register to store the starting address for the bitmap
    # $t1: register to store the address for BITMAP_COPY
    # $t2: register to store the current address of BITMAP_COPY being written to
    # $t3: register to store the current bitmap address being accessed
    # $t4: register to store the current index offset
    # $t5: register to store the colour value at $
    # $t6: register to store the end index offset value (1024 * 4)
    
    lw $t0, ADDR_DSPL       # Store the display starting address in $t0
    la $t1, BITMAP_COPY      # Store the starting address for BITMAP_COPY array
    
    addi $t4, $zero, 0      # Set index offset to 0
    addi $t6, $zero, 1024   # Set end index offset value to be 1024
    sll $t6, $t6, 2         # Multiply index offset by 4

redraw_bitmap_start:
    add $t2, $t1, $t4                       # Set current address being written to to be the starting address + index offset
    add $t3, $t0, $t4                       # Set current address of bitmap being accessed to be the starting address + index offset
    lw $t5, 0($t2)                          # Store the colour at the current BITMAP_COPY address in $t3
    sw $t5, 0($t3)                          # Write the colour stored in $t5 to the current bitmap address
    addi $t4 $t4, 4                         # Increment the index offset by 4 to go to the next array element
    beq $t4, $t6, redraw_bitmap_end     # Check if index offset has reached the end of the bitmap
    j redraw_bitmap_start               # Jump back to top of loop
redraw_bitmap_end:
    jr $ra
# -----------------------------------------------------------------------------------------------------------------------------
# Functions for drawing background
draw_checkboard:
    beq $t5, $t6, wall_drawing      # go back to main after checkboard is finished
    addi $t5, $t5, 1                # increment counter
    add $t3, $zero, $zero           # re-initialize loop counters
    addi $t4, $zero, 16
    jal start_row_1
    add $t3, $zero, $zero           # re-initialize loop counters
    addi $t4, $zero, 16
    jal start_row_2
    j draw_checkboard
end_draw_checkboard:
    jr $ra
    
start_row_1:
    beq $t3, $t4, end_row_1
    sw $t1, 0($t0) 		# paint the first pixel dark grey
    addi $t0, $t0, 4   	# move to the next pixel over in the bitmap
    sw $t2, 0($t0) 		# paint the second pixel light grey
    addi $t0, $t0, 4   	# move to the next pixel over in the bitmap
    addi $t3, $t3, 1
    j start_row_1
end_row_1:
    jr $ra

start_row_2:
    beq $t3, $t4, end_row_2
    sw $t2, 0($t0) 		# paint the first pixel light grey
    addi $t0, $t0, 4   	# move to the next pixel over in the bitmap
    sw $t1, 0($t0) 		# paint the second pixel dark grey
    addi $t0, $t0, 4   	# move to the next pixel over in the bitmap
    addi $t3, $t3, 1
    j start_row_2
end_row_2:
    jr $ra
    
# Drawing the walls of the game
draw_left_wall:
    beq $t5, $t6, end_draw_left_wall
    sw $t7, 0($t0) 		# paint first value at offset
    addi $t0, $t0, 128  # increment memory position
    addi $t5, $t5, 1    # increment loop counter 
    j draw_left_wall
end_draw_left_wall:
    jr $ra

draw_right_wall:
    beq $t5, $t6, end_draw_right_wall
    sw $t7, 124($t0)    # paint first value at offset
    addi $t0, $t0, 128  # increment memory position
    addi $t5, $t5, 1    # increment loop counter 
    j draw_right_wall
end_draw_right_wall:
    jr $ra

draw_floor:
    beq $t5, $t6, end_draw_floor
    sw $t7, 3968($t0)   # paint first value at offset
    addi $t0, $t0, 4    # increment memory position
    addi $t5, $t5, 1    # increment loop counter 
    j draw_floor
end_draw_floor:
    jr $ra
    
    
    
draw_background:
    # Need to store $ra in the stack 
    addi $sp, $sp, -4   # Update stack pointer
    sw $ra, 0($sp)      # Store $ra on the stack
    
    lw $t0, ADDR_DSPL   # $t0 stores the base address for display
    lw $t1, LIGHT_GREY  # $t1 stores one of the bg colours
    lw $t2, DARK_GREY   # $t2 stores another one of the bg colours
    lw $t7, DARK_PURPLE
    
    add $t5, $zero, $zero # initialize loop variables
    addi $t6, $zero, 16 
    jal draw_checkboard
    
    wall_drawing:
        lw $t0, ADDR_DSPL # re-initialize loop variables and address
        add $t5, $zero, $zero 
        addi $t6, $zero, 32
        jal draw_left_wall
        
        lw $t0, ADDR_DSPL # re-initialize loop variables and address
        add $t5, $zero, $zero
        addi $t6, $zero, 32
        jal draw_right_wall
        
        lw $t0, ADDR_DSPL # re-initialize loop variables and address
        add $t5, $zero, $zero
        addi $t6, $zero, 32
        jal draw_floor
        
        lw $ra, 0($sp)      # Remove $ra from the stack
        addi $sp, $sp, 4    # Update stack pointer
        jr $ra              # Return


set_background:
    # $t0: register to store the starting address for the bitmap
    # $t1: register to store the address for BACKGROUND
    # $t2: register to store the current address of BACKGROUND being written to
    # $t3: register to store the current bitmap address being accessed
    # $t4: register to store the current index offset
    # $t5: register to store the colour value at $
    # $t6: register to store the end index offset value (1024 * 4)
    
    lw $t0, ADDR_DSPL       # Store the display starting address in $t0
    la $t1, BACKGROUND      # Store the starting address for BACKGROUND array
    
    addi $t4, $zero, 0      # Set index offset to 0
    addi $t6, $zero, 1024   # Set end index offset value to be 1024
    sll $t6, $t6, 2         # Multiply index offset by 4

set_background_start:
    add $t2, $t1, $t4                   # Set current address being written to to be the starting address + index offset
    add $t3, $t0, $t4                   # Set current address of bitmap being accessed to be the starting address + index offset
    lw $t5, 0($t3)                      # Store the colour at the current bitmap address in $t3
    sw $t5, 0($t2)                      # Write the colour stored in $t5 to the current address location in BACKGROUND array
    addi $t4 $t4, 4                     # Increment the index offset by 4 to go to the next array element
    beq $t4, $t6, set_background_end    # Check if index offset has reached the end of the bitmap
    j set_background_start              # Jump back to top of loop
set_background_end:
    jr $ra
    
    
    
redraw_background:
    # $t0: register to store the starting address for the bitmap
    # $t1: register to store the address for BACKGROUND
    # $t2: register to store the current address of BACKGROUND being written to
    # $t3: register to store the current bitmap address being accessed
    # $t4: register to store the current index offset
    # $t5: register to store the colour value at $
    # $t6: register to store the end index offset value (1024 * 4)
    
    lw $t0, ADDR_DSPL       # Store the display starting address in $t0
    la $t1, BACKGROUND      # Store the starting address for BACKGROUND array
    
    addi $t4, $zero, 0      # Set index offset to 0
    addi $t6, $zero, 1024   # Set end index offset value to be 1024
    sll $t6, $t6, 2         # Multiply index offset by 4

redraw_background_start:
    add $t2, $t1, $t4                       # Set current address being written to to be the starting address + index offset
    add $t3, $t0, $t4                       # Set current address of bitmap being accessed to be the starting address + index offset
    lw $t5, 0($t2)                          # Store the colour at the current BACKGROUND address in $t3
    sw $t5, 0($t3)                          # Write the colour stored in $t5 to the current bitmap address
    addi $t4 $t4, 4                         # Increment the index offset by 4 to go to the next array element
    beq $t4, $t6, redraw_background_end     # Check if index offset has reached the end of the bitmap
    j redraw_background_start               # Jump back to top of loop
redraw_background_end:
    jr $ra
    

# -------------------------------------------------------------------------------------------------------------------------------------------------------
# Functions for T-Tetromino
create_T_tetromino:
    # $a0: register to store original x offset value from the stack
    # $a1: register to store original y offset value from the stack
    # $t0: register to store x offset
    # $t1: register to store y offset
    # $t2: register to store width
    # $t3: register to store length
    # $t4: register to store array index
    # $t9: register to store the array at index 0
    
    # Get values from the stack
    lw $a0, 0($sp)              # Get starting position x offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    addi $t0, $a0, 0            # Store x offset in $t0
    lw $a1, 0($sp)              # Get starting position y offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    addi $t1, $a1, 0            # Store y offset on $t1
    
    la $t9, T_TETROMINO         # Store the starting address in $t9
    addi $t4, $zero, 0          # Set array index to 0
    
    # Modify x offset to draw the 3 pixel horizontal line
    addi $t0, $t0, -1           # Subtract 1 so position is at the start of the line
    addi $t2, $zero, 3          # Store width value in $t2
    addi $t3, $zero, 1          # Store length value in $t3
    
    # Put parameters onto the stack
    # Need to save the values of $a0, $a1, and $t9 for later
    addi $sp, $sp, -4           # Update the stack pointer
    sw $ra, 0($sp)              # Store $ra on the stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $a0, 0($sp)              # Store value of $a0 on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $a1, 0($sp)              # Store value of $a1 on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t9, 0($sp)              # Store value of $t9 on stack
    # Need to pass the values of $t0, $t1, $t2, $t3, and $t9 to the function
    addi $sp, $sp, -4           # Update stack pointer
    sw $t9, 0($sp)              # Store value of $t9 (starting address) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t4, 0($sp)              # Store the value of $t4 (array index) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t3, 0($sp)              # Store value of $t3 (length) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t2, 0($sp)              # Store value of $t2 (width) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t1, 0($sp)              # Store value of $t1 (y offset) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t0, 0($sp)              # Store value of $t0 (x offset) on stack
    jal set_rectangle           # Call function to set line
    
    # Take parameters off of the stack
    lw $t9, 0($sp)              # Remove array address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    lw $t1, 0($sp)              # Remove original y offset from the stack
    addi $sp, $sp 4             # Update stack pointer
    lw $t0, 0($sp)              # Remove original x offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # Modify values
    addi $t1, $t1, 1            # Modify y offset to set the 1 pixel below
    addi $t2, $zero, 1          # Set width to 1
    addi $t3, $zero, 1          # Set height to 1
    addi $t4, $zero, 3          # Set array index to 3
    # Put parameters onto the stack
    # Need to pass the values of $t0, $t1, $t2, $t3, and $t9 to the function
    addi $sp, $sp, -4           # Update stack pointer
    sw $t9, 0($sp)              # Store value of $t9 (array address) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t4, 0($sp)              # Store value of $t4 (array index) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t3, 0($sp)              # Store value of $t3 (length) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t2, 0($sp)              # Store value of $t2 (width) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t1, 0($sp)              # Store value of $t1 (y offset) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t0, 0($sp)              # Store value of $t0 (x offset) on stack
    jal set_rectangle           # Call function to set line
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update stack pointer
    jr $ra                      # return
    
 
    
create_T_R1_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the T_TETROMINO_R1 array
    # $t1: register to store the current index
    # $t2: register to store current address being written to
    # $t9: register to store the starting address for the T_TETROMINO_R1 array
    # Given the starting position's current address, not the offset from the starting address
    
    la $t9, T_TETROMINO_R1      # Store the starting address of T_TETROMINO_R1 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    add $t0, $zero, $a0         # Set register $t0 to be the starting address given 
    addi $t0, $t0, -128         # Subtract 128 to get pixel above starting posiiton
    sw $t0, 0($t2)              # Store the pixel address in $t0 at the first index
    
    addi $t1, $t1, 4            # Set index to get second element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -4           # Set $t0 to be the pixel before the starting position
    sw $t0, 0($t2)              # Store the pixel address as the second element
    
    addi $t1, $t1, 4            # Set index to get third element
    add $t2, $t9, $t1           # Store address for the third element in $t2
    add $t0, $zero, $a0         # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store the pixel address as the second element
    
    addi $t1, $t1, 4            # Set index to get the fourth element
    add $t2, $t9, $t1           # Store addresss for the fourth element in $t2
    addi $t0, $a0, 128          # Set $t0 to be the pixel below the starting position
    sw $t0, 0($t2)              # Store the pixel address as the second element
    jr $ra                      # Return
    
    
    
create_T_R2_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the T_TETROMINO_R2 array
    # $t1: register to store the current index
    # $t2: register to store current address being written to
    # $t9: register to store the starting address for the T_TETROMINO_R2 array
    # Given the starting position's current address, not the offset from the starting address
    
    la $t9, T_TETROMINO_R2      # Store the array address in register $t9
    
    lw $a0, 0($sp)              # Get starting position's address on bitmap from the stack
    addi $sp, $sp, 4            # Update the stack pointer
    
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, -128         # Subtract 128 from the starting position to get the pixel above
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the first element
    
    addi $t1, $t1, 4            # Set index to 1
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, -4           # Subtract 4 from the starting position to get the pixel to the left
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the second element
    
    addi $t1, $t1, 4            # Set index to 2
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, 0            # Set $t0 to the starting position
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the third element
    
    addi $t1, $t1, 4            # Set index to 3
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, 4            # Add 4 to the starting position to get the pixel to the right
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the fourth element 
    jr $ra                      # Return



create_T_R3_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the T_TETROMINO_R3 array
    # $t1: register to store the current index
    # $t2: register to store current address being written to
    # $t9: register to store the starting address for the T_TETROMINO_R3 array
    # Given the starting position's current address, not the offset from the starting address
    
    la $t9, T_TETROMINO_R3      # Store the array address in register $t9
    
    lw $a0, 0($sp)              # Get starting position's address on bitmap from the stack
    addi $sp, $sp, 4            # Update the stack pointer
    
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, -128         # Subtract 128 from the starting position to get the pixel above
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the first element
    
    addi $t1, $t1, 4            # Set index to 1
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, 0            # Set $t0 to be the starting address
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the second element
    
    addi $t1, $t1, 4            # Set index to 2
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, 4            # Add 4 to the starting address to get the pixel to the right
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the third element
    
    addi $t1, $t1, 4            # Set index to 3
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, 128          # Add 128 to the starting position to get the pixel below
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the fourth element
    jr $ra                      # Return
    
    
    
T_R3_to_R_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the T_TETROMINO array
    # $t1: register to store the current index
    # $t2: register to store current address being written to
    # $t9: register to store the starting address for the T_TETROMINO array
    # Given the starting position's current address, not the offset from the starting address
    
    la $t9, T_TETROMINO         # Store memory address for T_TETROMINO array
    
    lw $a0, 0($sp)              # Get starting position address from the stack
    addi $sp, $sp, 4            # Update the stack pointer
    
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, -4           # Subtract 4 from the starting position to get the pixel to the left
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the first element
    
    addi $t1, $t1, 4            # Set index to 1
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the second element
    
    addi $t1, $t1, 4            # Set index to 2
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, 4            # Add 4 to the starting position to get the pixel to the right
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the third element
    
    addi $t1, $t1, 4            # Set index to 3
    add $t2, $t9, $t1           # Set $t2 to be the current address being written to
    addi $t0, $a0, 128          # Add 128 to the starting position to get the pixel below
    sw $t0, 0($t2)              # Store the address of the pixel at $t0 in the array as the fourth element
    jr $ra                      # Return
    


# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Functions for J tetromino
create_J_tetromino:
    # $a0: register to store the original x offset value from the stack
    # $a1: register to store the original y offset value from the stack
    # $t0: register to store the array index
    # $t1: register to store the bitmap starting address
    # $t2: register to store the starting position of the tetromino
    # $t3: register to store the current pixel address
    # $t4: register to store the current address of J_TETROMINO being written to
    # $t9: register to store the starting address of J_TETROMINO
    
    # Get values from the stack
    lw $a0, 0($sp)              # Get the starting position x offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    lw $a1, 0($sp)              # Get the starting position y offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    la $t9, J_TETROMINO         # Store the starting address in $t9
    lw $t1, ADDR_DSPL           # Store the starting address for the bitmap display
    addi $t0, $zero, 0          # Set array index to 0
    
    # Calculate horizontal and vertical offsets
    sll $a0, $a0, 2             # Multiply $a0 by 4
    sll $a1, $a1, 2             # Multiply $a1 by 4
    
    add $t2, $t1, $a0           
    add $t2, $t2, $a1           # Store the starting position address in $t2
    
    # Store the starting position at index 0
    add $t4, $t9, $t0           # Add index offset to the starting address
    sw $t2, 0($t4)              # Store the starting position at the first index
    
    # Get second pixel and store as second element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to starting address
    addi $t3, $t2, 128          # Add 128 to the starting position to get pixel below
    sw $t3, 0($t4)              # Store the pixel location in the second element
    
    # Get the third pixel and store as third element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 252          # Add 252 to the starting position to get the pixel 2 rows down and 1 pixel to the left
    sw $t3, 0($t4)              # Store the pixel location in the third element
    
    # Get fourth pixel and store as fourth element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 256          # Add 256 to the starting position to get the pixel 2 rows below
    sw $t3, 0($t4)              # Store the pixel location in the fourth element
    
    jr $ra                      # Return



create_J_R1_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the J_TETROMINO_R1 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the J_TETROMINO_R1
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, J_TETROMINO_R1      # Store the starting address of the J_TETROMINO_R1 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -136         # Subtract 136 from the starting position to get the pixel 1 row above and 2 to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -8           # Subtract 8 from the starting point to get the pixel, 2 pixels to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, -4           # Subtract 4 from the starting point to get the pixel to the left
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting point
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_J_R2_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the J_TETROMINO_R2 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the J_TETROMINO_R2
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, J_TETROMINO_R2      # Store the starting address of the J_TETROMINO_R2 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -256         # Subtract 256 from the starting position to get the pixel 2 rows above
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -252         # Subtract 252 from the starting address to get the pixel 2 rows above and 1 to the right
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, -128         # Subtract 128 from the starting position to get the pixel 1 row above
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting point
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_J_R3_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the J_TETROMINO_R3 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the J_TETROMINO_R3
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, J_TETROMINO_R3      # Store the starting address of the J_TETROMINO_R3 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, 0            # Set $t0 to be the starting point
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 4            # Add 4 to the starting position to get the pixel to the right
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 8            # Add 8 to the starting position to get the pixel 2 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 136          # Add 136 to the starting point to get the pixel 1 row below and 2 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



J_R3_to_R_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the J_TETROMINO array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the J_TETROMINO
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, J_TETROMINO      # Store the starting address of the J_TETROMINO array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 128          # Add 128 to starting position to get the pixel 1 row below
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 252          # Add 252 to the starting position to get the pixel 2 rows below and 1 to the left
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 256          # Add 256 to the starting position to get the pixel 2 rows below
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Functions for L tetromino
create_L_tetromino:
    # $a0: register to store the original x offset value from the stack
    # $a1: register to store the original y offset value from the stack
    # $t0: register to store the array index
    # $t1: register to store the bitmap starting address
    # $t2: register to store the starting position of the tetromino
    # $t3: register to store the current pixel address
    # $t4: register to store the current address of L_TETROMINO being written to
    # $t9: register to store the starting address of L_TETROMINO
    
    # Get values from the stack
    lw $a0, 0($sp)              # Get the starting position x offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    lw $a1, 0($sp)              # Get the starting position y offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    la $t9, L_TETROMINO         # Store the starting address in $t9
    lw $t1, ADDR_DSPL           # Store the starting address for the bitmap display
    addi $t0, $zero, 0          # Set array index to 0
    
    # Calculate horizontal and vertical offsets
    sll $a0, $a0, 2             # Multiply $a0 by 4
    sll $a1, $a1, 2             # Multiply $a1 by 4
    
    add $t2, $t1, $a0           
    add $t2, $t2, $a1           # Store the starting position address in $t2
    
    # Store the starting position at index 0
    add $t4, $t9, $t0           # Add index offset to the starting address
    sw $t2, 0($t4)              # Store the starting position at the first index
    
    # Get second pixel and store as second element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to starting address
    addi $t3, $t2, 128          # Add 128 to the starting position to get pixel below
    sw $t3, 0($t4)              # Store the pixel location in the second element
    
    # Get the third pixel and store as third element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 256          # Add 256 to the starting position to get the pixel 2 rows below
    sw $t3, 0($t4)              # Store the pixel location in the third element
    
    # Get fourth pixel and store as fourth element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 260          # Add 260 to the starting position to get the pixel 2 rows below and 1 to the right
    sw $t3, 0($t4)              # Store the pixel location in the fourth element
    
    jr $ra                      # Return



create_L_R1_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the L_TETROMINO_R1 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the L_TETROMINO_R1
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, L_TETROMINO_R1      # Store the starting address of the L_TETROMINO_R1 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -8           # Subtract 8 from the starting position to get the pixel 2 to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -4           # Subtract 4 from the starting position to get the pixel 1 to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 120          # Add 120 to the starting point to get the pixel 1 row below and 2 to the left
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_L_R2_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the L_TETROMINO_R2 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the L_TETROMINO_R2
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, L_TETROMINO_R2      # Store the starting address of the L_TETROMINO_R1 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -260         # Subtract 260 from the starting position to get the pixel 2 rows above and 1 to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -256         # Subtract 256 from the starting position to get the pixel 2 rows above
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, -128         # Subtract 128 from the starting position to get the pixel 1 row above
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 0            # Set $t0 to the starting position
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_L_R3_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the L_TETROMINO_R3 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the L_TETROMINO_R3
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, L_TETROMINO_R3      # Store the starting address of the L_TETROMINO_R3 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -120         # Subtract 120 from the starting position to get the pixel one row above and 2 to the right
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 0            # Set $t0 to the starting point
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 4            # Add 4 to the starting position to get the pixel 1 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 8            # Add 8 to the starting position to get the pixel 2 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



L_R3_to_R_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the L_TETROMINO array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the L_TETROMINO
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, L_TETROMINO         # Store the starting address of the L_TETROMINO array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, 0            # Set $t0 to the starting position
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 128          # Add 128 to the starting position to get the pixel 1 row below
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 256          # Add 256 to the starting position to get the pixel 2 rows below
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 260          # Add 260 to the starting position to get the pixel 2 rows below and 1 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Functions for Z tetromino
create_Z_tetromino:
    # $a0: register to store the original x offset value from the stack
    # $a1: register to store the original y offset value from the stack
    # $t0: register to store the array index
    # $t1: register to store the bitmap starting address
    # $t2: register to store the starting position of the tetromino
    # $t3: register to store the current pixel address
    # $t4: register to store the current address of Z_TETROMINO being written to
    # $t9: register to store the starting address of Z_TETROMINO
    
    # Get values from the stack
    lw $a0, 0($sp)              # Get the starting position x offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    lw $a1, 0($sp)              # Get the starting position y offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    la $t9, Z_TETROMINO         # Store the starting address in $t9
    lw $t1, ADDR_DSPL           # Store the starting address for the bitmap display
    addi $t0, $zero, 0          # Set array index to 0
    
    # Calculate horizontal and vertical offsets
    sll $a0, $a0, 2             # Multiply $a0 by 4
    sll $a1, $a1, 2             # Multiply $a1 by 4
    
    add $t2, $t1, $a0           
    add $t2, $t2, $a1           # Store the starting position address in $t2
    
    # Store the starting position at index 0
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, -4           # Subtract 4 from the starting position to get the pixel 1 to the left
    sw $t3, 0($t4)              # Store the starting position at the first index
    
    # Get second pixel and store as second element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to starting address
    addi $t3, $t2, 0            # Set $t0 to be the starting position
    sw $t3, 0($t4)              # Store the pixel location in the second element
    
    # Get the third pixel and store as third element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 128          # Add 128 to the starting position to get the pixel 1 row below
    sw $t3, 0($t4)              # Store the pixel location in the third element
    
    # Get fourth pixel and store as fourth element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 132          # Add 132 to the starting position to get the pixel 1 row below and 1 to the right
    sw $t3, 0($t4)              # Store the pixel location in the fourth element
    
    jr $ra                      # Return



create_Z_R1_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the Z_TETROMINO_R1 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the Z_TETROMINO_R1
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, Z_TETROMINO_R1         # Store the starting address of the Z_TETROMINO_R1 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -128         # Subtract 128 from the starting position to get the pixel 1 row above
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -4           # Subtract 4 from the starting position to get the pixel 1 to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 124          # Add 124 to the starting position to get the pixel 1 row down and 1 to the left
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_Z_R2_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the Z_TETROMINO_R2 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the Z_TETROMINO_R2
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, Z_TETROMINO_R2         # Store the starting address of the Z_TETROMINO_R2 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -132         # Subtract 132 from the starting position to get the pixel 1 row above and 1 to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -128         # Subtract 128 from the starting position to get the pixel 1 row above
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 4            # Add 4 to the starting position to get the pixel 1 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_Z_R3_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the Z_TETROMINO_R3 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the Z_TETROMINO_R3
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, Z_TETROMINO_R3         # Store the starting address of the Z_TETROMINO_R3 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -124         # Subtract 124 from the starting position to get the pixel 1 row above and 1 to the right
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 4            # Add 4 to the starting position to get the pixel 1 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 128          # Add 128 to the starting position to get the pixel 1 row below
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



Z_R3_to_R_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the Z_TETROMINO array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the Z_TETROMINO
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, Z_TETROMINO         # Store the starting address of the Z_TETROMINO array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -4           # Subtract 4 from the starting position to get the pixel 1 to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 128          # Add 128 to the starting position to get the pixel 1 row below
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 132          # Add 132 to the starting position to get the pixel 1 row below and 1 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Functions for S tetromino
create_S_tetromino:
    # $a0: register to store the original x offset value from the stack
    # $a1: register to store the original y offset value from the stack
    # $t0: register to store the array index
    # $t1: register to store the bitmap starting address
    # $t2: register to store the starting position of the tetromino
    # $t3: register to store the current pixel address
    # $t4: register to store the current address of S_TETROMINO being written to
    # $t9: register to store the starting address of S_TETROMINO
    
    # Get values from the stack
    lw $a0, 0($sp)              # Get the starting position x offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    lw $a1, 0($sp)              # Get the starting position y offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    la $t9, S_TETROMINO         # Store the starting address in $t9
    lw $t1, ADDR_DSPL           # Store the starting address for the bitmap display
    addi $t0, $zero, 0          # Set array index to 0
    
    # Calculate horizontal and vertical offsets
    sll $a0, $a0, 2             # Multiply $a0 by 4
    sll $a1, $a1, 2             # Multiply $a1 by 4
    
    add $t2, $t1, $a0           
    add $t2, $t2, $a1           # Store the starting position address in $t2
    
    # Store the starting position at index 0
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 0            # Set $t0 to be the starting position
    sw $t3, 0($t4)              # Store the starting position at the first index
    
    # Get second pixel and store as second element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to starting address
    addi $t3, $t2, 4            # Add 4 to the starting position to get the pixel 1 to the right
    sw $t3, 0($t4)              # Store the pixel location in the second element
    
    # Get the third pixel and store as third element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 124          # Add 124 to the starting position to get the pixel 1 row below and 1 to the left
    sw $t3, 0($t4)              # Store the pixel location in the third element
    
    # Get fourth pixel and store as fourth element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 128          # Add 128 to the starting position to get the pixel 1 row below
    sw $t3, 0($t4)              # Store the pixel location in the fourth element
    
    jr $ra                      # Return



create_S_R1_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the S_TETROMINO_R1 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the S_TETROMINO_R1
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, S_TETROMINO_R1      # Store the starting address of the S_TETROMINO_R1 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -132         # Subtract 132 from the starting position to get the pixel 1 row above and 1 to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -4           # Subtract 4 from the starting position to get the pixel 1 to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 128          # Add 128 to the starting position to get the pixel 1 row below
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_S_R2_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the S_TETROMINO_R2 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the S_TETROMINO_R2
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, S_TETROMINO_R2      # Store the starting address of the S_TETROMINO_R2 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -128         # Subtract 128 from the starting position to get the pixel 1 row above
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -124         # Subtract 124 from the starting position to get the pixel 1 row above and 1 to the right
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, -4           # Subtract 4 from the starting position to get the pixel 1 to the left
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_S_R3_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the S_TETROMINO_R3 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the S_TETROMINO_R3
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, S_TETROMINO_R3      # Store the starting address of the S_TETROMINO_R3 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -128         # Subtract 128 from the starting position to get the pixel 1 row above
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 4            # Add 4 to the starting position to get the pixel 1 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 132          # Add 132 to the starting position to get the pixel 1 row below and 1 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



S_R3_to_R_tetromino:
    # $a0: register to store the original starting position address
    # $t0: register to store the current address of a pixel to be added to the S_TETROMINO array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the S_TETROMINO
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, S_TETROMINO         # Store the starting address of the S_TETROMINO array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 4            # Add 4 to the starting position to get the pixel 1 to the right
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 124          # Add 124 to the starting position to get the pixel 1 row below and 1 to the left
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 128          # Add 128 to the starting position to get the pixel 1 row below
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return


# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Functions for I tetromino:
create_I_tetromino:
    # $a0: register to store original x offset value from the stack
    # $a1: register to store original y offset value from the stack
    # $t0: register to store x offset
    # $t1: register to store y offset
    # $t2: register to store width
    # $t3: register to store length
    # $t4: register to store array index
    # $t9: register to store the array at index 0
    
    # Get values from the stack
    lw $a0, 0($sp)              # Get starting position x offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    addi $t0, $a0, 0            # Store x offset in $t0
    lw $a1, 0($sp)              # Get starting position y offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    addi $t1, $a1, 0            # Store y offset on $t1
    
    la $t9, I_TETROMINO        # Store the starting address in $t9
    addi $t4, $zero, 0          # Set array index to 0
    
    # Modify x offset to draw the 3 pixel horizontal line
    addi $t2, $zero, 1          # Store width value in $t2
    addi $t3, $zero, 4          # Store length value in $t3
    
    # Put parameters onto the stack
    # Need to save $ra
    addi $sp, $sp, -4           # Update the stack pointer
    sw $ra, 0($sp)              # Store $ra on the stack
    # Need to pass the values of $t0, $t1, $t2, $t3, $t4 and $t9 to the function
    addi $sp, $sp, -4           # Update stack pointer
    sw $t9, 0($sp)              # Store value of $t9 (starting address) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t4, 0($sp)              # Store the value of $t4 (array index) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t3, 0($sp)              # Store value of $t3 (length) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t2, 0($sp)              # Store value of $t2 (width) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t1, 0($sp)              # Store value of $t1 (y offset) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t0, 0($sp)              # Store value of $t0 (x offset) on stack
    jal set_rectangle           # Call function to set line
    
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update stack pointer
    jr $ra                      # return



create_I_R1_tetromino:
    # $t0: register to store the current address of a pixel to be added to the I_TETROMINO_R1 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the I_TETROMINO_R1
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, I_TETROMINO_R1      # Store the starting address of the I_TETROMINO_R1 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -12          # Subtract 12 from the starting position to get the pixel 3 to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -8           # Subtract 8 from the starting position to get the pixel 2 from the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, -4           # Subtract 4 from the starting position to get the pixel 1 from the left
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_I_R2_tetromino:
    # $t0: register to store the current address of a pixel to be added to the I_TETROMINO_R2 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the I_TETROMINO_R2
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, I_TETROMINO_R2      # Store the starting address of the I_TETROMINO_R2 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -384         # Subtract 384 from the starting position to get the pixel 3 rows above
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -256         # Subtract 256 from the starting position to get the pixel 2 rows above
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, -128         # Subtract 128 from the starting positionto get the pixel 1 row above 
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_I_R3_tetromino:
    # $t0: register to store the current address of a pixel to be added to the I_TETROMINO_R3 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the I_TETROMINO_R3
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, I_TETROMINO_R3      # Store the starting address of the I_TETROMINO_R3 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 4            # Add 4 to the starting position to get the pixel 1 to the right
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 8            # Add 8 to the starting position to get the pixel 2 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 12           # Add 12 to the starting position to get the pixel 3 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



I_R3_to_R_tetromino:
    # $t0: register to store the current address of a pixel to be added to the I_TETROMINO array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the I_TETROMINO
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, I_TETROMINO         # Store the starting address of the I_TETROMINO array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 128          # Add 128 to the starting position to get the pixel 1 row below
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 256          # Add 256 to the starting position to get the pixel 2 rows below
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 384          # Add 384 to the starting position to get the pixel 3 rows below
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Funcitons for O tetromino
create_O_tetromino:
    # $a0: register to store the original x offset value from the stack
    # $a1: register to store the original y offset value from the stack
    # $t0: register to store the array index
    # $t1: register to store the bitmap starting address
    # $t2: register to store the starting position of the tetromino
    # $t3: register to store the current pixel address
    # $t4: register to store the current address of O_TETROMINO being written to
    # $t9: register to store the starting address of O_TETROMINO
    
    # Get values from the stack
    lw $a0, 0($sp)              # Get the starting position x offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    lw $a1, 0($sp)              # Get the starting position y offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    la $t9, O_TETROMINO         # Store the starting address in $t9
    lw $t1, ADDR_DSPL           # Store the starting address for the bitmap display
    addi $t0, $zero, 0          # Set array index to 0
    
    # Calculate horizontal and vertical offsets
    sll $a0, $a0, 2             # Multiply $a0 by 4
    sll $a1, $a1, 2             # Multiply $a1 by 4
    
    add $t2, $t1, $a0           
    add $t2, $t2, $a1           # Store the starting position address in $t2
    
    # Store the starting position at index 0
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 0            # Set $t0 to be the starting position
    sw $t3, 0($t4)              # Store the starting position at the first index
    
    # Get second pixel and store as second element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to starting address
    addi $t3, $t2, 4            # Add 4 to the starting position to get the pixel 1 to the right
    sw $t3, 0($t4)              # Store the pixel location in the second element
    
    # Get the third pixel and store as third element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 128          # Add 128 to the starting position to get the pixel 1 row below
    sw $t3, 0($t4)              # Store the pixel location in the third element
    
    # Get fourth pixel and store as fourth element
    addi $t0, $t0, 4            # Increment index by 4
    add $t4, $t9, $t0           # Add index offset to the starting address
    addi $t3, $t2, 132          # Add 132 to the starting position to get the pixel 1 row below and 1 to the right
    sw $t3, 0($t4)              # Store the pixel location in the fourth element
    
    jr $ra                      # Return



create_O_R1_tetromino:
    # $t0: register to store the current address of a pixel to be added to the O_TETROMINO_R1 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the O_TETROMINO_R1
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, O_TETROMINO_R1      # Store the starting address of the O_TETROMINO_R1 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -4           # Subtract 4 from the starting position to get the pixel 1 to the left
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 0            # Set $t0 to the starting position
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 124          # Add 124 to the starting position to get the pixel 1 row below and 1 to the left
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 128          # Add 128 to the starting position to get the pixel 1 row below
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_O_R2_tetromino:
    # $t0: register to store the current address of a pixel to be added to the O_TETROMINO_R2 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the O_TETROMINO_R2
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, O_TETROMINO_R2      # Store the starting address of the O_TETROMINO_R2 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -132         # Subtract 132 form the starting position to get the pixel 1 row above and 1 to the right
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -128         # Subtract 128 from the starting position to get the pixel 1 row above
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, -4           # Subtract 4 from the starting position to get the pixel 1 to the left
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



create_O_R3_tetromino:
    # $t0: register to store the current address of a pixel to be added to the O_TETROMINO_R3 array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the O_TETROMINO_R3
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, O_TETROMINO_R3      # Store the starting address of the O_TETROMINO_R3 array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, -128         # Subtract 128 from the starting position to get the pixel 1 row above
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, -124         # Subtract 124 from the starting position to get the pixel 1 row above and 1 to the right
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 4            # Add 4 to the starting position to get the pixel 1 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return



O_R3_to_R_tetromino:
    # $t0: register to store the current address of a pixel to be added to the O_TETROMINO array
    # $t1: register to store the current index
    # $t2: register to store the current address being written to
    # $t9: register to store the starting address for the O_TETROMINO
    # Given the startingposition's address, not the offset from the starting address
    
    la $t9, O_TETROMINO         # Store the starting address of the O_TETROMINO array in $t9
    
    lw $a0, 0($sp)              # Get starting position's current address from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # First pixel
    addi $t1, $zero, 0          # Set index to 0
    add $t2, $zero, $t9         # Set current address being written to to be the first address
    addi $t0, $a0, 0            # Set $t0 to be the starting position
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the first index
    
    # Second pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to next element
    add $t2, $t9, $t1           # Store address for second element in $t2
    addi $t0, $a0, 4            # Add 4 to the starting position to get the pixel 1 to the right
    sw $t0, 0($t2)              # Store pixel address held in $t0 at the second index
    
    # Third pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the third element in $t2
    addi $t0, $a0, 128          # Add 128 to the starting position to get the pixel 1 row below
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the third index
    
    # Fourth pixel
    addi $t1, $t1, 4            # Increment index by 4 to get to the next element
    add $t2, $t9, $t1           # Store the address for the fourth element in $t2
    addi $t0, $a0, 132          # Add 132 to the starting position to get the pixel 1 row below and 1 to the right
    sw $t0, 0($t2)              # Store the pixel address held in $t0 at the fourth index
    jr $ra                      # Return

# Left and right collision checks ---------------------------------------------------------------------------------------------------------------------
# Original T-tetromino -------------------------------------------------------------------------------------------------------------------------------
T_TETROMINO_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 116, T_TETROMINO_left_check_end
    bne $t1, 0, T_TETROMINO_left_check_end
    
    la $t2, T_TETROMINO
    jal left_collision_check
    
    addi $t2, $t2, 12
    jal left_collision_check
T_TETROMINO_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
T_TETROMINO_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 116, T_TETROMINO_right_check_end
    bne $t1, 0, T_TETROMINO_right_check_end
    
    la $t2, T_TETROMINO
    addi $t2, $t2, 8
    jal right_collision_check
    
    addi $t2, $t2, 4
    
T_TETROMINO_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

# T-Tetromino rotated once
T_TETROMINO_R1_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 116, T_TETROMINO_R1_left_check_end
    bne $t1, 1, T_TETROMINO_R1_left_check_end
    
    la $t2, T_TETROMINO_R1
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
T_TETROMINO_R1_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


T_TETROMINO_R1_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 116, T_TETROMINO_R1_right_check_end
    bne $t1, 1, T_TETROMINO_R1_right_check_end
    
    la $t2, T_TETROMINO_R1
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
T_TETROMINO_R1_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

# T-Tetromino rotated twice
T_TETROMINO_R2_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 116, T_TETROMINO_R2_left_check_end
    bne $t1, 2, T_TETROMINO_R2_left_check_end
    
    la $t2, T_TETROMINO_R2
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
T_TETROMINO_R2_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
T_TETROMINO_R2_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 116, T_TETROMINO_R2_right_check_end
    bne $t1, 2, T_TETROMINO_R2_right_check_end
    
    la $t2, T_TETROMINO_R2
    jal right_collision_check
    
    addi $t2, $t2, 12
    jal right_collision_check
T_TETROMINO_R2_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

# T-Tetromino rotated thrice
T_TETROMINO_R3_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 116, T_TETROMINO_R3_left_check_end
    bne $t1, 3, T_TETROMINO_R3_left_check_end
    
    la $t2, T_TETROMINO_R3
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
T_TETROMINO_R3_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
T_TETROMINO_R3_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 116, T_TETROMINO_R3_right_check_end
    bne $t1, 3, T_TETROMINO_R3_right_check_end
    
    la $t2, T_TETROMINO_R3
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
T_TETROMINO_R3_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

# Original J-tetromino -------------------------------------------------------------------------------------------------------------------------------
J_TETROMINO_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 106, J_TETROMINO_left_check_end
    bne $t1, 0, J_TETROMINO_left_check_end
    
    la $t2, J_TETROMINO
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
J_TETROMINO_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


J_TETROMINO_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 106, J_TETROMINO_right_check_end
    bne $t1, 0, J_TETROMINO_right_check_end
    
    la $t2, J_TETROMINO
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
J_TETROMINO_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
# J-tetromino rotated once
J_TETROMINO_R1_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 106, J_TETROMINO_R1_left_check_end
    bne $t1, 1, J_TETROMINO_R1_left_check_end
    
    la $t2, J_TETROMINO_R1
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
J_TETROMINO_R1_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    

J_TETROMINO_R1_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 106, J_TETROMINO_R1_right_check_end
    bne $t1, 1, J_TETROMINO_R1_right_check_end
    
    la $t2, J_TETROMINO_R1
    addi $t2, $t2, 12
    jal right_collision_check
J_TETROMINO_R1_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
# J-tetromino rotated twice
J_TETROMINO_R2_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 106, J_TETROMINO_R2_left_check_end
    bne $t1, 2, J_TETROMINO_R2_left_check_end
    
    la $t2, J_TETROMINO_R2
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
J_TETROMINO_R2_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


J_TETROMINO_R2_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 106, J_TETROMINO_R2_right_check_end
    bne $t1, 2, J_TETROMINO_R2_right_check_end
    
    la $t2, J_TETROMINO_R2
    addi $t2, $t2, 4
    jal right_collision_check
J_TETROMINO_R2_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
# J-tetromino rotated thrice
J_TETROMINO_R3_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 106, J_TETROMINO_R3_left_check_end
    bne $t1, 3, J_TETROMINO_R3_left_check_end
    
    la $t2, J_TETROMINO_R3
    jal left_collision_check
J_TETROMINO_R3_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


J_TETROMINO_R3_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 106, J_TETROMINO_R3_right_check_end
    bne $t1, 3, J_TETROMINO_R3_right_check_end
    
    la $t2, J_TETROMINO_R3
    addi $t2, $t2, 8
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
J_TETROMINO_R3_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
# Original L-tetromino -------------------------------------------------------------------------------------------------------------------------------
L_TETROMINO_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 108, L_TETROMINO_left_check_end
    bne $t1, 0, L_TETROMINO_left_check_end
    
    la $t2, L_TETROMINO
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
L_TETROMINO_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


L_TETROMINO_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 108, L_TETROMINO_right_check_end
    bne $t1, 0, L_TETROMINO_right_check_end
    
    la $t2, L_TETROMINO
    addi $t2, $t2, 12
    jal right_collision_check
L_TETROMINO_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

# L-tetromino rotated once
L_TETROMINO_R1_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 108, L_TETROMINO_R1_left_check_end
    bne $t1, 1, L_TETROMINO_R1_left_check_end
    
    la $t2, L_TETROMINO_R1
    jal left_collision_check
    
    addi $t2, $t2, 12
    jal left_collision_check
L_TETROMINO_R1_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


L_TETROMINO_R1_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 108, L_TETROMINO_right_check_end
    bne $t1, 1, L_TETROMINO_right_check_end
    
    la $t2, L_TETROMINO_R1
    addi $t2, $t2, 8
    jal right_collision_check
L_TETROMINO_R1_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
# L-tetromino rotated twice
L_TETROMINO_R2_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 108, L_TETROMINO_R2_left_check_end
    bne $t1, 2, L_TETROMINO_R2_left_check_end
    
    la $t2, L_TETROMINO_R2
    jal left_collision_check
L_TETROMINO_R2_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


L_TETROMINO_R2_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 108, L_TETROMINO_R2_right_check_end
    bne $t1, 2, L_TETROMINO_R2_right_check_end
    
    la $t2, L_TETROMINO_R2
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
L_TETROMINO_R2_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
# L-tetromino rotated thrice
L_TETROMINO_R3_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 108, L_TETROMINO_R3_left_check_end
    bne $t1, 3, L_TETROMINO_R3_left_check_end
    
    la $t2, L_TETROMINO_R3
    addi $t2, $t2, 4
    jal left_collision_check
L_TETROMINO_R3_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


L_TETROMINO_R3_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 108, L_TETROMINO_R3_right_check_end
    bne $t1, 3, L_TETROMINO_R3_right_check_end
    
    la $t2, L_TETROMINO_R3
    jal right_collision_check
    
    addi $t2, $t2, 12
    jal right_collision_check
L_TETROMINO_R3_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
# Original Z-tetromino (or rotated twice) ------------------------------------------------------------------------------------------------------------------------
Z_TETROMINO_R0_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 122, Z_TETROMINO_R0_left_check_end
    bne $t1, 0, Z_TETROMINO_R0_left_check_end
    
    la $t2, Z_TETROMINO
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
Z_TETROMINO_R0_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

Z_TETROMINO_R0_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 122, Z_TETROMINO_R0_right_check_end
    bne $t1, 0, Z_TETROMINO_R0_right_check_end
    
    la $t2, Z_TETROMINO
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
Z_TETROMINO_R0_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra



Z_TETROMINO_R2_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 122, Z_TETROMINO_R2_left_check_end
    bne $t1, 2, Z_TETROMINO_R2_left_check_end
    
    la $t2, Z_TETROMINO_R2
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
Z_TETROMINO_R2_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

Z_TETROMINO_R2_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 122, Z_TETROMINO_R2_right_check_end
    bne $t1, 2, Z_TETROMINO_R2_right_check_end
    
    la $t2, Z_TETROMINO_R2
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
Z_TETROMINO_R2_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
# Z-tetromino rotated once or thrice
Z_TETROMINO_R1_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 122, Z_TETROMINO_R1_left_check_end
    bne $t1, 1, Z_TETROMINO_R1_left_check_end
    
    la $t2, Z_TETROMINO_R1
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
Z_TETROMINO_R1_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

Z_TETROMINO_R1_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 122, Z_TETROMINO_R1_right_check_end
    bne $t1, 1, Z_TETROMINO_R1_right_check_end
    
    la $t2, Z_TETROMINO_R1
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
Z_TETROMINO_R1_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


Z_TETROMINO_R3_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 122, Z_TETROMINO_R3_left_check_end
    bne $t1, 3, Z_TETROMINO_R3_left_check_end
    
    la $t2, Z_TETROMINO_R3
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
Z_TETROMINO_R3_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

Z_TETROMINO_R3_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 122, Z_TETROMINO_R3_right_check_end
    bne $t1, 3, Z_TETROMINO_R3_right_check_end
    
    la $t2, Z_TETROMINO_R3
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
Z_TETROMINO_R3_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
# Original S-tetromino -------------------------------------------------------------------------------------------------------------------------------
S_TETROMINO_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 115, S_TETROMINO_left_check_end
    bne $t1, 0, S_TETROMINO_left_check_end
    
    la $t2, S_TETROMINO
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
S_TETROMINO_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

S_TETROMINO_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 115, S_TETROMINO_right_check_end
    bne $t1, 0, S_TETROMINO_right_check_end
    
    la $t2, S_TETROMINO
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
S_TETROMINO_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


# S-tetromino rotated once
S_TETROMINO_R1_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 115, S_TETROMINO_R1_left_check_end
    bne $t1, 1, S_TETROMINO_R1_left_check_end
    
    la $t2, S_TETROMINO_R1
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
S_TETROMINO_R1_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

S_TETROMINO_R1_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 115, S_TETROMINO_R1_right_check_end
    bne $t1, 1, S_TETROMINO_R1_right_check_end
    
    la $t2, S_TETROMINO_R1
    addi $t2, $t2, 8
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
S_TETROMINO_R1_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
# S-tetromino rotated twice
S_TETROMINO_R2_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 115, S_TETROMINO_R2_left_check_end
    bne $t1, 2, S_TETROMINO_R2_left_check_end
    
    la $t2, S_TETROMINO_R2
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
S_TETROMINO_R2_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

S_TETROMINO_R2_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 115, S_TETROMINO_R2_right_check_end
    bne $t1, 2, S_TETROMINO_R2_right_check_end
    
    la $t2, S_TETROMINO_R2
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
S_TETROMINO_R2_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
# S-tetromino rotated thrice
S_TETROMINO_R3_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 115, S_TETROMINO_R3_left_check_end
    bne $t1, 3, S_TETROMINO_R3_left_check_end
    
    la $t2, S_TETROMINO_R3
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
S_TETROMINO_R3_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

S_TETROMINO_R3_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 115, S_TETROMINO_R3_right_check_end
    bne $t1, 3, S_TETROMINO_R3_right_check_end
    
    la $t2, S_TETROMINO_R3
    addi $t2, $t2, 8
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
S_TETROMINO_R3_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
# Original I-tetromino -------------------------------------------------------------------------------------------------------------------------------
I_TETROMINO_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 105, I_TETROMINO_left_check_end
    bne $t1, 0, I_TETROMINO_left_check_end
    
    la $t2, I_TETROMINO
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
I_TETROMINO_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

I_TETROMINO_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 105, I_TETROMINO_right_check_end
    bne $t1, 0, I_TETROMINO_right_check_end
    
    la $t2, I_TETROMINO
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
I_TETROMINO_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


# I-tetromino rotated once
I_TETROMINO_R1_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 105, I_TETROMINO_R1_left_check_end
    bne $t1, 1, I_TETROMINO_R1_left_check_end
    
    la $t2, I_TETROMINO_R1
    jal left_collision_check
I_TETROMINO_R1_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

I_TETROMINO_R1_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 105, I_TETROMINO_R1_right_check_end
    bne $t1, 1, I_TETROMINO_R1_right_check_end
    
    la $t2, I_TETROMINO_R1
    addi $t2, $t2, 12
    jal right_collision_check
I_TETROMINO_R1_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
# I-tetromino rotated twice
I_TETROMINO_R2_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 105, I_TETROMINO_R2_left_check_end
    bne $t1, 2, I_TETROMINO_R2_left_check_end
    
    la $t2, I_TETROMINO_R2
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
    
    addi $t2, $t2, 4
    jal left_collision_check
I_TETROMINO_R2_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

I_TETROMINO_R2_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 105, I_TETROMINO_R2_right_check_end
    bne $t1, 2, I_TETROMINO_R2_right_check_end
    
    la $t2, I_TETROMINO_R2
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 4
    jal right_collision_check
I_TETROMINO_R2_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
# I-tetromino rotated thrice
I_TETROMINO_R3_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 105, I_TETROMINO_R3_left_check_end
    bne $t1, 3, I_TETROMINO_R3_left_check_end
    
    la $t2, I_TETROMINO_R3
    jal left_collision_check
I_TETROMINO_R3_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

I_TETROMINO_R3_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 105, I_TETROMINO_R3_right_check_end
    bne $t1, 3, I_TETROMINO_R3_right_check_end
    
    la $t2, I_TETROMINO_R3
    addi $t2, $t2, 12
    jal right_collision_check
I_TETROMINO_R3_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
# Original O-tetromino -------------------------------------------------------------------------------------------------------------------------------
O_TETROMINO_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 111, O_TETROMINO_left_check_end
    bne $t1, 0, O_TETROMINO_left_check_end
    
    la $t2, O_TETROMINO
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
O_TETROMINO_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

O_TETROMINO_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 111, O_TETROMINO_right_check_end
    bne $t1, 0, O_TETROMINO_right_check_end
    
    la $t2, O_TETROMINO
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
O_TETROMINO_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


# O-tetromino rotated once
O_TETROMINO_R1_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 111, O_TETROMINO_R1_left_check_end
    bne $t1, 1, O_TETROMINO_R1_left_check_end
    
    la $t2, O_TETROMINO_R1
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
O_TETROMINO_R1_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

O_TETROMINO_R1_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 111, O_TETROMINO_R1_right_check_end
    bne $t1, 1, O_TETROMINO_R1_right_check_end
    
    la $t2, O_TETROMINO_R1
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
O_TETROMINO_R1_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


# O-tetromino rotated twice
O_TETROMINO_R2_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 111, O_TETROMINO_R2_left_check_end
    bne $t1, 2, O_TETROMINO_R2_left_check_end
    
    la $t2, O_TETROMINO_R2
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
O_TETROMINO_R2_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

O_TETROMINO_R2_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 111, O_TETROMINO_R2_right_check_end
    bne $t1, 2, O_TETROMINO_R2_right_check_end
    
    la $t2, O_TETROMINO_R2
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
O_TETROMINO_R2_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
# O-tetromino rotated thrice
O_TETROMINO_R3_left_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 111, O_TETROMINO_R3_left_check_end
    bne $t1, 3, O_TETROMINO_R3_left_check_end
    
    la $t2, O_TETROMINO_R3
    jal left_collision_check
    
    addi $t2, $t2, 8
    jal left_collision_check
O_TETROMINO_R3_left_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

O_TETROMINO_R3_right_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    bne $t0, 111, O_TETROMINO_R3_right_check_end
    bne $t1, 3, O_TETROMINO_R3_right_check_end
    
    la $t2, O_TETROMINO_R3
    addi $t2, $t2, 4
    jal right_collision_check
    
    addi $t2, $t2, 8
    jal right_collision_check
O_TETROMINO_R3_right_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
# General left and right collision functions ---------------------------------------------------------------------------------------------------------
pre_left_collision_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    lw $t0, TETROMINO_TYPE
    lw $t1, ROTATION
    
    # Checking collisions for each tetromino
    jal T_TETROMINO_left_check
    jal T_TETROMINO_R1_left_check
    jal T_TETROMINO_R2_left_check
    jal T_TETROMINO_R3_left_check
    jal J_TETROMINO_left_check
    jal J_TETROMINO_R1_left_check
    jal J_TETROMINO_R2_left_check
    jal J_TETROMINO_R3_left_check
    jal L_TETROMINO_left_check
    jal L_TETROMINO_R1_left_check
    jal L_TETROMINO_R2_left_check
    jal L_TETROMINO_R3_left_check
    jal Z_TETROMINO_R0_left_check
    jal Z_TETROMINO_R1_left_check
    jal Z_TETROMINO_R2_left_check
    jal Z_TETROMINO_R3_left_check
    jal S_TETROMINO_left_check
    jal S_TETROMINO_R1_left_check
    jal S_TETROMINO_R2_left_check
    jal S_TETROMINO_R3_left_check
    jal I_TETROMINO_left_check
    jal I_TETROMINO_R1_left_check
    jal I_TETROMINO_R2_left_check
    jal I_TETROMINO_R3_left_check
    jal O_TETROMINO_left_check
    jal O_TETROMINO_R1_left_check
    jal O_TETROMINO_R2_left_check
    jal O_TETROMINO_R3_left_check
pre_left_collision_checend:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra

left_collision_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    lw $t3, 0($t2)              # Store the bitmap address of the first pixel of the tetromino in $t3
    addi $t4, $t3, -4          
    lw $t5, 0($t4)              # Store the colour of the pixel in $t5
    
    lw $t1, PINK
    beq $t1, $t5, game_loop
    lw $t1, BLUE
    beq $t1, $t5, game_loop
    lw $t1, GREEN
    beq $t1, $t5, game_loop
    lw $t1, YELLOW
    beq $t1, $t5, game_loop
    lw $t1, PURPLE
    beq $t1, $t5, game_loop
    lw $t1, INDIGO
    beq $t1, $t5, game_loop
    lw $t1, ORANGE
    beq $t1, $t5, game_loop
    lw $t1, DARK_PURPLE
    beq $t1, $t5, game_loop
left_collision_check_end:
    # If reached, then no collision occurred
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    
    
pre_right_collision_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    lw $t0, TETROMINO_TYPE
    lw $t1, ROTATION
    
    # Checking collisions for each tetromino
    jal T_TETROMINO_right_check
    jal T_TETROMINO_R1_right_check
    jal T_TETROMINO_R2_right_check
    jal T_TETROMINO_R3_right_check
    jal J_TETROMINO_right_check
    jal J_TETROMINO_R1_right_check
    jal J_TETROMINO_R2_right_check
    jal J_TETROMINO_R3_right_check
    jal L_TETROMINO_right_check
    jal L_TETROMINO_R1_right_check
    jal L_TETROMINO_R2_right_check
    jal L_TETROMINO_R3_right_check
    jal Z_TETROMINO_R0_right_check
    jal Z_TETROMINO_R1_right_check
    jal Z_TETROMINO_R2_right_check
    jal Z_TETROMINO_R3_right_check
    jal S_TETROMINO_right_check
    jal S_TETROMINO_R1_right_check
    jal S_TETROMINO_R2_right_check
    jal S_TETROMINO_R3_right_check
    jal I_TETROMINO_right_check
    jal I_TETROMINO_R1_right_check
    jal I_TETROMINO_R2_right_check
    jal I_TETROMINO_R3_right_check
    jal O_TETROMINO_right_check
    jal O_TETROMINO_R1_right_check
    jal O_TETROMINO_R2_right_check
    jal O_TETROMINO_R3_right_check
pre_right_collision_check_end:
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra


right_collision_check:
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on stack
    
    lw $t3, 0($t2)              # Store the bitmap address of the first pixel of the tetromino in $t3
    addi $t4, $t3, 4             
    lw $t5, 0($t4)              # Store the colour of the pixel in $t5
    
    lw $t1, PINK
    beq $t1, $t5, game_loop
    lw $t1, BLUE
    beq $t1, $t5, game_loop
    lw $t1, GREEN
    beq $t1, $t5, game_loop
    lw $t1, YELLOW
    beq $t1, $t5, game_loop
    lw $t1, PURPLE
    beq $t1, $t5, game_loop
    lw $t1, INDIGO
    beq $t1, $t5, game_loop
    lw $t1, ORANGE
    beq $t1, $t5, game_loop
    lw $t1, DARK_PURPLE
    beq $t1, $t5, game_loop
right_collision_check_end:
    # If reached, then no collision occurred
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update the stack
    jr $ra
    

# Letter drawing functions ----------------------------------------------------------------------------------------------------------------
draw_horizontal_line:
    beq $t2, $t3, draw_horizontal_line_end
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, 1
    j draw_horizontal_line
draw_horizontal_line_end:
    jr $ra
    
draw_vertical_line:
    beq $t2, $t3, draw_vertical_line_end
    sw $t1, 0($t0)
    addi $t0, $t0, 128
    addi $t2, $t2, 1
    j draw_vertical_line
draw_vertical_line_end:
    jr $ra

draw_game_over:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal draw_g
    jal draw_a
    jal draw_m
    
    addi $a0, $zero, 1116
    addi $a1, $zero, 1120
    addi $a2, $zero, 1376
    addi $a3, $zero, 1760
    jal draw_e
    
    jal draw_o
    jal draw_v
    
    addi $a0, $zero, 1988
    addi $a1, $zero, 1992
    addi $a2, $zero, 2248
    addi $a3, $zero, 2632
    jal draw_e
    
    addi $a0, $zero, 2012
    addi $a1, $zero, 2016
    addi $a2, $zero, 2400
    addi $a3, $zero, 2156
    addi $s3, $zero, 2540
    jal draw_r
    
    # For R at the bottom left corner
    addi $a0, $zero, 3204
    addi $a1, $zero, 3208
    addi $a2, $zero, 3592
    addi $a3, $zero, 3348
    addi $s3, $zero, 3732
    jal draw_r
draw_game_over_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
draw_paused:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    lw $t0, ADDR_DSPL
    lw $t1, WHITE
    
    jal draw_p
    jal draw_a_alt
    jal draw_u
    jal draw_s
    jal draw_e_alt
    jal draw_d
draw_paused_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
# Drawing G -------------------------------------------------------------------------------------------------------------------------------
draw_g:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
        
    addi $t0, $t0, 1044
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1684
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1168
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    sw $t1, 1572($t0)
    sw $t1, 1444($t0)
    sw $t1, 1312($t0)
    sw $t1, 1308($t0)
end_draw_g:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Drawing A -------------------------------------------------------------------------------------------------------------------------------
draw_a:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1072
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1196
    addi $t2, $zero, 0
    addi $t3, $zero, 5
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1212
    addi $t2, $zero, 0
    addi $t3, $zero, 5
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1456
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_horizontal_line
end_draw_a:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Drawing M -------------------------------------------------------------------------------------------------------------------------------
draw_m:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1220
    addi $t2, $zero, 0
    addi $t3, $zero, 5
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1236
    addi $t2, $zero, 0
    addi $t3, $zero, 5
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1228
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    sw $t1, 1096($t0)
    sw $t1, 1104($t0)
end_draw_m:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
# Drawing E --------------------------------------------------------------------------------------------------------------------
draw_e:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    lw $t0, ADDR_DSPL
    add $t0, $t0, $a0
    addi $t2, $zero, 0
    addi $t3, $zero, 6
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    add $t0, $t0, $a1
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    add $t0, $t0, $a2
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_horizontal_line

    lw $t0, ADDR_DSPL
    add $t0, $t0, $a3
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_horizontal_line
end_draw_e:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Drawing O ------------------------------------------------------------------------------------------------------------------------------
draw_o:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 2064
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 2084
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1940
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 2580
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_horizontal_line
end_draw_o:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Drawing V ------------------------------------------------------------------------------------------------------------------------------
draw_v:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1964
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    sw $t1, 2480($t0)
    sw $t1, 2612($t0)
    sw $t1, 2488($t0)
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1980
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_vertical_line
end_draw_v:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Drawing R ------------------------------------------------------------------------------------------------------------------------------
draw_r:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ADDR_DSPL
    add $t0, $t0, $a0 # 2012
    addi $t2, $zero, 0
    addi $t3, $zero, 6
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    add $t0, $t0, $a1 # 2016
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    add $t0, $t0, $a2 # 2400
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    add $t0, $t0, $a3 # 2156
    addi $t2, $zero, 0
    addi $t3, $zero, 2
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    add $t0, $t0, $s3 # 2540
    addi $t2, $zero, 0
    addi $t3, $zero, 2
    jal draw_vertical_line
end_draw_r:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
# Drawing p
draw_p:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $t0, $t0, 1040
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1296
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1168
    addi $t2, $zero, 0
    addi $t3, $zero, 4
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1048
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_vertical_line
end_draw_p:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Drawing alternate a
draw_a_alt:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1056
    addi $t2, $zero, 0
    addi $t3, $zero, 5
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1064
    addi $t2, $zero, 0
    addi $t3, $zero, 5
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    sw $t1, 1060($t0)
    sw $t1, 1316($t0)
end_draw_a_alt:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_u:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1072
    addi $t2, $zero, 0
    addi $t3, $zero, 5
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1080
    addi $t2, $zero, 0
    addi $t3, $zero, 5
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    sw $t1, 1588($t0)
end_draw_u:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_s:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1088
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1344
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1600
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    sw $t1, 1216($t0)
    sw $t1, 1480($t0)
end_draw_s:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_e_alt:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1104
    addi $t2, $zero, 0
    addi $t3, $zero, 5
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1108
    addi $t2, $zero, 0
    addi $t3, $zero, 2
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1364
    addi $t2, $zero, 0
    addi $t3, $zero, 2
    jal draw_horizontal_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1620
    addi $t2, $zero, 0
    addi $t3, $zero, 2
    jal draw_horizontal_line
end_draw_e_alt:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_d:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1120
    addi $t2, $zero, 0
    addi $t3, $zero, 5
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1256
    addi $t2, $zero, 0
    addi $t3, $zero, 3
    jal draw_vertical_line
    
    lw $t0, ADDR_DSPL
    sw $t1, 1124($t0)
    sw $t1, 1636($t0)
end_draw_d:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra