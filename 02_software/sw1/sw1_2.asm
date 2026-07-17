# Author : WhisperingRock
#
# Purpose : Read from the SWITCHES addr in memory a unsigned half-word
#			changing the sign, then writing to the LEDS addr.
#			
# Notes : 
#			- Assume caller/calle has no need to preserve reg values.
#				KISS method for this assignment
#
#			- Split 32-bit addresses according to instr imm handling.

.data
# ~~~~~~~~ Test Cases ~~~~~~~~
# TC1 : zero
#A:	.half 0
#	answer= 0x0000

# TC2 : positive 
#A:	.half 0x5
#	answer= 0xFFFB (-5)

# TC3 : negative 
#A:	.half 0xFFFB		# -5
#	answer= 0x0005		#  5

# TC4 : positive 
#A:	.half 0x5678		# 22136
#	answer= 0xA988		# -22136

# TC5 : reverse
#A:	.half 0xA988		
#	answer= 0x5678

# TC6 : negative 
#A : .half 0xFFFF #(-1)
#	answer= 1

# TC7 : negative 2
#A : .half 0xFFFE #(-2)
#	answer= 2

# TC7 : negative 32 bit
#A : .word 0x89ABCDEF		#(0xCDEF = -12817)
#	answer= 0x3211			# 12817

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


.global _start
.text
#.equ SWITCHES_H,	0x11000	# upper 20 bits
#.equ SWITCHES_L,	0x000	# lower 12 bits
.equ SWITCHES_H,	0x00006	# upper 20 bits (data seg at 0x00006000)
.equ SWITCHES_L,	0x000	# lower 12 bits

#.equ LEDS_H,		0x11000 # upper 20 bits
#.equ LEDS_L,		0x020	# lower 12 bits
.equ LEDS_H,		0x00006 # upper 20 bits (data seg at 0x00006020)
.equ LEDS_L,		0x020	# lower 12 bits



_start:

	# ~~~~ register init ~~~~
	addi t0, zero, 0	# t0 is the SW first read
						# t3 is a dummy variable for testing

						# s0 contains the SWITCH addr
						# s1 contains the LEDS addr
	
	# ~~~~ load addr into registers ~~~~
	lui s0, SWITCHES_H
	addi s0, s0, SWITCHES_L

	lui s1, LEDS_H
	addi s1, s1, LEDS_L


	# ~~~~ read SWITCHES and sum ~~~~

	# ~~ behind the scenes : switch value ~~
	lw t3, A
	sw t3, 0(s0)			
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	lhu  t0, 0(s0)			# first read


	# ~~~~ invert the sign (2sC) ~~~~
	not t0, t0
	addi t0, t0, 1

	# ~~~~ Write the unsigned half word to LEDS mem addr
	sh t0, 0(s1)


	# ~~~~ return with exit status ~~~~
	li a7, 10		# load system call number for exit()
	li a0, 0		# Load the exit status code ( EXIT_SUCCESS )
	ecall			# Make the system call




