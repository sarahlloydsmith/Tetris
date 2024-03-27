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

##############################################################################
# Mutable Data
##############################################################################

GRAVITY:
    .word 60        # Store increment value for gravity
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
    
    # Drawing the starting tetromino
    # $t0: starting x offset
    # $t1: starting y offset 
    # $t2: array address
    # $t3: value of GRAVITY_COUNTER
    # $t4: value of GRAVITY
    # $t5: address for GRAVITY_COUNTER
    # $t9: colour
    
draw_new_tetromino:
    addi $t1, $zero, 0          # Initialize y offset
    lw $t0, STARTING_X_OFFSET   # Initialize x offset
    addi $sp, $sp, -4           # Update stack pointer
    sw $t1, 0($sp)              # Store y offset onto the stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t0, 0($sp)              # Store x offset into the stack
    jal create_T_tetromino      # Set the array for the current tetromino
    lw $t9, PINK                # Store colour in register $t9
    la $t2, T_TETROMINO         # Store array address in register $t2
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
	beq $t1, 1, key_pressed        # If key was pressed ($t1 == 1), jump to key_pressed
	j sleep                 # If key was not pressed, continue to rest of game_loop
    # 1b. Check which key has been pressed
key_pressed:
    lw $t2, 4($t0)                  # Load second word into $t2
    beq $t2, 97, pressed_a          # Check if a was pressed
    beq $t2, 115, pressed_s         # Check if s was pressed, if so check if there is a downward collision
    beq $t2, 100, pressed_d         # Check if d was pressed
    beq $t2, 119, pressed_w         # Check if w was pressed
    beq $t2, 113, pressed_q         # Check if q was pressed
    j sleep
    # 2a. Check for collisions (down-ward collisions are checked in the pressed_s branch)
    
    # When a is pressed, check if there is a collision on the left
    # When d is pressed, check if there is a collision on the right
    # When w is pressed make sure it doesnt collide with a wall or tetromino
    
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
	
	beq $t3, $t4, call_gravity         # When counter reaches value for GRAVITY, move tetromino down 1
	addi $t3, $t3, 1                   # Increase counter value by 1
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

#---------------------------------------------------------------------------------------------------------------------------------------------------------
# Code to handle what key was pressed

pressed_a:
    # $s0: register to store array address
    # $s1: register to store the ROTATION value
    # $t9: register to store the colour of the pixel
    lw $s1, ROTATION                # Store the rotation value in $s1
    beq $s1, 1, a_rotation_1        # If the tetromino has been rotated once
    beq $s1, 2, a_rotation_2        # If the tetromino has been rotated twice
    beq $s1, 3, a_rotation_3        # If the tetromino has been rotated thrice 
    la $s0, T_TETROMINO             # Store the array address into register $t0
    j pressed_a_continuation        # Continue
    
a_rotation_1:
    la $s0, T_TETROMINO_R1          # Store the array address into register $s0
    j pressed_a_continuation        # Continue
    
a_rotation_2:
    la $s0, T_TETROMINO_R2          # Store the array address into register $s0
    j pressed_a_continuation        # Continue
    
a_rotation_3:
    la $s0, T_TETROMINO_R3          # Store the array address into register $s0
    j pressed_a_continuation        # Continue
    
pressed_a_continuation:
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal move_left                   # Update the array to move one to the left
    lw $t9, PINK                    # Store colour in register $t9
    addi $sp, $sp, -4               # Update stack pointer
    sw $t9, 0($sp)                  # Store colour onto the stack
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal redraw_background           # Redraw background
    jal redraw_bitmap_copy          # Redraw previously placed tetrominoes
    jal draw_tetromino              # Draw updated tetromino
    j game_loop



pressed_s:
    # $s0: register to store array address
    # $s1: register to store ROTATION value
    # $t9: register to store colour of the pixel
    addi $sp, $sp, -4               # update stack pointer
    sw $ra, 0($sp)                  # Store $ra on stack pointer
    
    lw $s1, ROTATION                # Store the rotation value in $s1
    beq $s1, 1, s_rotation_1        # If tetromino has been rotated once
    beq $s1, 2, s_rotation_2        # If tetromino has been rotated twice
    beq $s1, 3, s_rotation_3        # If tetromino has been rotated thrice
    la $s0, T_TETROMINO             # Store the array address into register $t0
    j pressed_s_continuation        # Continue
    
