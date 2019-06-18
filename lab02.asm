.data
	enterMsg: .asciiz "Enter a number between 0 & 9: "
	lowMsg: .asciiz "Your guess was too low."
	highMsg: .asciiz "Your guess was too high."
	loseMsg: .asciiz "You lose. the number was "
	winMsg: .asciiz "Your guess was right!"
.text
# t0: generated number
# t1: read int
# t2: try counter
main:
	addi $t2, $zero, 0
	jal seed
	jal createRand
	mainLoop:
		jal newLine
		addi $t2, $t2, 1
		beq $t2, 4, printLose
		jal printMain
		jal readInt
		jal newLine
		beq $t0, $t1, printWin
		bge $t1, $t0, printHigh
		ble $t1, $t0, printLow
		
		
	

newLine:
	addi $a0, $0, 0xA #try 0xD for CR.
        addi $v0, $0, 0xB 
        syscall
        jr $ra
	
printMain: #print enter message
	addi $v0, $zero, 4
	la $a0, enterMsg
	syscall
	jr $ra
printLow: #print enter message
	addi $v0, $zero, 4
	la $a0, lowMsg
	syscall
	j mainLoop
printHigh: #print enter message
	addi $v0, $zero, 4
	la $a0, highMsg
	syscall
	j mainLoop
printLose: #print enter message
	addi $v0, $zero, 4
	la $a0, loseMsg
	syscall
	jal printRand
	j quit
printWin: #print enter message
	addi $v0, $zero, 4
	la $a0, winMsg
	syscall
	j quit
readInt: # get number input and store in store in $t0
	addi $v0, $zero, 5
	syscall
	or $t1, $v0, $zero
	jr $ra
seed: #generate seed and store in 
	addi $v0, $zero, 30
	syscall
	add $a1, $zero, $a0
	add $a0, $zero, $zero
	addi $v0, $zero, 40
	syscall
	jr $ra
createRand: #generate rand. num, store in $t0
	addi $v0, $zero, 42
	add $a0, $zero, $zero
	addi $a1, $zero, 10
	syscall
	add $t0, $zero,$a0
	jr $ra
quit:
	addi $v0,$zero,10
	syscall
printRand:
	addi $v0, $zero, 1
	add $a0, $zero, $t0
	syscall
	jr $ra
	

	
	
	
	