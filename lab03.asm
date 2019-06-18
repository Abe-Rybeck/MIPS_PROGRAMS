.globl main
.data
	input1: .asciiz "Please enter a positive integer: "
	input2: .asciiz "Please enter a second positive integer: "
	error: .asciiz "negative integers are not allowed.\n"
	multChar: .asciiz " * "
	equalsChar: .asciiz " = "
	caratChar: .asciiz "^"
	newLine: .asciiz "\n"

	
.text
main:
#t0: int 1
#t1: int 2
#t2: AND result
#t3: mult loop counter
#t4: bit matcher
#t5: exp loop counter
#s1: mult FINAL result
#s2: exp FINAL result
first:
	jal firstInput #get int1
	ble $t0, $zero, printError1 #if negative, erro
second:
	jal secondInput #get int2
	ble $t1, $zero, printError2 #if negative, error
run:
	addi $t4, $zero, 1 # set bit matcher
	ori $a0, $t0, 0 #set arg1 to int1
	ori $a1, $t1, 0 #set arg2 to int2
	jal multiply
	ori $s1, $v1, 0 # hold mult final answer in s1
	addi $v1, $zero, 0
	ori $a0, $t0, 0 #reset arg1 to int1
	ori $a1, $a0, 0 #set arg2 to int1
	ori $t6, $t1, 0 # set t6 to int2
	jal multiply
	addi $v1, $zero, 0
	ori $a0, $t0, 0 #reset arg1 to int1
	ori $a1, $a0, 0 #set arg2 to int1
	ori $t6, $t1, 0 # set t6 to int2
	jal exp
	


#------------- Multiply ---------------multiplies a0 and a1 into v1
multiply: 
	beq $t3, 31, multReturn
	and $t2, $a1, $t4
	sll $t4, $t4, 1
	beq $t2, 0, multiply2
	add $v1, $v1, $a0
multiply2:
	sll $a0, $a0, 1
	addi $t3, $t3, 1
	j multiply
multReturn:
	addi $t4, $zero, 1
	addi $t3, $zero, 0
	jr $ra
#------------- Exponent -------------- exponents a0 by t6, stores in s2
exp:
	jal multiply
	ori $s2,$v1,0 #set exp final to mult return
	ori $a0, $v1, 0 #set mult arg 1 to pevous mult return
	addi $v1, $zero, 0 #zero out previos return
	
	addi $t5, $t5, 1 #add 1 to exp counter
	beq $t5, $a1, print #print if done
	j exp
	
	
	
	
	
	

#--------- print-out ------------
print:
printMult:
	addi $v0, $zero, 1
	or $a0, $t0, $zero
	syscall
	addi $v0, $zero, 4
	la $a0, multChar
	syscall
	addi $v0, $zero, 1
	or $a0, $t1, $zero
	syscall
	addi $v0, $zero, 4
	la $a0, equalsChar
	syscall
	addi $v0, $zero, 1
	or $a0, $s1, $zero
	syscall
	addi $v0, $zero, 4
	la $a0, newLine
	syscall
printExp:
	addi $v0, $zero, 1
	or $a0, $t0, $zero
	syscall
	addi $v0, $zero, 4
	la $a0, caratChar
	syscall
	addi $v0, $zero, 1
	or $a0, $t1, $zero
	syscall
	addi $v0, $zero, 4
	la $a0, equalsChar
	syscall
	addi $v0, $zero, 1
	or $a0, $s2, $zero
	syscall
j quit
#----------- inputs -------------
firstInput: #t0 == int1
	addi $v0, $zero, 4
	la $a0, input1
	syscall
	addi $v0, $zero, 5
	syscall
	or $t0, $zero, $v0
	jr $ra

secondInput: #t1 == int2
	addi $v0, $zero, 4
	la $a0, input2
	syscall
	addi $v0, $zero, 5
	syscall
	or $t1, $zero, $v0
	jr $ra	
#---------- errors ------------
printError1:
	addi $v0, $zero, 4
	la $a0, error
	syscall
	j first
printError2:
	addi $v0, $zero, 4
	la $a0, error
	syscall
	j second
#-------- quit ---------------
quit:
	addi $v0, $zero, 10
	syscall

	
