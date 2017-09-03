 .data
 	# variables
 	A: .word
 	B: .word
 	S: .word
 	#prompts
 	prompt1: .asciiz "Enter the first number "
 	prompt2: .asciiz "Enter the second number "
 	answer: .asciiz "The total (A+B) is "
 .text
 
 	main:
 		#Prompt 1
 		la $a0,prompt1 #Print prompt1
 		li $v0,4
 		syscall
 		la $t0,A
 		li $v0,5
 		syscall
 		move $t0,$v0
 		sw $t0,A# Save the number
 		
 		#Prompt 2
 		la $a0,prompt2 #Print prompt2
 		li $v0,4
		syscall
 		la $t1,B
 		li $v0,5
 		syscall
 		move $t1,$v0
 		sw $t1,B# Save the number
 		
 		#Answer
 		la $t2,S
 		add $t2,$t0,$t1 #add the numbers and but it in the register assicuated with S
 		sw $t2,S# Save the number
 		la $a0,answer #Print answer
 		li $v0,4
 		syscall
 		lw $a0,S
 		li $v0,1
 		syscall
 		
 		
 		
 		
 		