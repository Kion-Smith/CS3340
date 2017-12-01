# Authors: Brandon Allion, Kion Smith, Rafael Sanchez 
# Class: CS 3340.001
# Date: 11/30/17
# Description: Here is Othello developed in Mips Assembly. It utilizes an array in memory
# which can remember a players move and algorithms which perform the game logic.

.data
	Prompt1: .asciiz "Enter x coordinate (1-8): "
	Prompt2: .asciiz "Enter y coordinate (1-8): "
	Prompt69: .asciiz "Debugging: "
	p1WinPrompt: .asciiz "PLAYER 1 WINS GRATZ!"
	p2WinPrompt: .asciiz "PLAYER 2 WINS BETTER LUCK NEXT TIME!"
	
	xVal:		.word	0
	yVal:		.word	0
	
	xPiece:		.byte	'X'
	oPiece:		.byte	'0'
	dash:		.byte	'-'
	
	mdArray: .byte  '-','-','-','-','-','-','-','-'
			'-','-','-','-','-','-','-','-'
			'-','-','-','-','-','-','-','-'
			'-','-','-','X','0','-','-','-'
			'-','-','-','0','X','-','-','-'
			'-','-','-','-','-','-','-','-'
			'-','-','-','-','-','-','-','-'
			'-','-','-','-','-','-','-','-'
			 
	size:    .word 1
	.eqv 	 DATA_SIZE 1 #number of bytes per data
	
	takenMessage:	.asciiz	"That input is not valid, that tile is already taken."
	nextToOpponentMessage: .asciiz "That input is not valid, it is not next to an opponent piece"  
	sandwichErrorMessage: .asciiz "That input is not valid, two of your pieces do not sandwich their piece(s)"
	noMovesMessage: .asciiz "There are no more available moves" 
.text
main: 

addi $s1, $zero, 0
while:
	bgt $s1, 1, exit
	
	
	
	
#Print board
#======================================================================================================
	la $t0, mdArray          #address of the first element
        li $t1, 0
	li $t2, 0 		 #controls the loop
	li $t3, 64 
	loop:
	bgt $t2, $t3, end # if t1 == 10 we are done
	
	ble $t1, 7, needsNL
	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall
	li $t1, 0
	needsNL:
	addi $t1, $t1, 1
	
	lb    $a0, ($t0)            # hexdigits[10] (which is 'A')
	li    $v0, 11                 # I will assume syscall 11 is printchar (most simulators support it)
	syscall
	
	addi $t0, $t0, 1 # moves 1 index further in the array
	addi $t2, $t2, 1 
	j loop # jump back to the top
	end:	
#======================================================================================================



userInput: 
#this is going to detect if the player can make a move
addi $t0, $zero, 0 	#this resets the index to zero to be able to test every point for availble moves 
addi $t8, $zero, 0 	#this is being used as a counter. If this counter is not zero, then
			#then there is still an available move
j availableMove	
userInput1:
#get Input X, Y
#======================================================================================================
	# Prompt for input X
   	 li   $v0, 4
   	 la   $a0, Prompt1
    	 syscall
   	 # Read input
   	 li   $v0, 5
   	 syscall
   	 sw	$v0, xVal
   	 # Prompt for input Y
   	 li   $v0, 4
   	 la   $a0, Prompt2
    	 syscall
   	 # Read input
   	 li   $v0, 5
   	 syscall
   	 sw	$v0, yVal
#======================================================================================================
	
#	reset registers
	addi $t0, $zero, 0 
	addi $t1, $zero, 0 
	addi $t2, $zero, 0 




#move detection and error messaging 
#======================================================================================================

#will need to jump back to start if error detected
#maybe cheat time by not including the middle man case
#focus on next to and on top of case
#======================================================================================================	




#calculate position in array
#======================================================================================================
	lw $t1, yVal
	addi $t1, $t1 -1
	addi $t2, $t2, 8
	mult $t1, $t2
	mflo $t1
	
	lw $t0, xVal
	add $t0, $t0, $t1
	addi $t0, $t0, -1


#input validation - checking if coordinate is taken
#======================================================================================================
taken: 
	lb $t4, mdArray($t0)
	bne $t4, '-', errorMessageT	#if(t4!='-') // because '-' is the negative space on the board
	j nextToOpponent
	#ouput for wrong coordinate becuase the tile was taken
errorMessageT:	
	#outputting error message prompt 
	li   $v0, 4
   	la   $a0, takenMessage
    	syscall
    	#newline
    	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall
    	j userInput
#======================================================================================================




#input validation - checking if move is next to opponent 
#======================================================================================================
nextToOpponent:		#tests if the move is next to the opponnent 
			#will scan 8 immidiate places around the move for opponent 
			#and will then scan the row/column/diagnal for sandwiched pieces
	addi $t8, $zero, 0 	#t8 will give the indication that it was a legal move 
				#and will make the error messages not prompt 
	addi $t7, $zero, 0 	#t7 will give the indication to know if to display
				#error message for sandwiched pieces
	addi $t9, $zero, 0 	#t9 will be used as a counter variable