s_rotation_1:
    la $s0, T_TETROMINO_R1          # Store the array address in $s0
    j pressed_s_continuation        # Continue
    
s_rotation_2:
    la $s0, T_TETROMINO_R2          # Store the array address in $s0
    j pressed_s_continuation        # Continue
    
s_rotation_3:
    la $s0, T_TETROMINO_R3          # Store the array address in $s0
    j pressed_s_continuation        # Continue
    
pressed_s_continuation:
    # $s0: register to store array address
    # $s1: register to store ROTATION value
    # $t9: register to store colour of the pixel
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal move_down                   # Update the array to move one row down
    lw $t9, PINK                    # Store colour in register $t9
    addi $sp, $sp, -4               # Update stack pointer
    sw $t9, 0($sp)                  # Store colour onto the stack
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal redraw_background         # Redraw background
    jal redraw_bitmap_copy          # Redraw previously placed tetrominoes
    jal draw_tetromino              # Draw updated tetromino
    jal check_downward_collision    # Check if moved tetromino has collided
    lw $ra, 0($sp)                  # Remove $ra from stack pointer
    addi $sp, $sp, 4                # Update stack pointer
    jr $ra                          # Return
    
    

pressed_d:
    # $s0: register to store array address
    # $s1: register to store ROTATION value
    # $t9: register to store colour of the pixel
    lw $s1, ROTATION                # Store value of ROTATION in $s1
    beq $s1, 1, d_rotation_1        # If tetromino has been rotated once
    beq $s1, 2, d_rotation_2        # If tetromino has been rotated twice
    beq $s1, 3, d_rotation_3        # If tetromino has been rotated thrice
    la $s0, T_TETROMINO             # Store the array address into register $t0
    j pressed_d_continuation        # Continue
    
d_rotation_1:
    la $s0, T_TETROMINO_R1          # Store the array address in $s0
    j pressed_d_continuation        # Continue
    
d_rotation_2:
    la $s0, T_TETROMINO_R2          # Store the array address in $s0
    j pressed_d_continuation        # Continue
    
d_rotation_3:
    la $s0, T_TETROMINO_R3          # Store the array address in $s0
    j pressed_d_continuation        # Continue

pressed_d_continuation:
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal move_right                  # Update the array to move one to the right
    lw $t9, PINK                    # Store colour in register $t9
    addi $sp, $sp, -4               # Update stack pointer
    sw $t9, 0($sp)                  # Store colour onto the stack
    addi $sp, $sp, -4               # Update stack pointer
    sw $s0, 0($sp)                  # Put array address on the stack
    jal redraw_background         # Redraw background
    jal redraw_bitmap_copy          # Redraw previously placed tetrominoes
    jal draw_tetromino              # Draw updated tetromino
    j game_loop
    
    
    
pressed_w:
    # $t1: register to store the rotation number
    lw $t1, ROTATION                # Load the value of ROTATION into register $t1
    beq $t1, 0, go_to_R1            # Check if shape is at starting rotation position
    beq $t1, 1, go_to_R2            # Check if shape is at first rotation position
    beq $t1, 2, go_to_R3            # Check if shape is at second rotation position
    beq $t1, 3, go_to_R             # Check if shape is at third rotation position
    
