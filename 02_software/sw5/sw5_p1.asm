# Author : WhisperingRock
#
# Purpose : Division by repeat subtraction
# Input : 
#			- array of two unsigned 16-bit elems
#			- 7SEG & LEDS MMIO address to 32 bits
#
# Output :
#			Write to 7SEG and LEDS addr


.data
# ~~~~ Test Cases ~~~~

# ~~ TC1 : 0 / 1 ~~
#TC:		.half 0, 1
# answer : *verified*
#	Q = 0 
#	R = 0

# ~~ TC2 : 1 / 0 ~~
#TC:		.half 1, 0
# answer : *verified*
#	RaiseError 
#	

# ~~ TC3 : 1 / 1 ~~
#TC:		.half 1, 1
# answer : *verified*
#	Q = 1 
#	R = 0

# ~~ TC4 : 2 / 1 ~~
#TC:		.half 2, 1
# answer : *verified*
#	Q = 2 
#	R = 0

# ~~ TC5 : 1 / 2 ~~
#TC:		.half 1, 2
# answer : *verified*
#	Q = 0 
#	R = 1

# ~~ TC6 : half max'd ~~
#TC:		.half 0xFFFF, 0xFFFF
# answer : *verified*
#	Q = 1 
#	R = 0

# ~~ TC7 : quotent max'd ~~
#TC:		.half 0xFFFF, 1
# answer : *verified*
#	Q = 0xFFFF
#	R = 0

# ~~ TC8 : prime1 ~~
#TC:		.half 7919, 13
# answer : *verified*
#	Q = 609
#	R = 2

# ~~ TC9 : prime2 ~~
#TC:		.half 9973, 241
# answer : *verified*
#	Q = 41
#	R = 92

# ~~ TC10 : prime3 ~~
#TC:		.half 0xFFFF, 149
# answer : *verified*
#	Q = 439
#	R = 124

# ~~ TC11 : 0 / 0 ~~
#TC:		.half 0, 0
# answer : *verified*
#	RaiseError 
#	

# ~~ TC12 : denom max'd ~~
TC:		.half 1, 0xFFFF
# answer : *verified*
#	Q = 0
#	R = 1


.global _start

.text
#.equ MMIO_SWITCHES, 	0x00007F00
.equ MMIO_SEVSEG, 		0x00007F40
.equ MMIO_LEDS,			0x00007F20

_start:
	# ~~~~ init reg + TC injection ~~~~
	la s0, TC					# s0 is the addr for ARR
	li s1, MMIO_SEVSEG			# a2 is the addr for MMIO 7SEG
	li s2, MMIO_LEDS			# a2 is the addr for MMIO LEDS

	# ~~~~ caller(_start) saves non-preserved ~~~~
	# ~~ 1. caller(_start) allocates space on stack ~~
	# ~~ 2. caller(_start) stores reg values on stack ~~
	# ~~ 3. caller(_start) function execution ~~
	lhu a0, 0(s0)				# a0 is N
	lhu a1, 2(s0)				# a1 is D; NOTE: halfword spacing
	addi a2, s1, 0				# a2 is the addr for MMIO 7SEG
	addi a3, s2, 0				# a3 is the addr for MMIO LEDS
	jal DivBySub 
	# ~~ 4. caller(_start) restores preserved from stack ~~
	# ~~ 5. caller(_start) deallocates space on stack ~~

	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 0			# EXIT_SUCCESS code
	ecall				# execute sys call


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Purpose : Perform division by subtraction, writing the quotient to
#				addr1 and the remainder to addr2
#			
#
# Input :
#			a0 : [unsigned 16-bit] Numerator variable N
#			a1 : [unsigned 16-bit] Denominator variable D
#			a2 : [unsigned 32-bit] addr1
#			a3 : [unsigned 32-bit] addr2
#
# Return:	
#			

DivBySub:
	
	# ~~~~ calle(DivBySub) saves preserved ~~~~
	# ~~ 1. calle(DivBySub) allocates space on stack ~~
	addi sp, sp, -16

	# ~~ 2. calle(DivBySub) stores reg values on stack ~~
	sw s2, 12(sp)
	sw s1, 8(sp)
	sw s0, 4(sp)
	sw ra, 0(sp)

	# ~~ 3. calle(DivBySub) function execution ~~

	# ~ error ~
	blez a1, RaiseError	

	# ~ init ~
	addi t0, a0, 0				# R = t0 = N
	addi t1, zero, 0			# Q = t1 = 0

While:	# ~ while div produces integers s.t. (R >= D) ~
	# (R>= D) = (D > R)
	bgtu a1, t0, EndWhile
	sub t0, t0, a1				# R = R - D
	addi t1, t1, 1				# Q++
	j While
EndWhile:
	# ~ write to MMIOs ~
	sw t1, 0(a2)				# Q goes to addr1
	sw t0, 0(a3)				# R goes to addr2
	
	# ~~ 4. calle(DivBySub) restores preserved from stack ~~
	lw s2, 12(sp)
	lw s1, 8(sp)
	lw s0, 4(sp)
	lw ra, 0(sp)

	# ~~ 5. calle(DivBySub) deallocates space on stack ~~
	addi sp, sp, 16

	# ~~ calle return ~~
	jr ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

RaiseError:
	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 1			# EXIT_FAILURE code
	ecall				# execute sys call