north: 		#scans the position above the coordinate for an opponents piece 
	#calculate position in array to the north
	#will use #t4 as input validation index 
	lw $t5, yVal
	addi $t6, $zero, 0	#resetting t6 register 
	addi $t5, $t5 -1
	addi $t6, $t6, 8
	mult $t5, $t6
	mflo $t5
	
	lw $t4, xVal
	add $t4, $t4, $t5
	addi $t4, $t4, -1
	addi $t4, $t4, -8 	#this gives the index north to the coordinate indicated
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t1, -1	#looking at the position above the coordinate the user entered 
	blt $t3, 1, northEast	#if(t3<1) check northEast
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '0', xNorth 	#check if its a sandwich
	j northEast
	

northEast: 	#scans the position northeast of the chosen coordinate point 
	#calculate position in array to the north
	#will use #t4 as input validation index 
	lw $t5, yVal
	addi $t6, $zero, 0	#resetting t6 register
	addi $t5, $t5 -1
	addi $t6, $t6, 8
	mult $t5, $t6
	mflo $t5
	
	lw $t4, xVal
	add $t4, $t4, $t5
	addi $t4, $t4, -1
	addi $t4, $t4, -7 	#this gives the index northeast to the coordinate indicated
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t1, -1	#looking at the position norht the coordinate the user entered 
	blt $t3, 1, east
	
	addi $t3, $t2, 1	#looking at the position east the coordinate the user entered 
	bgt $t3, 8, east
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into  
	beq $t5, '0', xNorthEast 	#check if sandwich
	j east
	
					
east: 		#scans the position east of the chosen coordinate 
	#calculate position in array to the north
	#will use #t4 as input validation index 
	lw $t5, yVal
	addi $t6, $zero, 0	#resetting t6 register
	addi $t5, $t5 -1
	addi $t6, $t6, 8
	mult $t5, $t6
	mflo $t5
	
	lw $t4, xVal
	add $t4, $t4, $t5
	addi $t4, $t4, -1
	addi $t4, $t4, 1 	#this gives the index east to the coordinate indicated
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t2, 1	#looking at the position east the coordinate the user entered 
	bgt $t3, 8, southEast	#if(t3>8) check east
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5 
	beq $t5, '0', xEast 	#check if its a sandwich
	j southEast

			
southEast: 	#scans the position southEast of the chosen coordinate point 
	#calculate position in array to the north
	#will use #t4 as input validation index 
	lw $t5, yVal
	addi $t6, $zero, 0	#resetting t6 register
	addi $t5, $t5 -1
	addi $t6, $t6, 8
	mult $t5, $t6
	mflo $t5
	
	lw $t4, xVal
	add $t4, $t4, $t5
	addi $t4, $t4, -1
	addi $t4, $t4, 9 	#this gives the index northeast to the coordinate indicated
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t2, 1	#looking at the position east the coordinate the user entered 
	bgt $t3, 8, south
	
	addi $t3, $t1, 1	#looking at the position south the coordinate the user entered 
	bgt $t3, 8, south
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5 
	beq $t5, '0', xSouthEast 	#check if its a sandwich
	j south	


south: 		#scans the position south the coordinate for an opponents piece 
	#calculate position in array to the north
	#will use #t4 as input validation index 
	lw $t5, yVal
	addi $t6, $zero, 0	#resetting t6 register
	addi $t5, $t5 -1
	addi $t6, $t6, 8
	mult $t5, $t6
	mflo $t5
	
	lw $t4, xVal
	add $t4, $t4, $t5
	addi $t4, $t4, -1
	addi $t4, $t4, 8 	#this gives the index south to the coordinate indicated
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t1, 1	#looking at the position south the coordinate the user entered 
	bgt $t3, 8, southWest	#if(t3>8) check southwest
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5 
	beq $t5, '0', xSouth 	#check if its a sandwich
	j southWest	


southWest: 	#scans the position southwest of the chosen coordinate point 
	#calculate position in array to the southWest
	#will use #t4 as input validation index 
	lw $t5, yVal
	addi $t6, $zero, 0	#resetting t6 register
	addi $t5, $t5 -1
	addi $t6, $t6, 8
	mult $t5, $t6
	mflo $t5
	
	lw $t4, xVal
	add $t4, $t4, $t5
	addi $t4, $t4, -1
	addi $t4, $t4, 7	#this gives the index southWest to the coordinate indicated
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t1, 1	#looking at the position south the coordinate the user entered 
	bgt $t3, 8, west
	
	addi $t3, $t2, -1	#looking at the position west the coordinate the user entered 
	blt $t3, 1, west
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5 
	beq $t5, '0', xSouthWest 	#check if its a sandwich
	j west	


west: 		#scans the position west of the chosen coordinate 
	#calculate position in array to the north
	#will use #t4 as input validation index 
	lw $t5, yVal
	addi $t6, $zero, 0	#resetting t6 register
	addi $t5, $t5 -1
	addi $t6, $t6, 8
	mult $t5, $t6
	mflo $t5
	
	lw $t4, xVal
	add $t4, $t4, $t5
	addi $t4, $t4, -1
	addi $t4, $t4, -1 	#this gives the index west to the coordinate indicated
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t2, -1	#looking at the position west the coordinate the user entered 
	blt $t3, 1, northWest	#if(t3<1) check norhtEast
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5 
	beq $t5, '0', xWest 	#check if its a sandwich
	j northWest
	

