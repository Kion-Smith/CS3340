#Kion Smith
#kls160403
#CS3340-001
.data
	#prompts
	prompt:.asciiz"Enter a number from the range 0 - 50 \n"
	aboveMax:.asciiz "The number you enterd was above 50"
	sumMessage:.asciiz "The sum of integers from 0 to N is:"
	#array adress and nums
	list: .space 200 # Reserve space for 50 integers
	listz: .word 50 # using an array of size 50
	
.text
	main:
		#Prompt the use the question
		la $a0,prompt
		li $v0,4
		syscall
		# get user input for
 		li $v0,5
 		syscall
 		#place userinput into register t0
		move $t0,$v0
 		slt $t1,$zero,$t0
 		beq $t1,$zero,isZero# move down to is Zero stament
 		#if userInput>50
 		slti $t1,$t0,51
 		beq $t1,$zero,isAboveZero
 		
 		#load in lists
 		lw $s0,listz
 		la $s1,list
 		
 		loop:
 			#while userInput is larger than  than register
 			beq $t7,$t0,end
 			sb $s1,0($s1)
			#increment for address and array
 			addi $t5,$t5,4
 			addi $t7,$t7,1
 			#add 1 to sum
 			add $s2,$s2,$t7 
 			j loop#keep looping
 
 		end:
 			#print the message before the sum
			li $v0,4
			la $a0,sumMessage
			syscall

			#print the sum
			li $v0,1
			add $a0,$s2,$zero
			syscall

 		#If the number is zero run this
 		isZero:
 			#stops program
 			li $v0,10
 			syscall
 		#if number is above zero run this
 		isAboveZero:
 			li $v0,4
 			la $a0,aboveMax
 			syscall 
 			#stops program
 			li $v0,10
 			syscall
