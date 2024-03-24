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

DARK_PURPLE:
    .word 0x1f124a # colour for wall
LIGHT_GREY:
    .word 0x303030 # colour for background
DARK_GREY:
    .word 0x202020 # colour for background
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

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
main:
    # Initialize the game
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
    
    j exit
    
game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
     b game_loop



draw_rectangle:
    # $a0: register to store original x offset
    # $a1: register to store original y offset
    # $t0: register for starting address
    # $t1: register to store x offset
    # $t2: register to store y offset
    # $t3: register to store width in pixels
    # $t4: register to store the length in pixels
    # $t5: register to store current address
    # $t9: register to store colour
    
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
    lw $t9, 0($sp)              # Get colour from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # Horizontal offset and and width
    sll $t1, $a0, 2             # Calculate horizontal offset (x offset * 4)
    sll $t3, $t3, 2             # Convert the width from pixels to bytes (multiply by 4)
    add $t3, $t3, $t1           # Add original starting point to width to get end width
    
    # Vertical offset and length
    sll $t2, $t2, 7             # Calculate vertical offset (y offset * 128)
    sll $t4, $t4, 7             # Convert the length from pixels to bytes (multiply by 128)
    add $t4, $t4, $t2           # Add original starting point to the length to get the end length
    
draw_reactangle_top:
    sll $t1, $a0, 2             # Calculate horizontal offset (x offset * 4)
    add $t5, $t1, $t2           # update current offset value where the pixel will be drawn
    
draw_line_top:
    add $t5, $t1, $t2                   # Calculate total offset
    add $t5, $t5, $t0                   # Add offset to starting address
    sw $t9, 0($t5)                      # Draw pixel at starting address
    addi $t1, $t1, 4                    # Increment horizontal offset
    beq $t1, $t3, draw_line_end         # Check if offset == width, if so exit loop
    j draw_line_top                     # Jump back to top of loop
    
draw_line_end:
    addi $t2, $t2, 128                  # Increment the vertical offset
    beq $t2 ,$t4, draw_rectangle_end    # Check if length offset == end length, if so exit loop
    j draw_reactangle_top               # Jump back to top of loop
    
draw_rectangle_end:
    jr $ra                      # return



draw_T_tetromino:
    # $a0: register to store original x offset value from the stack
    # $a1: register to store original y offset value from the stack
    # $t0: register to store x offset
    # $t1: register to store y offset
    # $t2: register to store width
    # $t3: register to store length
    # $t9: register to store the colour for the T tetromino (PINK)
    
    # Get values from the stack
    lw $a0, 0($sp)              # Get starting position x offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    addi $t0, $a0, 0            # Store x offset in $t0
    lw $a1, 0($sp)              # Get starting position y offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    addi $t1, $a1, 0            # Store y offset on $t1
    
    lw $t9, PINK                # Store the colour in $t9
    
    # Modify x offset to draw the 3 pixel horizontal line
    addi $t0, $t0, -1           # Subtract one so position is at the start of the line
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
    sw $t9, 0($sp)              # Store value of $t9 (colour) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t3, 0($sp)              # Store value of $t3 (length) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t2, 0($sp)              # Store value of $t2 (width) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t1, 0($sp)              # Store value of $t1 (y offset) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t0, 0($sp)              # Store value of $t0 (x offset) on stack
    jal draw_rectangle          # Call function to draw line
    
    # Take parameters off of the stack
    lw $t9, 0($sp)              # Remove colour value from the stack
    addi $sp, $sp, 4            # Update stack pointer
    lw $t1, 0($sp)              # Remove original y offset from the stack
    addi $sp, $sp 4             # Update stack pointer
    lw $t0, 0($sp)              # Remove original x offset from the stack
    addi $sp, $sp, 4            # Update stack pointer
    lw $ra, 0($sp)              # Remove $ra from the stack
    addi $sp, $sp, 4            # Update stack pointer
    
    # Modify values
    addi $t1, $t1, 1            # Modify y offset to draw the 1 pixel below
    addi $t2, $zero, 1          # Set width to 1
    addi $t3, $zero, 1          # Set height to 1
    # Put parameters onto the stack
    # Need to pass the values of $t0, $t1, $t2, $t3, and $t9 to the function
    addi $sp, $sp, -4           # Update stack pointer
    sw $t9, 0($sp)              # Store value of $t9 (colour) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t3, 0($sp)              # Store value of $t3 (length) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t2, 0($sp)              # Store value of $t2 (width) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t1, 0($sp)              # Store value of $t1 (y offset) on stack
    addi $sp, $sp, -4           # Update stack pointer
    sw $t0, 0($sp)              # Store value of $t0 (x offset) on stack
    jal draw_rectangle          # Call function to draw line
    jr $ra                      # return
    
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

exit:
li $v0, 10 # terminate the program gracefully
syscall