#all of the error messages are ouputted here because this is the last place that is checked 			
northWest: 		#scans the position northwest of the chosen coordinate 
	#calculate position in array to the northwest
	#will use #t4 as input validation index 
	lw $t5, yVal
	addi $t6, $zero, 0	#resetting t6 register
	addi $t5, $t5 -1
	addi $t6, $t6, 8
	mult $t5, $t6
	mflo $t5
	
	lw $t4, xVal
	add $t4, $t4, $t5
	addi $t4, $t4, -1
	addi $t4, $t4, -9 	#this gives the index northwest to the coordinate indicated
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t2, -1	#looking at the position west the coordinate the user entered 
	bge $t3, 1, checkNext1
	bge $t7, 1, placeholder 	##if(t7>=1) dont ouput any error messagesbecuase tiles were flipped
	bge $t8, 1, sandwichError 	#this will skip the "not next to opponent" error message and will
					#instead display the sandwich error message 
					#"That input is not valid, two of your pieces do not sandwich their piece(s)"	
	#outputting not next to opponent error prompt 
	li   $v0, 4
   	la   $a0, nextToOpponentMessage 	#"That input is not valid, it is not next to an opponent piece" 
    	syscall
    	#newline
    	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall
	j userInput 
	
checkNext1: 		#doing it this way to be able to give error message 	
	addi $t3, $t1, -1	#looking at the position north the coordinate the user entered 
	bge $t3, 1, checkNext2 	
	bge $t7, 1, placeholder		#if(t7>=1) dont ouput any error messages becuase tiles were flipped
	bge $t8, 1, sandwichError 	#this will skip the "not next to opponent" error message and will
					#instead display the sandwich error message 
					#"That input is not valid, two of your pieces do not sandwich their piece(s)"
	#outputting not next to opponent error prompt 
	li   $v0, 4
   	la   $a0, nextToOpponentMessage 	#"That input is not valid, it is not next to an opponent piece" 
    	syscall
    	#newline
    	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall

checkNext2:		#doing it this way to be able to give error message 	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5 
	beq $t5, '0', xNorthWest 	#check if its a sandwich
returnHere: 		#this is so that the tile flips has a function to return to 	
	bge $t7, 1, placeholder		#if(t7>=1) dont ouput any error messages becuase tiles were flipped
	bge $t8, 1, sandwichError 	#this will skip the "not next to opponent" error message and will
					#instead display the sandwich error message 
					#"That input is not valid, two of your pieces do not sandwich their piece(s)"	
	#outputting not next to opponent error prompt 
	li   $v0, 4
   	la   $a0, nextToOpponentMessage 	#"That input is not valid, it is not next to an opponent piece" 
    	syscall
    	#newline
    	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall
	j userInput
	
sandwichError: 		#displays the sandwich error message 
			#"That input is not valid, two of your pieces do not sandwich their piece(s)"	
	#outputting not a sandwich error prompt 
	li   $v0, 4
   	la   $a0, sandwichErrorMessage 	#"That input is not valid, it is not next to an opponent piece" 
    	syscall
    	#newline
    	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall
	j userInput
#======================================================================================================	



#input validation - sandwich error checking
#======================================================================================================
#I will be be using $t9 as a counter variable, to count the number iterations a loop has been done 
xNorth: 	#looks for another player 1 piece north of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, -8 	#this gives the index north to the player 2 coordinate 
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t1, -1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	sub $t3, $t3, $t9	#looking at the position above the coordinate the user entered 
	blt $t3, 1, jOutNorth 	#if(t3<1) check other directions 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '-', jOutNorth	#check other directions because reached negative space instead of X
	j checkXNorth
	
jOutNorth: 	#Takes us back to check the other dircetions 
	addi $t8, $t8, 1	#will prompt error message for no sandwiched pieces
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j northEast
	
checkXNorth: 	#looks at the row/column/diagnoal for a for a player piece, will repeat until reaches edge
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	bne $t5, 'X', xNorth 

northAlg: 		#this is the algorithm to change a row to the player tile 
	lb $a0, xPiece		
	blt $t9, 1, northAlgDone 
	addi $t9, $t9, -1 	#decreasing the counter to ensure only flip correct number of tiles
	addi $t4, $t4, 8 	#have to decrease index becuase dont need to change to player tile which its one now
	sb $a0, mdArray($t4) 	#changes the tile to current player tile
	j northAlg

northAlgDone: 	
	addi $t7, $t7, 1 	#used to ensure the error messages dont prompt 
				#still have to keep checking otherdirections because 
				#there can still be sandiwiches in the other directions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j northEast
	


xNorthEast: 	#looks for another player 1 piece northEAst of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, -7 	#this gives the index northEast to the player 2 coordinate 
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t1, -1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	sub $t3, $t3, $t9	#checking if the sequential pieces reach the edge
	blt $t3, 1, jOutNorthEast 	#if(t3<1) check other directions 
	addi $t3, $t2, 1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	add $t3, $t3, $t9 	#checking the sequential pieces
	bgt $t3, 8, jOutNorthEast	#check other directions if fall off edge 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '-', jOutNorthEast	#check other directions because reached negative space instead of X
	j checkXNorthEast
	
