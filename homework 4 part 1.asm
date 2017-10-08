#Part 1 of HW 4

#Kion Smith
#Net ID kls160430
#CS 3340 - 001
.data
	#Prompts
	prompt: .asciiz "Enter a zip code\n"
	normalPrompt: .asciiz "This is the total sum done normally: "
	recPrompt: .asciiz "\nThis is the total sum done recusively: "
	#variables
	.align 2
	A: .word
	B: .word
	
.text
	main:
		#get prompt
		la $a0,prompt
		li $v0,4
		syscall
		#get userInput
		li $v0,5
		syscall
		
		beq $v0,$zero,Exit
		
		move $t2,$v0
		
		#jump down to Loop
		jal Loop
		sw $v0,A#setting A to $v0
		
		#setting the the variables anr return item
		add $a0,$v0,$zero
		jal Recursion
		sw $v0,B #setting b to be $v0
		
		#printing the normal answer
    		la $a0, normalPrompt
		li $v0, 4
		syscall
		
		lw $a0,A 
 		li $v0,1
 		syscall
 		
 		#printing the recusive answer
 		la $a0, recPrompt
		li $v0, 4
		syscall
			
		lw $a0,B 
 		li $v0,1
 		syscall
 		
 		#end program
 		li $v0,10
 		syscall
		
	Loop:
		div $t2, $t2, 10 # input divided by 10
    		mfhi, $t3 #get remainder and store in 3
    		add $t0, $t0, $t3 # add t3 to t0
		bne $t2,$zero,Loop #loop until t2 = 0
		
 		jr $ra# return
 		
 	Recursion:
 		sub $sp,$sp,12#create space for stack
		sw $ra,0($sp)#store address
		sw $a0,4($sp)#Input
		
		beq $a0,$zero,exitRecursion# loop until is zero then exit to exitRecursion
		mfhi $t0  # the remiander
		sw $t0,8($sp) #save t0 to the stack
		div $a0,$a0,10 #divide input by 10
		jal Recursion# recusive call
		
		lw $t0,8($sp)#load from stack
		add $v0,$v0,$t0#add to to others
		lw $ra,0($sp)#get address
		addi $sp,$sp,12
		jr $ra# return
	
	exitRecursion:
		li $v0,0 #load in input
		lw $ra,0($sp)#load input address
		addi $sp,$sp,12#get rid of extra stack space
		jr $ra # return 
 	Exit:
 		#end program
 		li $v0,10
 		syscall