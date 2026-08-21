# Author : WhisperingRock
#
# Purpose : Convert an unsigned hex to BCD, where each hex char
#			in the result is actually base 10 decimal.
# Input : 
#			- A single read from an unsigned 16-bit array
#
# Output :
#			- A single 32-bit write to a 32-bit array


.data
DIVSET:		.word 0, 0			# Quotient[0] and Remainder[1]

# ~~~~ Test Cases ~~~~
# ~~ TC1 : one decimal digit ~~
#TC:		.half 	0x7
#RES:	.word	0
# answer : 0x00007   *verified*

# ~~ TC2 : two decimal digit ~~
#TC:		.half 	0xA
#RES:	.word	0
# answer : 0x00010   *verified*

# ~~ TC3 : given ~~
#TC:		.half 	0x3A6C
#RES:	.word	0
# answer : 0x14956   *verified*

# ~~ TC4 : max input for 16 unsign bit~~
#TC:		.half 	0xFFFF
#RES:	.word	0
# answer : 0x65535  *verified*

# ~~ TC5 : zero ~~
#TC:		.half 	0x0
#RES:	.word	0
# answer : 0x0      *verified*

# ~~ TC6 : lucky ~~
TC:		.half 	0x309
RES:	.word	0
# answer : 0x777      *verified*

.global _start

.text
#.equ MMIO_SWITCHES, 	0x00007F00
#.equ MMIO_SEVSEG, 		0x00007F40
#.equ MMIO_LEDS,			0x00007F20
.equ DIVISOR, 10

_start:
	# ~~~~ init reg + TC injection ~~~~
	# ~~ preserved ~~
	la s0, TC					# s0 is the addr for read array
	la s1, RES					# s1 is the addr for write array
	# ~~ non-preserved ~~
	la a0, DIVSET				# a0 is an array for passing args
	addi a1, zero, DIVISOR		# a1 is the divisor arg (const)
	addi a2, zero, 0			# a2 is working version of BCD
	addi t0, zero, 0			# t0 = i = 0
								# t1 is working var
	
	# ~~~~ read and load hex from array ~~~~
	lhu t1, 0(s0)
	sw t1, 0(a0)			# Numerator is initial quotient
	sw zero, 4(a0)			# Remainder

	# ~~~~ while (numerator >= 0) s.t. hex can be further converted ~~~~
MainWhile:
	blez t1, End_MainWhile	

	# ~~~~ caller(_start) saves non-preserved ~~~~
	# ~~ 1. caller(_start) allocates space on stack ~~
	addi sp, sp, -20
	# ~~ 2. caller(_start) stores reg values on stack ~~
	sw t1, 16(sp)
	sw a0, 12(sp)
	sw a1, 8(sp)
	sw a2, 4(sp)
	sw t0, 0(sp)
	# ~~ 3. caller(_start) function execution ~~
								# a0 remains addr (const)
								# a1 remains const (10)
	jal DivBySub 
								# return a0 should remain as above
	# ~~ 4. caller(_start) restores preserved from stack ~~
	lw t1, 16(sp)
	lw a0, 12(sp)
	lw a1, 8(sp)
	lw a2, 4(sp)
	lw t0, 0(sp)
	# ~~ 5. caller(_start) deallocates space on stack ~~
	addi sp, sp, 20

	# ~~~~ prefix hex to BCD ~~~~
	slli t2, t0, 2				# t2 = 4i
	lw t3, 4(a0)				# t3 = RES[1] = Remainder
	sll t3, t3, t2				# remainder shifted to correct hex spot
	or a2, a2, t3				# prefix remainder to BCD
	addi t0, t0, 1				# i++
	lw t1, 0(a0)				# t1 = RES[0] = Quotinet
	
	j MainWhile
End_MainWhile:

	sw a2, 0(s1)				# write BCD to result array

	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 0			# EXIT_SUCCESS code
	ecall				# execute sys call


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Purpose : Perform division by subtraction, writing the quotient and 
#				remainder to a single array.
#			
# Input :
#			a0 : [signed 32-bit] Array of two elements
#					a[0] is Numerator
#			a1 : [signed 32-bit] Denominator
#
# Return:	
#			address to array stored in a0, with
#				arr[0] storing the quotient
#				arr[1] storing the remainder	

DivBySub:
	
	# ~~~~ calle(DivBySub) saves preserved ~~~~
	# ~~ 1. calle(DivBySub) allocates space on stack ~~
	addi sp, sp, -12

	# ~~ 2. calle(DivBySub) stores reg values on stack ~~
	sw s1, 8(sp)
	sw s0, 4(sp)
	sw ra, 0(sp)

	# ~~ 3. calle(DivBySub) function execution ~~

	# ~ Edge case : div by zero ~
	blez a1, RaiseError	

	# ~ init ~
	lw t0, 0(a0)				# R = N = RES[0]
	addi t1, a1, 0				# D = a1 = 10
	addi t2, zero, 0			# Q = 0

DivWhile:	# ~ while div produces integers s.t. (R >= D) ~
	# (R>= D) = (D > R)
	bgtu t1, t0, End_DivWhile
	sub t0, t0, t1				# R = R - D
	addi t2, t2, 1				# Q++

	j DivWhile
End_DivWhile:

	# ~ write to return array ~
	sw t2, 0(a0)				# Q saved in a0[0]
	sw t0, 4(a0)				# R saved in a0[1]
	
	# ~~ 4. calle(DivBySub) restores preserved from stack ~~
	lw s1, 8(sp)
	lw s0, 4(sp)
	lw ra, 0(sp)

	# ~~ 5. calle(DivBySub) deallocates space on stack ~~
	addi sp, sp, 12

	# ~~ calle return ~~
	jr ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

RaiseError:
	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 1			# EXIT_FAILURE code
	ecall				# execute sys call