jOutNorthEast: 		#Takes us back to check the other dircetions 
	addi $t8, $t8, 1	#will prompt error message for no sandwiched pieces
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j east
	
checkXNorthEast: 	#looks at the row/column/diagnoal for a for a white piece, will repeat until reaches edge
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	bne $t5, 'X', xNorthEast 

northEastAlg: 		#this is the algorithm to change a row to the player tile 
	lb $a0, xPiece		
	blt $t9, 1, northEastAlgDone 
	addi $t9, $t9, -1 	#decreasing the counter to ensure only flip correct number of tiles
	addi $t4, $t4, 7 	#have to decrease index becuase dont need to change to player tile which its one now
	sb $a0, mdArray($t4) 	#changes the tile to current player tile
	j northEastAlg

northEastAlgDone: 	
	addi $t7, $t7, 1 	#used to ensure the error messages dont prompt 
				#still have to keep checking otherdirections because 
				#there can still be sandiwiches in the other directions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j east



xEast: 	#looks for another player 1 piece east of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, 1 	#this gives the index east to the player 2 coordinate 
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t2, 1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	add $t3, $t3, $t9 	#checking the sequential pieces
	bgt $t3, 8, jOutEast	#check other directions if fall off edge 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '-', jOutEast	#check other directions because reached negative space instead of X
	j checkXEast
	
jOutEast: 		#Takes us back to check the other dircetions 
	addi $t8, $t8, 1	#will prompt error message for no sandwiched pieces
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j southEast
	
checkXEast: 	#looks at the row/column/diagnoal for a for a white piece, will repeat until reaches edge
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	bne $t5, 'X', xEast 

eastAlg: 		#this is the algorithm to change a row to the player tile 
	lb $a0, xPiece		
	blt $t9, 1, eastAlgDone 
	addi $t9, $t9, -1 	#decreasing the counter to ensure only flip correct number of tiles
	addi $t4, $t4, -1 	#have to decrease index becuase dont need to change to player tile which its one now
	sb $a0, mdArray($t4) 	#changes the tile to current player tile
	j eastAlg

eastAlgDone: 	
	addi $t7, $t7, 1 	#used to ensure the error messages dont prompt 
				#still have to keep checking otherdirections because 
				#there can still be sandiwiches in the other directions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j southEast



xSouthEast: 	#looks for another player 1 piece southEast of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, 9 	#this gives the index southEast to the player 2 coordinate 
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t1, 1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	add $t3, $t3, $t9	#checking if the sequential pieces reach the edge
	bgt $t3, 8, jOutSouthEast 	#if(t3<1) check other directions 
	addi $t3, $t2, 1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	add $t3, $t3, $t9 	#checking the sequential pieces
	bgt $t3, 8, jOutSouthEast	#check other directions if fall off edge 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '-', jOutSouthEast	#check other directions because reached negative space instead of X
	j checkXSouthEast
	
jOutSouthEast: 		#Takes us back to check the other dircetions 
	addi $t8, $t8, 1	#will prompt error message for no sandwiched pieces
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j south
	
checkXSouthEast: 	#looks at the row/column/diagnoal for a for a white piece, will repeat until reaches edge
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	bne $t5, 'X', xSouthEast 

southEastAlg: 		#this is the algorithm to change a row to the player tile 
	lb $a0, xPiece		
	blt $t9, 1, southEastAlgDone 
	addi $t9, $t9, -1 	#decreasing the counter to ensure only flip correct number of tiles
	addi $t4, $t4, -9 	#have to decrease index becuase dont need to change to player tile which its one now
	sb $a0, mdArray($t4) 	#changes the tile to current player tile
	j southEastAlg

southEastAlgDone: 	
	addi $t7, $t7, 1 	#used to ensure the error messages dont prompt 
				#still have to keep checking otherdirections because 
				#there can still be sandiwiches in the other directions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j south



xSouth: 	#looks for another player 1 piece south of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, 8 	#this gives the index south to the player 2 coordinate 
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t1, 1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	add $t3, $t3, $t9	#checking if the sequential pieces reach the edge
	bgt $t3, 8, jOutSouth 	#if(t3<1) check other directions 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '-', jOutSouth	#check other directions because reached negative space instead of X
	j checkXSouth
	
jOutSouth: 		#Takes us back to check the other dircetions 
	addi $t8, $t8, 1	#will prompt error message for no sandwiched pieces
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j southWest
	
checkXSouth: 	#looks at the row/column/diagnoal for a for a white piece, will repeat until reaches edge
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	bne $t5, 'X', xSouth 
	
southAlg: 		#this is the algorithm to change a row to the player tile 
	lb $a0, xPiece		
	blt $t9, 1, southAlgDone 
	addi $t9, $t9, -1 	#decreasing the counter to ensure only flip correct number of tiles
	addi $t4, $t4, -8 	#have to decrease index becuase dont need to change to player tile which its one now
	sb $a0, mdArray($t4) 	#changes the tile to current player tile
	j southAlg

southAlgDone: 	
	addi $t7, $t7, 1 	#used to ensure the error messages dont prompt 
				#still have to keep checking otherdirections because 
				#there can still be sandiwiches in the other directions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j southWest
	


