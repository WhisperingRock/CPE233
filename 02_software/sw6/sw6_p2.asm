# Author : WhisperingRock
#
# Purpose :	Find the greatest common denominator using recursion 
#			
# Assumtions : All input unsigned and greater than zero.
#
# Input : 
#			- TC : [16-bit unsigned] array with at least 2 values
#
# Output :
#			- the gcd between the two numbers, written to a result array


.data

# ~~~~ Test Cases ~~~~
# ~~ TC1 : one decimal digit 1 ~~
#TC:		.half 	8, 16
#RES:	.word	0
# answer : 8  *verified*

# ~~ TC2 : one decimal digit rev ~~
#TC:		.half 	16, 8
#RES:	.word	0
# answer : 8  *verified*

# ~~ TC3 : same | floor ~~
#TC:		.half 	1, 1
#RES:	.word	0
# answer : 1  *verified*

# ~~ TC4 : same | ceiling ~~
#TC:		.half 	0xFF, 0xFF
#RES:	.word	0
# answer : 0xFF  *verified*

# ~~ TC5 : not input 1 ~~
#TC:		.half 	255, 102
#RES:	.word	0
# answer : 51  *verified*

# ~~ TC6 : not input 1 rev ~~
#TC:		.half 	102, 255
#RES:	.word	0
# answer : 51  *verified*

# ~~ TC7 : one #1~~
#TC:		.half 	1, 255
#RES:	.word	0
# answer : 1  *verified*

# ~~ TC8 : one rev #2  ~~
TC:		.half 	255, 1
RES:	.word	0
# answer : 1  *verified*

.global _start

.text
#.equ MMIO_SWITCHES, 	0x00007F00
#.equ MMIO_SEVSEG, 		0x00007F40
#.equ MMIO_LEDS,			0x00007F20

_start:
	# ~~~~ init reg + TC injection ~~~~
	# ~~ preserved ~~
	la s0, TC					# s0 is the addr for read array
	la s1, RES					# s1 is the addr for write array
	# ~~ non-preserved ~~
								# a0 first arg (consumed)
								# a1 second arg (consumed)
	
	# ~~~~ read from array (TC injection) ~~~~
	lhu a0, 0(s0)
	lhu a1, 2(s0)

	# ~~~~ caller(_start) saves non-preserved ~~~~
	# ~~ 1. caller(_start) allocates space on stack ~~
	# ~~ 2. caller(_start) stores reg values on stack ~~
	# ~~ 3. caller(_start) function execution ~~
	jal GCD 
	# ~~ 4. caller(_start) restores preserved from stack ~~
	# ~~ 5. caller(_start) deallocates space on stack ~~

	sw a0, 0(s1)				# write GCD to result array

	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 0			# EXIT_SUCCESS code
	ecall				# execute sys call


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Purpose :	Find the GCD by recursively subtracting til equal 
#				
#			
# Input :
#			a0 : [unsigned 16-bit] 
#			a1 : [unsigned 16-bit] 
#
# Return:	
#			a0 : [unsigned 16-bit] gcd between a0 and a1	

GCD:
	
	# ~~~~ calle(GCD) saves preserved ~~~~
	# ~~ 1. calle(GCD) allocates space on stack ~~
	addi sp, sp, -4
	# ~~ 2. calle(GCD) stores reg values on stack ~~
	sw ra, 0(sp)
	# ~~ 3. calle(GCD) function execution ~~
	
	bltu a1, a0, GCD_If
	bltu a0, a1, GCD_ElseIf
	j GCD_IfEnd

GCD_If:
	sub a0, a0, a1

	# a0 and a1 don't need to be preserved
	# ~~~~ caller(GCD) saves non-preserved ~~~~
	# ~~ 1. caller(GCD) allocates space on stack ~~
	# ~~ 2. caller(GCD) stores reg values on stack ~~
	# ~~ 3. caller(GCD) function execution ~~
	jal GCD 
	# ~~ 4. caller(GCD) restores preserved from stack ~~
	# ~~ 5. caller(GCD) deallocates space on stack ~~

	j GCD_IfEnd

GCD_ElseIf:
	sub a1, a1, a0
	# a0 and a1 don't need to be preserved
	# ~~~~ caller(GCD) saves non-preserved ~~~~
	# ~~ 1. caller(GCD) allocates space on stack ~~
	# ~~ 2. caller(GCD) stores reg values on stack ~~
	# ~~ 3. caller(GCD) function execution ~~
	jal GCD 
	# ~~ 4. caller(GCD) restores preserved from stack ~~
	# ~~ 5. caller(GCD) deallocates space on stack ~~

GCD_IfEnd:

	# ~~ return a0 as itself ~~

	# ~~ 4. calle() restores preserved from stack ~~
	lw ra, 0(sp)
	# ~~ 5. calle() deallocates space on stack ~~
	addi sp, sp, 4

	# ~~ calle return ~~
	jr ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

RaiseError:
	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 1			# EXIT_FAILURE code
	ecall				# execute sys call

