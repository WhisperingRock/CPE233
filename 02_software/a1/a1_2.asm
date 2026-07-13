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




.global _start

#.equ SWITCHES_H,	0x11000	# upper 20 bits
#.equ SWITCHES_L,	0x000	# lower 12 bits
.equ SWITCHES_H,	0x00006	# upper 20 bits (data seg at 0x00006000)
.equ SWITCHES_L,	0x000	# lower 12 bits

#.equ LEDS_H,		0x11000 # upper 20 bits
#.equ LEDS_L,		0x020	# lower 12 bits
.equ LEDS_H,		0x00006 # upper 20 bits (data seg at 0x00006020)
.equ LEDS_L,		0x020	# lower 12 bits

# ~~~~~~~~ Test Cases ~~~~~~~~
# TC1 : zero
.equ READ1_H,		0x00000	# switch first read (0)
.equ READ1_L, 		0x0
#	answer= 0x0000


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

	# ~~ behind the scenes : switch mem changes value ~~
	lui t3, READ1_H
	ori t3, t3, READ1_L
	sw t3, 0(s0)			# only 3 bytes are stored (0x234)
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	lhu  t0, 0(s0)			# first read


	# ~~~~ invert the sign
	

	# ~~~~ Write the unsigned half word to LEDS mem addr
	sh t0, 0(s1)


	# ~~~~ return with exit status ~~~~
	li a7, 10		# load system call number for exit()
	li a0, 0		# Load the exit status code ( EXIT_SUCCESS )
	ecall			# Make the system call