xSouthWest: 	#looks for another player 1 piece southwest of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, 7 	#this gives the index southwest to the player 2 coordinate 
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	add $t3, $t1, 1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	add $t3, $t3, $t9	#checking if the sequential pieces reach the edge
	bgt $t3, 8, jOutSouthWest	#if(t3<1) check other directions 
	addi $t3, $t2, -1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	sub $t3, $t3, $t9 	#checking the sequential pieces
	blt $t3, 1, jOutSouthWest	#check other directions if fall off edge 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '-', jOutSouthWest	#check other directions because reached negative space instead of X
	j checkXSouthWest
	
jOutSouthWest: 		#Takes us back to check the other dircetions 
	addi $t8, $t8, 1	#will prompt error message for no sandwiched pieces
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j west
	
checkXSouthWest: 	#looks at the row/column/diagnoal for a for a white piece, will repeat until reaches edge
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	bne $t5, 'X', xSouthWest 

southWestAlg: 		#this is the algorithm to change a row to the player tile 
	lb $a0, xPiece		
	blt $t9, 1, southWestAlgDone 
	addi $t9, $t9, -1 	#decreasing the counter to ensure only flip correct number of tiles
	addi $t4, $t4, -7	#have to decrease index becuase dont need to change to player tile which its one now
	sb $a0, mdArray($t4) 	#changes the tile to current player tile
	j southWestAlg

southWestAlgDone: 	
	addi $t7, $t7, 1 	#used to ensure the error messages dont prompt 
				#still have to keep checking otherdirections because 
				#there can still be sandiwiches in the other directions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j west
	
	
	
xWest: 	#looks for another player 1 piece west of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, -1 	#this gives the index west to the player 2 coordinate 
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	addi $t3, $t2, -1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	sub $t3, $t3, $t9 	#checking the sequential pieces
	blt $t3, 1, jOutWest	#check other directions if fall off edge 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '-', jOutWest	#check other directions because reached negative space instead of X
	j checkXWest
	
jOutWest: 		#Takes us back to check the other dircetions 
	addi $t8, $t8, 1	#will prompt error message for no sandwiched pieces
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j northWest
	
checkXWest: 	#looks at the row/column/diagnoal for a for a white piece, will repeat until reaches edge
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	bne $t5, 'X', xWest 

westAlg: 		#this is the algorithm to change a row to the player tile 
	lb $a0, xPiece		
	blt $t9, 1, westAlgDone 
	addi $t9, $t9, -1 	#decreasing the counter to ensure only flip correct number of tiles
	addi $t4, $t4, 1 	#have to decrease index becuase dont need to change to player tile which its one now
	sb $a0, mdArray($t4) 	#changes the tile to current player tile
	j westAlg

westAlgDone: 	
	addi $t7, $t7, 1 	#used to ensure the error messages dont prompt 
				#still have to keep checking otherdirections because 
				#there can still be sandiwiches in the other directions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j northWest
	
	
	
xNorthWest: 	#looks for another player 1 piece northwest of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, -9 	#this gives the index northwest to the player 2 coordinate 
	
	#branching
	lw $t1 yVal
	lw $t2 xVal
	add $t3, $t1, -1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	sub $t3, $t3, $t9	#checking if the sequential pieces reach the edge
	blt $t3, 1, jOutNorthWest	#if(t3<1) check other directions 
	addi $t3, $t2, -1	#this is being done to reset the value of t3 for the purposes of when its used elsewhere
	sub $t3, $t3, $t9 	#checking the sequential pieces
	blt $t3, 1, jOutNorthWest	#check other directions if fall off edge 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '-', jOutNorthWest	#check other directions because reached negative space instead of X
	j checkXNorthWest
	
jOutNorthWest: 		#Takes us back to check the other dircetions 
	addi $t8, $t8, 1	#will prompt error message for no sandwiched pieces
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j returnHere
	
checkXNorthWest: 	#looks at the row/column/diagnoal for a for a white piece, will repeat until reaches edge
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	bne $t5, 'X', xNorthWest 

northWestAlg: 		#this is the algorithm to change a row to the player tile 
	lb $a0, xPiece		
	blt $t9, 1, northWestAlgDone 
	addi $t9, $t9, -1 	#decreasing the counter to ensure only flip correct number of tiles
	addi $t4, $t4, -8 	#have to decrease index becuase dont need to change to player tile which its one now
	sb $a0, mdArray($t4) 	#changes the tile to current player tile
	j northWestAlg

northWestAlgDone: 	
	addi $t7, $t7, 1 	#used to ensure the error messages dont prompt 
				#still have to keep checking otherdirections because 
				#there can still be sandiwiches in the other directions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j returnHere


placeholder: 	
#can insert tile
#======================================================================================================
insert: 
	lb $v0, xPiece 
	sb $v0, mdArray($t0)
	j player2
#======================================================================================================
#This part of the program test if there is an avaiable move for player 2 
#======================================================================================================
availableMove: 		#looks at the entire board to check if there is an available move
	
