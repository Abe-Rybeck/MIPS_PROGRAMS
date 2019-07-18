.globl main
.data
	nl: .asciiz  "\n"
	#0xFFFF8000
.text
main:
jal printBoard_
addi $a0, $zero, 0
addi $a1, $zero, 0
addi $a2, $zero, 0
addi $s3, $zero, -1
jal _solveSudoku
j end

#-------- Main solver ------------------------------------------------------------------------------------
_solveSudoku:			#vars: a0==row, a1==column
addi $sp, $sp, -20		#STORE
sw $ra, 0($sp)			#--- cur ret addr
sw $s0, 4($sp)			# |  cur row
sw $s1, 8($sp)			# |  cur col
sw $s2, 12($sp)			# |  cur guess
sw $s3, 16($sp)			#--- cur count

addi $s0, $a0, 0		#s0 = row
addi $s1, $a1, 0		#s1 = column


#if((r == 8 AND c == 8) OR (c == 9)
bne $s1, 9, cont		#if(c != 9), skip row incrementation and doneCheck
beq $s0, 8, reTrue		#if(r = 8), return true
addi $s0, $s0, 1		#row += 1
addi $s1, $zero, 0		#column = 0

#occupation check
cont:
addi $s3, $s3, 1		#s3 += 1 
lb $s2, 0xFFFF8000($s3)		#ld square in next addr
beqz $s2, check			#if square == 0, go to next steps
addi $a0, $s0, 0		#row = cur row
addi $a1 , $s1, 1		#C = C+1
jal _solveSudoku
beqz $v0, reFalse
j reTrue
#-----------3---------------
check:
addi $s2, $zero, 1

checkLoop:
bgt $s2, 9, checkEnd

#checkRow
addi $a0, $s0, 0
addi $a1, $s2, 0
jal _checkRow
beqz $v0, checkInc

#checkColumn
addi $a0, $s1, 0
addi $a1, $s2, 0
jal _checkColumn
beqz $v0, checkInc

#checkGrid
addi $a0, $s0, 0
addi $a1, $s1, 0
addi $a2, $s2, 0
jal _checkSubgrid
beqz $v0, checkInc

#if all pass
sb $s2, 0xFFFF8000($s3)		#store num in cell
addi $a0, $s0, 0		#set row var
addi $a1, $s1, 1		#set col+1 var
jal _solveSudoku		#recurse
bnez $v0, reTrue		#if next returned true, return true

checkInc:
addi $s2, $s2, 1
j checkLoop

checkEnd:
sb $zero, 0xFFFF8000($s3)	#store zero
j reFalse		#else return false



reTrue:
addi $v0, $zero, 1		# set t9 to true
j return

reFalse:
addi $v0, $zero, 0		# set t9 to false

return:
lw $ra, 0($sp)			#LOAD
lw $s0, 4($sp)			#---
lw $s1, 8($sp)			# |
lw $s2, 12($sp)			# |
lw $s3, 16($sp)			# |
addi $sp, $sp, 20		#---
jr $ra








#-------------- Check Row -------------------------
_checkRow:			#vars: a0==row, a1 == num || ret: V0
addi $t0, $a0, 0		#t0 = row
addi $t1, $a1, 0		#t1 = num
addi $t2, $zero, 9		# |
mult $t0, $t2			#\|/
mflo $t2			#t2 = 9*row (start address offset)
addi $t3, $zero, 9		#t3 = counter = 9	
la $t4,0xFFFF8000($t2)

rowLoop:
lb $t5, ($t4)			#$t5 = cell @ t4
beq $t5, $t1, rowFail		#if cell=num, fail
addi $t3, $t3, -1		#de-increment counter
beqz $t3, rowPass		#if no matches, pass
addi $t4, $t4, 1		#increment addr
j rowLoop

rowFail:
addi $v0, $zero, 0
jr $ra

rowPass:
addi $v0, $zero, 1
jr $ra

#--------------Check Column ----------------------------
_checkColumn:			#vars: a0== col, a1==num
addi $t0, $a0, 0		#t0 = col
addi $t1, $a1, 0		#t1 = num
addi $t2, $zero, 9		#t2 = counter = 9	
la $t3,0xFFFF8000($t0)		#t3 = baseAddr + col

colLoop:
lb $t4, ($t3)			#$t4 = cell @ t3
beq $t4, $t1, colFail		#if cell=num, fail
addi $t2, $t2, -1		#de-increment counter
beqz $t2, colPass		#if no matches, pass
addi $t3, $t3, 9		#addr += 9
j colLoop

colFail:
addi $v0, $zero, 0
jr $ra

colPass:
addi $v0, $zero, 1
jr $ra
#---------------Check Subgrid ----------------------------
_checkSubgrid:			#vars: a0==row, a1==columm, a2== num
addi $t0, $a0, 0		#t0 = row
addi $t1, $a1, 0		#t1 = col
addi $t2, $a2, 0		#t2 = num

addi $t4, $zero, 3		#t4 = 3: for division
div $t0, $t4			#row/3
mfhi $t4			#$t4 = row%3
sub $t4, $t0, $t4		#t4 = row - (row%3)
addi $t5, $zero, 3		#t5 = 3: for division
div $t1, $t5			#col/3
mfhi $t5			#$t5 = col%3
sub $t5, $t1, $t5		#t5 = col - (col%3)
addi $t6, $t4, -1		#t6 = t4-1
addi $t9, $zero, 0

subGridLoop:
addi $t6, $t6, 1		#t6 += 1
addi $t9, $t9, 1
bgt $t9, 2, gridPass		#pass if $t6 = 3
addi $t3, $t5, 0		#reset $t3
addi $t4, $zero, 0


subGridLoopInner:	
beq $t4, 3, subGridLoop		#goto outter loop if t3 = 3
addi $t7, $zero, 9		#t7 = 9
mult $t7, $t6			#t7 *= row
mflo $t7			#t7 *= row
add $t7, $t7, $t3		#t7 += count
la $t8,0xFFFF8000($t7)		#t8 = baseAddr + cellcount
lb $t8, ($t8)			#t8 = cell contents
beq $t8, $t2, gridFail		#if t8 = num, fail
addi $t3, $t3, 1		#increment t3
addi $t4, $t4, 1		#increment t4
j subGridLoopInner

gridFail:
addi $v0, $zero, 0
jr $ra

gridPass:
addi $v0, $zero, 1
jr $ra

#-------- Print Board -----------
printBoard_:
la $t0, 0xFFFF8000		#ld address of first square in puzzle
addi $t1, $zero, 0		#set  total counter to zero
addi $t2, $zero, 0		#set column  counter to zero
j printLoopLower

printLoopUpper:
addi $t2, $zero, 0		#set column  counter to zero
li $v0, 4      			# you can call it your way as well with addi 
la $a0, nl       		# load address of the string
syscall
syscall				#print newline
j printLoopCheck

printLoopLower:
lb $a0, 0($t0)			#load next square
addi $v0, $0, 1
syscall
addi $t2, $t2, 1		#increment column counter
addi $t1, $t1, 1		# increment total count
addi $t0, $t0, 1		# inrement address
beq $t1, 81, printEnd		#if total count == 80, end
beq $t2, 9, printLoopUpper	# if column count == 8, new row
printLoopCheck:
j printLoopLower		#inner loop
printEnd:
jr $ra

end:
