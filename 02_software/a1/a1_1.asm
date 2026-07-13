# Author : WhisperingRock
#
# Purpose : Read from the SWITCHES addr in memory three consecutive
#			times, summing the unsigned half-word reads and writing 
#			to the LEDS addr. 
#			
# Notes : 
#			- Assume caller/calle has no need to preserve reg values.
#				KISS method for this assignment
#
#			- Split 32-bit addresses according to instr imm handling.




.global main

#.equ SWITCHES_H,	0x11000	# upper 20 bits
#.equ SWITCHES_L,	0x000	# lower 12 bits
.equ SWITCHES_H,	0x00006	# upper 20 bits (data seg at 0x00006000)
.equ SWITCHES_L,	0x000	# lower 12 bits

#.equ LEDS_H,		0x11000 # upper 20 bits
#.equ LEDS_L,		0x020	# lower 12 bits
.equ LEDS_H,		0x00006 # upper 20 bits (data seg at 0x00006020)
.equ LEDS_L,		0x020	# lower 12 bits

# ~~~~~~~~ Test Cases ~~~~~~~~
# TC1 : Word Clip
#.equ READ1_H,		0x00001	# switch first read (0x1234)
#.equ READ1_L, 		0x234

#.equ READ2_H, 		0x12345 # switch second read (0x5678)
#.equ READ2_L, 		0x678	

#.equ READ3_H,		0x11111	# switch third read (0x1111)
#.equ READ3_L,		0x111
#	answer= 0x79BD

# TC2 : Maxed 
#.equ READ1_H,		0x00005	# switch first read (0x5555)
#.equ READ1_L, 		0x555

#.equ READ2_H, 		0x00005 # switch second read (0x5555)
#.equ READ2_L, 		0x555	# sign extended

#.equ READ3_H,		0x00005	# switch third read (0x5555)
#.equ READ3_L,		0x555
#	answer= 0xFFFF

# TC3 : Overflow
#.equ READ1_H,		0x00005	# switch first read (0x5555)
#.equ READ1_L, 		0x555

#.equ READ2_H, 		0x00005 # switch second read (0x5555)
#.equ READ2_L, 		0x555	# sign extended

#.equ READ3_H,		0x00005	# switch third read (0x5557)
#.equ READ3_L,		0x557
#	answer= 0x0001

# TC4 : zero
#.equ READ1_H,		0x00000	# switch first read (0)
#.equ READ1_L, 		0x0

#.equ READ2_H, 		0x00000 # switch second read (0)
#.equ READ2_L, 		0x0	# sign extended

#.equ READ3_H,		0x00000	# switch third read (0)
#.equ READ3_L,		0x0
#	answer= 0x0000

# TC5 : MAXXXED
#.equ READ1_H,		0x0000F	# switch first read (0xFFFF)
#.equ READ1_L, 		-1

#.equ READ2_H, 		0xFFFFF # switch second read (0xFFFF)
#.equ READ2_L, 		-1	

#.equ READ3_H,		0x00000	# switch third read (0)
#.equ READ3_L,		0
#	answer= 0xFFFE

# TC6 : All highs into full
.equ READ1_H,		0x00008	# switch first read 
.equ READ1_L, 		0x000

.equ READ2_H, 		0x00008 # switch second read 
.equ READ2_L, 		0x000

.equ READ3_H,		0x00008	# switch third read
.equ READ3_L,		0x000
#	answer= 0x8000 (0x18000 as full word though)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

main:

	# ~~~~ register init ~~~~
	addi t0, zero, 0	# t0 is the SW first read
	addi t1, zero, 0	# t1 is the SW second read
	addi t2, zero, 0	# t2 is the SW third read
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

	# ~~ behind the scenes : switch mem changes value ~~
	lui t3, READ2_H
	ori t3, t3, READ2_L
	sw t3, 0(s0)			# only 3 bytes are stored (0x678)
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	lhu  t1, 0(s0)			# second read

	# ~~~~ behind the scenes : switch mem changes value ~~~~
	lui t3, READ3_H
	ori t3, t3, READ3_L
	sw t3, 0(s0)			# only 3 bytes are stored (0x111)
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	lhu  t2, 0(s0)			# third read

	# ~~~~ sum values ~~~~
	add t0, t0, t1
	add t0, t0, t2


	# ~~~~ Write the unsigned half word to LEDS mem addr
	sh t0, 0(s1)


	# ~~~~ return with exit status ~~~~
	li a7, 10		# load system call number for exit()
	li a0, 0		# Load the exit status code ( EXIT_SUCCESS )
	ecall			# Make the system call