AMTaken: 	#testing all spaces for an available space 
	lb $t4, mdArray($t0)	#loading byte of that coordinate into t4 
	bne $t4, 'X', noMoves	#if(t4!='-') // because '-' is the negative space on the board
	j AMNextToOpponent

AMNextToOpponent:	#tests if the point is next to the opponnent 
			#will scan 8 immidiate places around the move for opponent 
			#and will then scan the row/column/diagnal for sandwiched pieces
	addi $t4, $zero, 0
	addi $t9, $zero, 0 	#this will be used as a counter for loops 
AMnorth: 		#scans the position above the coordinate for an opponents piece 
	#calculate position in array to the north
	#will use #t4 as input validation index 
	add $t4, $zero, $t0 	#making the input validation index equal to current index
	addi $t4, $t4, -8	#to check the position north of the current index
	
	#branching
	blt $t4, 0, AMnorthEast	#if index is neg, it has gone out of bounds, check other 
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, 'X', AMxNorth 	#check if its a sandwich
	j AMnorthEast
	
	
AMnorthEast: 		#scans the position above the coordinate for an opponents piece 
	#calculate position in array to the northeast
	#will use #t4 as input validation index 
	add $t4, $zero, $t0 	#making the input validation index equal to current index
	addi $t4, $t4, -7	#to check the position northeast of the current index
	
	#branching
	blt $t4, 0, AMeast	#if index is neg, it has gone out of bounds, check other 
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, 'X', AMxNorthEast 	#check if its a sandwich
	j AMeast
	

AMeast: 		#scans the position east the coordinate for an opponents piece 
	#calculate position in array to the east
	#will use #t4 as input validation index 
	add $t4, $zero, $t0 	#making the input validation index equal to current index
	addi $t4, $t4, 1	#to check the position east of the current index
	
	#branching
	bgt $t4, 63, AMsouthEast	#if index is greater than 63, it has gone out of bounds, check other 
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, 'X', AMxEast 	#check if its a sandwich
	j AMsouthEast
	
	
AMsouthEast: 		#scans the position southeast the coordinate for an opponents piece 
	#calculate position in array to the southeast
	#will use #t4 as input validation index 
	add $t4, $zero, $t0 	#making the input validation index equal to current index
	addi $t4, $t4, 9	#to check the position southeast of the current index
	
	#branching
	bgt $t4, 63, AMsouth	#if index is greater than 63, it has gone out of bounds, check other 
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, 'X', AMxSouthEast 	#check if its a sandwich
	j AMsouth
	
	
AMsouth: 		#scans the position south the coordinate for an opponents piece 
	#calculate position in array to the south
	#will use #t4 as input validation index 
	add $t4, $zero, $t0 	#making the input validation index equal to current index
	addi $t4, $t4, 8	#to check the position south of the current index
	
	#branching
	bgt $t4, 63, AMsouthWest	#if index is greater than 63, it has gone out of bounds, check other 
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, 'X', AMxSouth	#check if its a sandwich
	j AMsouthWest
	
	
AMsouthWest: 		#scans the position southwest the coordinate for an opponents piece 
	#calculate position in array to the southwest
	#will use #t4 as input validation index 
	add $t4, $zero, $t0 	#making the input validation index equal to current index
	addi $t4, $t4, 7	#to check the position southwest of the current index
	
	#branching
	bgt $t4, 63, AMwest	#if index is greater than 63, it has gone out of bounds, check other 
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, 'X', AMxSouthWest 	#check if its a sandwich
	j AMwest
	
	
AMwest: 		#scans the position west the coordinate for an opponents piece 
	#calculate position in array to the west
	#will use #t4 as input validation index 
	add $t4, $zero, $t0 	#making the input validation index equal to current index
	addi $t4, $t4, -1	#to check the position west of the current index
	
	#branching
	blt $t4, 0, AMnorthWest	#if index is neg, it has gone out of bounds, check other 
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, 'X', AMxWest 	#check if its a sandwich
	j AMnorthWest
	

AMnorthWest: 		#scans the position northWest the coordinate for an opponents piece 
	#calculate position in array to the northwest
	#will use #t4 as input validation index 
	add $t4, $zero, $t0 	#making the input validation index equal to current index
	addi $t4, $t4, -9	#to check the position northwest of the current index
	
	#branching
	blt $t4, 0, noMoves	#if index is neg, it has gone out of bounds, no other sides
				#sides to check, give indication if moves possible 
	
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, 'X', AMxNorthWest 	#check if its a sandwich
	j noMoves
	
#======================================================================================================


#this looks for possible sandwiches 
#======================================================================================================
#I will be be using $t9 as a counter variable, to count the number iterations a loop has been done 
AMxNorth: 	#looks for another player 1 piece north of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, -8 	#this gives the index north to the checked coordinate 
	
	#branching
	blt $t4, 0, AMjOutNorth	#if index is neg, it has gone out of bounds, check other 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '0', AMxNorth 	#there still might be a possible sandwich, check next possiblity 
	bne $t5, '-', AMjOutNorth	#check other directions because reached negative space instead of X
	j userInput1	#jump back to user input 
	
AMjOutNorth: 	#Takes us back to check the other dircetions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j AMnorthEast
	
AMcheckXNorth: 	#looks at the row/column/diagnoal for a for a player piece, will repeat until reaches edge
	addi $t8, $t8, 1	#This tells us that there is a valid move 
	j userInput1 


AMxNorthEast: 	#looks for another player 1 piece northeast of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, -7 	#this gives the index northeast to the checked coordinate 
	
	#branching
	blt $t4, 0, AMjOutNorthEast	#if index is neg, it has gone out of bounds, check other 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '0', AMxNorthEast 	#there still might be a possible sandwich, check next possiblity 
	bne $t5, '-', AMjOutNorthEast	#check other directions because reached negative space instead of X
	j userInput1	#jump back to user input 
	
AMjOutNorthEast: 	#Takes us back to check the other dircetions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j AMeast
	
AMcheckXNorthEast: 	#looks at the row/column/diagnoal for a for a player piece, will repeat until reaches edge
	addi $t8, $t8, 1	#This tells us that there is a valid move 
	j userInput1 


AMxEast: 	#looks for another player 1 piece east of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, 1 	#this gives the index east to the checked coordinate 
	
	#branching
	bgt $t4, 63, AMjOutEast	#if index is bigger than 63, it has gone out of bounds 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '0', AMxEast 	#there still might be a possible sandwich, check next possiblity 
	bne $t5, '-', AMjOutEast	#check other directions because reached negative space instead of X
	j userInput1	#jump back to user input 
	
AMjOutEast: 	#Takes us back to check the other dircetions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j AMsouthEast
	
AMcheckXEast: 	#looks at the row/column/diagnoal for a for a player piece, will repeat until reaches edge
	addi $t8, $t8, 1	#This tells us that there is a valid move 
	j userInput1 
	
	
AMxSouthEast: 	#looks for another player 1 piece southeast of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, 9 	#this gives the index southeast to the checked coordinate 
	
	#branching
	bgt $t4, 63, AMjOutSouthEast	#if index is bigger than 63, it has gone out of bounds 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '0', AMxSouthEast 	#there still might be a possible sandwich, check next possiblity 
	bne $t5, '-', AMjOutSouthEast	#check other directions because reached negative space instead of X
	j userInput1	#jump back to user input 
	
AMjOutSouthEast: 	#Takes us back to check the other dircetions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j AMsouth
	
AMcheckXSouthEast: 	#looks at the row/column/diagnoal for a for a player piece, will repeat until reaches edge 
	addi $t8, $t8, 1	#This tells us that there is a valid move 
	j userInput1 
	
		
AMxSouth: 	#looks for another player 1 piece south of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, 8	#this gives the index south to the checked coordinate 
	
	#branching
	bgt $t4, 63, AMjOutSouth	#if index is bigger than 63, it has gone out of bounds 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '0', AMxSouth 	#there still might be a possible sandwich, check next possiblity 
	bne $t5, '-', AMjOutSouth	#check other directions because reached negative space instead of X
	j userInput1	#jump back to user input 
	
AMjOutSouth: 	#Takes us back to check the other dircetions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j AMsouthWest
	
AMcheckXSouth: 	#looks at the row/column/diagnoal for a for a player piece, will repeat until reaches edge
	addi $t8, $t8, 1	#This tells us that there is a valid move 
	j userInput1 

	
AMxSouthWest: 	#looks for another player 1 piece southWest of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, 7 	#this gives the index southWest to the checked coordinate 
	
	#branching
	bgt $t4, 63, AMjOutSouthWest	#if index is bigger than 63, it has gone out of bounds 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '0', AMxSouthWest 	#there still might be a possible sandwich, check next possiblity 
	bne $t5, '-', AMjOutSouthWest	#check other directions because reached negative space instead of X
	j userInput1	#jump back to user input 
	
AMjOutSouthWest: 	#Takes us back to check the other dircetions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j AMwest
	
AMcheckXSouthWest: 	#looks at the row/column/diagnoal for a for a player piece, will repeat until reaches edge
	addi $t8, $t8, 1	#This tells us that there is a valid move 
	j userInput1 	
	
	
AMxWest: 	#looks for another player 1 piece west of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, -1	#this gives the index west to the checked coordinate 
	
	#branching
	blt $t4, 0, AMjOutWest	#if index is neg, it has gone out of bounds, check other 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '0', AMxWest 	#there still might be a possible sandwich, check next possiblity 
	bne $t5, '-', AMjOutWest	#check other directions because reached negative space instead of X
	j userInput1	#jump back to user input 
	
AMjOutWest: 	#Takes us back to check the other dircetions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j AMnorthWest
	
AMcheckXWest: 	#looks at the row/column/diagnoal for a for a player piece, will repeat until reaches edge
	addi $t8, $t8, 1	#This tells us that there is a valid move 
	j userInput1 


AMxNorthWest: 	#looks for another player 1 piece northwest of the player 2 piece 
	#calculate position in array for input validation
	addi $t9, $t9, 1 	#this is incrementing the counter  
	addi $t4, $t4, -9	#this gives the index northwest to the checked coordinate 
	
	#branching
	blt $t4, 0, AMjOutNorthWest	#if index is neg, it has gone out of bounds, check other 
	lb $t5, mdArray($t4) 	#loads the character of that coordinate into t5
	beq $t5, '0', AMxNorthWest 	#there still might be a possible sandwich, check next possiblity 
	bne $t5, '-', AMjOutNorthWest	#check other directions because reached negative space instead of X
	j userInput1	#jump back to user input 
	
