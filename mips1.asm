#data segme
.data
hello: .asciiz  "Hello world"
#Text stegme
	.text
		
main:
	la $a0, hello
	li $v0,4 # printing string
	syscall 