go_to_R:
    # $t1: register to store the rotation number address
    # $t2: register to store the starting address for T_TETROMINO_R3
    # $t3: register to store the starting address + 4, to get value at second index, where the starting position is
    # $t4: register to store the value at the second indes of the starting address
    # $t5: register to store the address for T_TETROMINO
    # $t6: register to store the colour
    # $t7: register to store the value of the new rotation number (0)
    # $t8: register to store starting address for T_TETROMINO
    la $t2, T_TETROMINO_R3          # Get starting address for T_TETROMINO_R3
    addi $t3, $t2, 4                # Add 4 to $t2 and store it in $t3 (to get the starting position)
    lw $t4, ($t3)                   # Get value at the second index
    addi $sp, $sp, -4               # Update stack pointer
    sw $t4, 0($sp)                  # Put the value of $t4 on the stack
    jal T_R3_to_R_tetromino         # Create the T-Tetromino
    la $t8, T_TETROMINO             # Store starting address for T_TETROMINO in $t8
    addi $sp, $sp, -4               # Update stack popinter
    sw $t8, 0($sp)                  # Put $t8 on the stack
    jal check_rotation_collision    # Check if there is any collision when rotation, continue if there is not
    la $t1, ROTATION                # Store the address for the rotation number
    addi $t7, $zero, 0              # Store 0 in $t7
    sw $t7, 0($t1)                  # Store 0 as the new rotation number
    lw $t6, PINK                    # Store the colour in $t6
    addi $sp, $sp, -4               # Update stack pointer
    sw $t6, 0($sp)                  # Store the colour on the stack
    la $t5, T_TETROMINO             # Store the address of the array in $t5
    addi $sp, $sp, -4               # Update stack pointer
    sw $t5, 0($sp)                  # Store the value of $t5 on the stack
    jal redraw_background           # Redraw background
    jal redraw_bitmap_copy          # Redraw previously placed tetrominoes
    jal draw_tetromino              # Draw tetromino
    j game_loop
    
go_to_R1:
    # $t1: register to store the rotation number address
    # $t2: register to store starting address for T_TETROMINO
    # $t3: register to store starting address + 4,  to get value at second index, where the starting position is
    # $t4: register to store the value at the second index of the starting address
    # $t5: register to store address for T_TETROMINO_R1
    # $t6: register to store the colour
    # $t7: register to store value of new rotation number (1)
    # $t8: register to store starting address for T_TETROMINO_R1
    la $t2, T_TETROMINO             # Get starting address for T_TETROMINO
    addi $t3, $t2, 4                # Add 4 to $t2 and store it in $t3 (to get the starting position)
    lw $t4, ($t3)                   # Get value at the second index
    addi $sp, $sp, -4               # Update stack pointer
    sw $t4, 0($sp)                  # Put the value of $t4 on the stack
    jal create_T_R1_tetromino       # Create the R1 T-Tetromino
    la $t8, T_TETROMINO_R1          # Store starting address for T_TETROMINO_R1 in $t8
    addi $sp, $sp, -4               # Update stack popinter
    sw $t8, 0($sp)                  # Put $t8 on the stack
    jal check_rotation_collision    # Check if there is any collision when rotation, continue if there is not
    la $t1, ROTATION                # Store the address for the rotation number
    addi $t7, $zero, 1              # Store 1 in $t7
    sw $t7, 0($t1)                  # Store 1 as the new rotation number
    lw $t6, PINK                    # Store the colour in $t6
    addi $sp, $sp, -4               # Update stack pointer
    sw $t6, 0($sp)                  # Store the colour on the stack
    la $t5, T_TETROMINO_R1          # Store the address of the array in $t5
    addi $sp, $sp, -4               # Update stack pointer
    sw $t5, 0($sp)                  # Store the value of $t5 on the stack
    jal redraw_background         # Redraw background
    jal redraw_bitmap_copy          # Redraw previously placed tetrominoes
    jal draw_tetromino              # Draw tetromino
    j game_loop
    