AMjOutNorthWest: 	#Takes us back to check the other dircetions 
	addi $t9, $zero, 0 	#resetting the counter to zero. 
	j noMoves
	
AMcheckXNorthWest: 	#looks at the row/column/diagnoal for a for a player piece, will repeat until reaches edge
	addi $t8, $t8, 1	#This tells us that there is a valid move 
	j userInput1 

noMoves: 		#There are no available moves
	addi $t0, $t0, 1 	#increments the index by one 
	ble $t0, 63, availableMove	#t0 is the index and if it reaches 63 it has checked the entire board
	#outputting error message prompt 
	li   $v0, 4
   	la   $a0, noMovesMessage
    	syscall
    	#newline
    	addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        j exit

player2: 
# buggy if these values are not reset
addi $a0, $zero, 0
addi $a1, $zero, 0
addi $s2, $zero, 0
addi $t1, $zero, 0
addi $t2, $zero, 0
addi $t3, $zero, 0
addi $t4, $zero, 0
addi $t5, $zero, 1

#player2 ai alorithm
#======================================================================================================


#use input here to debug this section
lb $a0, xPiece 
lb $a1, oPiece 
lb $v1, dash

scanBoardLoop:
	
	
	bgt $t5, 64, exitBoardScanned #to exit $s2 = 7
	lb $v0, mdArray($t5)
	bne $v0, $v1, notOnopenSpace 

	addi $s2, $zero, 0
	
	#main loop is the bulk of the switch case algorithm
mainCLoop:
	bgt $s2, 7, exitConv #to exit $s2 = 7
	
	
	bne $s2, 0, northC 
		addi $t3, $zero, -8 #changed for debugging
	northC:
	
	bne $s2, 1, northEastC 
		addi $t3, $zero, -7 
	northEastC:
	
	bne $s2, 2, eastC 
		addi $t3, $zero, 1
	eastC:
	
	bne $s2, 3, southEastC 
		addi $t3, $zero, 9
	southEastC:
	
	bne $s2, 4, southC 
		addi $t3, $zero, 8
	southC:
	
	bne $s2, 5, southWestC 
		addi $t3, $zero, 7
	southWestC:
	
	bne $s2, 6, westC 
		addi $t3, $zero, -1
	westC:
	
	bne $s2, 7, northWestC 
		addi $t3, $zero, -9
	northWestC:
	
	#ajusting values of index
	add $t4, $t5, $zero
	add $t4, $t4, $t3
	lb $v0, mdArray($t4)
	bne $v0, $a0, notEqual
	add $t4, $t5, $zero
	addi $v0, $zero, 0
	
	secondaryLoopC:
		
		add $t4, $t4, $t3
		
		lb $v0, mdArray($t4)
		
		bne $v0, $a0, exitSC #if not next to an x
		
		#loop while xs until hits either - or o if o then plot if - then skip
		
		#sb $a1, mdArray($t3)
		
	j secondaryLoopC
	exitSC:
	
	add $t4, $t5, $zero
	bne $v0, $a1, subExit
	
	sb $a1, mdArray($t5)
	addi $t5, $t5, 64
	
	#this loop goes back and converts tiles
	plotterLoop:
	
   	 	
		add $t4, $t4, $t3
		
		lb $v0, mdArray($t4)
		
		bne $v0, $a0, exitSC2 #if not next to an x
		
		sb $a1, mdArray($t4)	
		
		#loop while xs until hits either - or o if o then plot if - then skip
		
			
	j plotterLoop
	
	exitSC2:
	
	subExit:
	
	notEqual:
	addi $s2, $s2, 1
	
j mainCLoop
exitConv:

notOnopenSpace:

addi $t5, $t5, 1
j scanBoardLoop
exitBoardScanned:
#WestWorld?
#======================================================================================================



#End Game
#======================================================================================================
#endGameLoop:

#check each position in the array interavly
#if it is either an x or o luup the 8 directions to check if move is possible
#use boolean logic to flag when x is valid move and o is valid move
#jump statements to skip turn if no x or no o
#



# addi $s1, $s1, 1 

#j endGameLoop
#======================================================================================================




j while
exit:	

#Winner algorithm
#======================================================================================================
addi $s5, $zero, 0
addi $s6, $zero, 0
addi $s7, $zero, 0
winnerLoop:
	bne $s5, 64, exitWin #if not next to an x
	lb $v0, mdArray($s5)
	
	
	bne $v0, 'X', p1point
		addi $s6, $zero, 1
	bne $v0, '0', p2point
		addi $s7, $zero, 1
	p1point:
	p2point:
	
	addi $s5, $s5, 1
j winnerLoop
#======================================================================================================
exitWin:

blt  $s6, $s7, p2Wins #win conditions
   	 li   $v0, 4
   	 la   $a0, p1WinPrompt
    	 syscall
	 j p1Wins
	 
p2Wins:
	li   $v0, 4
   	la   $a0, p2WinPrompt
    	syscall
	p1Wins:
