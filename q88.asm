.globl main
.text
main:
wait:  beq $t9, $zero, wait	# Wait until $t9 is not zero (1)
#----------------------------------------------------------------
#clear values
addi $v0, $zero, 0		#Clear A
addi $v1, $zero, 0		#Clear B
#----------------------------------------------------------------
# Get operands A and B from $a0 and $a1
ori $t0, $a0, 0 		#copy A to t0
ori $t1, $a1, 0			#copy B to t1
#----------------------------------------------------------------
# Calculate A - B and put the result in the higher 16-bit of $v0
subtract:			
sub $v0, $t0, $t1		#A-B
sll $v0, $v0, 16 		#shift sub into upper-16
#----------------------------------------------------------------
#Refresh A and B
ori $t0, $a0, 0 		#refresh A
ori $t1, $a1, 0			#refresh B
#----------------------------------------------------------------
# Calculate A + B and put the result in the lower 16-bit of $v0
add:
add $t2, $t0, $t1 		#A+B
bgtz $t2, addEnd		#if sum is negative, mask upper bits
addi $t3, $zero, 65535		#create upper bit mask
and $t2, $t2, $t3		#apply upper bit mask
addEnd:
or $v0, $v0,$t2			#copy sub to lower 16 bits
#----------------------------------------------------------------
#Refresh A and B
ori $t0, $a0, 0 		#refresh A
ori $t1, $a1, 0			#refresh B
#----------------------------------------------------------------
# Calculate A * B and put the result in the lower 16-bit of $v1
multiply:
bltz $t0, multA			#if A is neg, goto multA
bltz $t1, multB			#if B is neg, goto multB
addi $t2, $zero, 0		# set t2 to zero
multLoop:
beq $t2, $t1, multEnd	#if counter== B, return
add $v1, $v1, $t0		#add A to sum
addi $t2, $t2, 1		#increment counter
j multLoop

multA:
bltz $t1, multAll		#if B is also neg, goto multALL
sub $t0, $zero, $t0		#flip A to pos
addi $t2, $zero, 0		# set t2 to zero
multLoopA:
beq $t2, $t1, multA2		#if counter== B, return
add $v1, $v1, $t0		#add A to sum
addi $t2, $t2, 1		#increment counter
j multLoopA
multA2:
sub $v1, $zero, $v1
j multEnd

multB:
sub $t1, $zero, $t1		#flip B to pos
addi $t2, $zero, 0		# set t2 to zero
multLoopB:
beq $t2, $t1, multB2		#if counter== B, return
add $v1, $v1, $t0		#add A to sum
addi $t2, $t2, 1		#increment counter
j multLoopB
multB2:
sub $v1, $zero, $v1
j multEnd

multAll:
sub $t0, $zero, $t0		#flip A to pos
sub $t1, $zero, $t1		#flip B to pos
addi $t2, $zero, 0		# set t2 to zero
multLoopAll:
beq $t2, $t1, multEnd 		#if counter== B, return
add $v1, $v1, $t0		#add A to sum
addi $t2, $t2, 1		#increment counter
j multLoopAll
multEnd:
srl $v1, $v1, 8
addi $t2,$zero, 65535		#create upper bit mask
and $v1, $v1, $t2

#----------------------------------------------------------------
#Refresh A and B
ori $t0, $a0, 0 		#refresh A
ori $t1, $a1, 0			#refresh B
#----------------------------------------------------------------
# Calculate A / B and put the result in the higher 16-bit of $v1 
division:
sll $t0, $t0, 8			#shift A left 8, into Q8.16
bltz $t0, divA			#if A is neg, goto divA (will become remainder)
bltz $t1, divB			#if B is neg, goto divB
addi $t2, $zero, 0		#set t2 to zero (will become quotient)
divLoop:
sub $t0, $t0, $t1		#A=A-B
bltz $t0, divLoopEnd		#if A is neg, break
addi $t2, $t2, 1		#increment counter
j divLoop
divLoopEnd:
sll $t2, $t2, 16
or $v1, $v1,$t2
j sqrt