go_to_R2:
    # $t1: register to store the rotation number address
    # $t2: register to store the starting address for T_TETROMINO_R1
    # $t3: register to store the starting address + 8,  to get value at third index, where the starting position is
    # $t4: register to store the value at the second indes of the starting address
    # $t5: register to store the address for T_TETROMINO_R2
    # $t6: register to store the colour
    # $t7: register to store the value of the new rotation number (2)
    # $t8: register to store starting address for T_TETROMINO_R2
    la $t2, T_TETROMINO_R1          # Get the starting address for T_TETROMINO_R1
    addi $t3, $t2, 8                # Add 8 to $t2 and store it in $t3 (to get the starting position)
    lw $t4, 0($t3)                  # Get the value at the second index and store it in $t4
    addi $sp, $sp, -4               # Update stack pointer
    sw $t4, 0($sp)                  # Store value of $t4 on the stack
    jal create_T_R2_tetromino       # Create the R2 T-Tetromino
    la $t8, T_TETROMINO_R2          # Store starting address for T_TETROMINO_R2 in $t8
    addi $sp, $sp, -4               # Update stack popinter
    sw $t8, 0($sp)                  # Put $t8 on the stack
    jal check_rotation_collision    # Check if there is any collision when rotation, continue if there is not
    la $t1, ROTATION                # Store the address for the ROTATION value
    addi $t7, $zero, 2              # Store 2 in $t7
    sw $t7, 0($t1)                  # Store 2 as the new rotation number
    lw $t6, PINK                    # Store the colour in $t6
    addi $sp, $sp, -4               # Update stack pointer
    sw $t6, 0($sp)                  # Store the colour on the stack
    la $t5, T_TETROMINO_R2          # Store the address of the array in $t5
    addi $sp, $sp, -4               # Update stack pointer
    sw $t5, 0($sp)                  # Store the address of the array on the stack
    jal redraw_background         # Redraw background
    jal redraw_bitmap_copy          # Redraw previously placed tetrominoes
    jal draw_tetromino              # Draw new tetromino
    j game_loop
    
    
    
go_to_R3:
    # $t1: register to store the rotation number address
    # $t2: register to store the starting address for T_TETROMINO_R2
    # $t3: register to store the starting address + 8,  to get value at third index, where the starting position is
    # $t4: register to store the value at the second indes of the starting address
    # $t5: register to store the address for T_TETROMINO_R3
    # $t6: register to store the colour
    # $t7: register to store the value of the new rotation number (3)
    # $t8: register to store starting address for T_TETROMINO_R3
    la $t2, T_TETROMINO_R2          # Get the starting address for T_TETROMINO_R2
    addi $t3, $t2, 8                # Add 8 to $t2 and store it in $t3 (to get the starting position)
    lw $t4, 0($t3)                  # Get the value at the second index and store it in $t4
    addi $sp, $sp, -4               # Update stack pointer
    sw $t4, 0($sp)                  # Store value of $t4 on the stack
    jal create_T_R3_tetromino       # Create the R3 T-Tetromino
    la $t8, T_TETROMINO_R3          # Store starting address for T_TETROMINO_R3 in $t8
    addi $sp, $sp, -4               # Update stack popinter
    sw $t8, 0($sp)                  # Put $t8 on the stack
    jal check_rotation_collision    # Check if there is any collision when rotation, continue if there is not
    la $t1, ROTATION                # Store the address for the ROTATION value
    addi $t7, $zero, 3              # Store 3 in $t7
    sw $t7, 0($t1)                  # Store 3 as the new rotation number
    lw $t6, PINK                    # Store the colour in $t6
    addi $sp, $sp, -4               # Update stack pointer
    sw $t6, 0($sp)                  # Store the colour on the stack
    la $t5, T_TETROMINO_R3          # Store the address of the array in $t5
    addi $sp, $sp, -4               # Update stack pointer
    sw $t5, 0($sp)                  # Store the address of the array on the stack
    jal redraw_background           # Redraw background
    jal redraw_bitmap_copy          # Redraw previously placed tetrominoes
    jal draw_tetromino              # Draw new tetromino
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
    # $t5: register to store the colour at the specified address]
    # $t6: register to store the address + index offset
    # $t9: register to store the address of ROTATION
    
    addi $sp, $sp, -4           # Update stack pointer
    sw $ra, 0($sp)              # Store $ra on store
    
    lw $t0, ROTATION            # Store the value of ROTATION in $t0
    lw $t1, TETROMINO_TYPE      # Store the value of TETROMINO_TYPE in $t1
    
    # Check rotation value and tetromino type to determine current tetromino
    beq $t1, 116, T             # If tetromino type is T, go to T section
    
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
    
game_over:
    j main                              # Game is over, currently start a new game automatically
    
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