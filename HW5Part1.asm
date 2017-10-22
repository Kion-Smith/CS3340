.data
	#PROMPTS
	Options:.asciiz "\n1) Set rate \n2)US $ to Yen Conversion \n3) Yen to US $ Conversion \n4)Exit Program \n" 
	
	#Propmt for rate of exchnage
	rateExchangePrompt1: .asciiz "Current rate is "
	rateExchangePrompt2: .asciiz ", enter a new rate::\n"
	
	#propmpts for us to yen
	USToYenPrompt1: .asciiz "Enter the US amount::\n"
	USToYenPrompt2: .asciiz "You entered the dollar amount as "
	USToYenPrompt3: .asciiz " the amount in is Yen "
	
	#prompts for yen to us
	YenToUSPrompt1: .asciiz "Enter the Yen amount::\n"
	YenToUSPrompt2: .asciiz "You entered the Yen amount as:: "
	YenToUSPrompt3: .asciiz "\nThe dollar amount is:: "
	YenToUSPrompt4: .asciiz "\nThe left over yen amount is:: "
	
	#the default rate
	rate:.word 115
.text
	main:
		#show the options menu	
		la $a0,Options
		li $v0,4
		syscall
		
		#get user input
		li $v0,5
		syscall
		
		#if any of the options then go to do that option
		beq $v0,1,setRate
		beq $v0,2,UStoYen
		beq $v0,3,YentoUS
		beq $v0,4,exit
		
		#if out of bounds, go back to main
		ble $v0,$zero,main
		bge $v0,$5,main
			
	setRate:
		#tell user old rate
		la $a0,rateExchangePrompt1
		li $v0,4
		syscall
		
		#Load current rate
		lw $a0,rate
		li $v0,1
		syscall
		
		#ask for new rate
		la $a0,rateExchangePrompt2
		li $v0,4
		syscall
		
		#get user input
		li $v0, 5
		syscall
		
		#store user input number to word rate
		move $t1,$v0
		sw $t1,rate
		
		#jump and link back to main
		jal main
	
	UStoYen:
		#Ask user for us amount
		la $a0,USToYenPrompt1
		li $v0,4
		syscall
		
		#get input
		li $v0,5
		syscall
		
		#move input to register $t0
		move $t0,$v0
		
		#propmpt user with what they entered
		la $a0,USToYenPrompt2
		li $v0,4
		syscall
		
		#get user input
		la $a0,($t0)
		li $v0,1
		syscall
		
		#tell user Yen amount
		la $a0,USToYenPrompt3
		li $v0,4
		syscall
		
		#load rate and store in $t1, then multiply with user input
		lw $t1,rate
		mult $t0,$t1 
		
		#store yen in $t0
		mflo $t0
		
		#print yen amount
		la $a0,($t0)
		li $v0,1
		syscall
		
		#go back to main
		jal main
	
	YentoUS:
		#ask for yen amount
		la $a0,YenToUSPrompt1
		li $v0,4
		syscall
		
		#get input
		li $v0,5
		syscall
		
		#move yen amount to $t0
		move $t0,$v0
		
		#Tell user yen amount
		la $a0,YenToUSPrompt2
		li $v0,4
		syscall
		
		#get input in yen
		la $a0,($t0)
		li $v0,1
		syscall
		
		#load rate
		lw $t1,rate
		
		#divide userinput / rate
		div $t0,$t1
		
		#Display the dollar amount
		la $a0,YenToUSPrompt3
		li $v0,4
		syscall
		
		#geting high for dollar amount
		mflo $t0
		
		#display amount
		la $a0,($t0)
		li $v0,1
		syscall
		
		#display left over yen
		la $a0,YenToUSPrompt4
		li $v0,4
		syscall
		
		#get left over yen
		mfhi $t0
		
		#display yen
		la $a0,($t0)
		li $v0,1
		syscall
		
		#go back to main
		jal main
		
	exit:
		#Teriminate program
		li $v0,10
 		syscall
