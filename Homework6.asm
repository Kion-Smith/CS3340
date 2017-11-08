.data
	promptUser: .asciiz "Enter a number to get 1-bits:: "
	promptBits: .asciiz "Number of 1-bits are:: "
.text
	main:
		#Print prompt
		li $v0,4
		la $a0,promptUser
		syscall
		
		#get user information
		li $v0,5
		syscall
		
		#put userinput in
		move $a0,$v0
		
		#set the number conter
		li $t0,1 
		li $t1,1 
		
		#go to bit counter
		jal bitcount
		
		#move amount of bits
		move $t0,$v0
		
		#Print end prompt
		li $v0,4
		la $a0,promptBits
		syscall
		
		#Print number of bits
		li $v0,1
		move $a0,$t0
		syscall
		
		#end program
		jal exit
	
	bitcount:
		#if counter is greater then 32, then end
		bgt $t0,32,endBitcount
		and $t3,$a0,$t1
		#if counter is equal to zero then loop
		beq $t3,0,loop
		add $t2,$t2,1
	
	loop:
		#shift right and add to counter
		srl $a0,$a0,1
		add $t0,$t0,1
		j bitcount
	
	endBitcount:
		#Move bit count results
		move $v0,$t2
		jr $ra
	exit:
		#End program
		li $v0,10
		syscall
	