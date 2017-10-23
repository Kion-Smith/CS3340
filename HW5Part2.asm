.data
	#prompts
	Prompt1:.asciiz "How many pizza(s) did you sell for the day?\n"	
	Prompt2:.asciiz "You sold "	
	Prompt3:.asciiz " pizza(s) which is  "
	Prompt4:.asciiz " square feet of pizza"
	size:.float 4
	pi:.float 3.14
	#empty float values to store infromation
	answer:.float
	final:.float
	input:.float 
.text
	main:
		#Prompts a user for pizza amount
		li $v0, 4
		la $a0,Prompt1
		syscall
		
		#load loat and set value to $f4, then get input
		lwc1 $f4, input
		li $v0,6
		syscall
		
		#Prompt 2 saying how many pizzas sold
		li $v0, 4
		la $a0,Prompt2
		syscall
		#set f4 to pizza amount temporarily
		li $v0,2
		add.s $f12,$f0,$f4
		syscall
		#permently move input to $f0
		mov.s $f4,$f0
		
		#load in the 
		l.s $f1,size
		l.s $f2,pi
		
		mul.s $f1,$f1,$f1# = r^2
		mul.s $f5,$f1,$f2# = pi * r^2
		#set the float to answer
		swc1 $f5, answer
		lwc1 $f12,answer
		li $v0,2
		
		mul.s $f3,$f5,$f0 # multiply the amount of pizza
		# prompt how much sq feet of pizza
		li $v0, 4
		la $a0,Prompt3
		syscall
		#load how much pizza is sold
		swc1 $f3, final
		lwc1 $f12,final
		li $v0,2
		syscall
		
		li $v0, 4
		la $a0,Prompt4
		syscall
		
		#end program
		li $v0,10
 		syscall
		
		
		
		
	