divA:
bltz $t1, divAll		#if B is neg, goto divB
sub $t0, $zero, $t0		#flip A to pos
addi $t2, $zero, 0		# set t2 to zero
divALoop:
sub $t0, $t0, $t1		#A=A-B
bltz $t0, divALoopEnd		#if A is neg, break
addi $t2, $t2, 1		#increment counter
j divALoop
divALoopEnd:
sll $t2, $t2, 16
sub $t2, $zero, $t2
or $v1, $v1,$t2
j sqrt

divB:
sub $t1, $zero, $t1		#flip B to pos
addi $t2, $zero, 0		# set t2 to zero
divBLoop:
sub $t0, $t0, $t1		#A=A-B
bltz $t0, divBLoopEnd		#if A is neg, break
addi $t2, $t2, 1		#increment counter
j divBLoop
divBLoopEnd:
sll $t2, $t2, 16
sub $t2, $zero, $t2
or $v1, $v1,$t2
j sqrt

divAll:
sub $t0, $zero, $t0		#flip A to pos
sub $t1, $zero, $t1		#flip B to pos
addi $t2, $zero, 0		# set t2 to zero
divAllLoop:
sub $t0, $t0, $t1		#A=A-B
bltz $t0, divAllLoopEnd		#if A is neg, break
addi $t2, $t2, 1		#increment counter
j divAllLoop
divAllLoopEnd:
sll $t2, $t2, 16
or $v1, $v1,$t2
j sqrt
#------------------------------------------------------------------
#SQUARE ROOT
#------------------------------------------------------------------
sqrt:
ori $t0, $a0, 0 		#set t0 to A
beqz $t0, sqrtEnd
bgtz $t0, sqrt2			#if A is positive, skip absolution
sub $t0, $zero, $t0		#flip A
addi $t0, $t0, 1

sqrt2:
addi $t1, $zero, 0		#set COUNTER(t1) to 0
addi $t2, $zero, 0		#set CURRENT_RESULT(t2) to 0
addi $t3, $zero, 0		#set CURRENT_REMAINDER(t3) to 0
addi $t4, $zero, 0		#set TEMP(t4) to 0
addi $t5, $zero, 49152 		#Set MASK(t5) to 0x000c000 (1100000000000000)
addi $t6, $zero, 0		#set INDICATOR to 0
addi $t7, $zero, 0		#temp2

sqrtLoop:
s1: 				#REMAINDER = (REMAINDER << 2) + active bits
sll $t3, $t3, 2			#multiply REMAINDER by 4
and $t7, $t0, $t5		#set TEMP2 to copy 2 active bits of A at mask
srl $t7, $t7, 14		#move active bits to LSB placement for adding
add $t3, $t3, $t7		#set REMAINDER to REMAINDER<<2 + active bits

s2:
sll $t4, $t2, 2			#set TEMP to RESULT*4

s3:
bge  $t4, $t3, s5		#if TEMP >= REMAINDER: skip addition and subtraction
addi $t4, $t4, 1		#TEMP = (TEMP +1)
ori $t6, $zero, 1		#set INDICATOR to 1

s4:
sub $t3, $t3, $t4		#REMAINDER = REMAINDER - TEMP
j s5

s5:
sll $t2, $t2, 1			#RESULT = RESULT*2
beqz $t6, s5c			#if INDICATOR=0, skip adding
addi $t2, $t2, 1		#RESULT = RESULT + 1
addi $t6, $zero, 0		#reset INDICATOR

s5c:
addi $t1, $t1, 1		#add 1 to COUNTER
beq $t1, 12, sqrtEnd		#if COUNTER = 11, exit
sll $t0, $t0, 2			#shift A left to mask new bits
j sqrtLoop

sqrtEnd:

ori $a2, $t2, 0			#copy RESULT to $a2
#---------------------------------------------------------------------------
add $t9, $zero, $zero		#Set $t9 back to 0
j   wait			#Go back to wait
