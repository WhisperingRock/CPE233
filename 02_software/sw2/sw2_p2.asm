# Author : WhisperingRock
#
# Purpose : Conditionals, branching, jumping
# Input : 
#			SWITCHES MMIO address to 32-bit unsigned value
#			7SEG MMIO address to 8-digits, each of 4-bits
#			constant CONST
#
# Output :
#			Write to 7SEG addr


.data
# ~~~~ Test Cases ~~~~

# ~~ TC1 : Zero (Div4) ~~
#TC:		.word 0
# answer = 0xFFFF_FFFF	(verified)

# ~~ TC2 : Two (Div2 = even) ~~
#TC:		.word 2
# answer = 0x1 			(verified)
 
# ~~ TC3 : 1 (odd) ~~
#TC:		.word 0x1
# answer = 0x0800		(verified)

# ~~ TC4 : 32-bit unsigned ceiling ~~
#TC:		.word 0xFFFFFFFF
# answer = 0x0000_07FF | 2047 (verified)

# ~~ TC5 : unsigned ceiling Div4 ~~
#TC:		.word 0xFFFFFFFC
# answer = 0x03 				(verified)

# ~~ TC6 : unsigned ceiling odd ~~
#TC:		.word 0xFFFFFFFD
# answer = 0x07FE 				(verified)

# ~~ TC6 : unsigned ceiling even ~~
TC:		.word 0xFFFFFFFE
# answer = 0xFFFFFFFD 			(verified)

.global _start

.text
.equ MMIO_SWITCHES, 0x11000000
.equ MMIO_SEVSEG, 0x11000040


_start:
	# ~~~~ init reg ~~~~
	li s1, MMIO_SWITCHES		# s1 is the addr for MMIO SWITCHES
	li s2, MMIO_SEVSEG			# s2 is the addr for MMIO 7SEG
								# t0 is the working variable for SWITCHES value
								# t1 is a logic case variable
	li t2, 4095					# t2 is reserved for const 
	
	# ~~~~ TC injection ~~~~
	lw t0, TC
	sw t0, 0(s1)

	# ~~~~ read SWITCHES ~~~~
	lw t0, 0(s1)				# load SW value into t0

	# ~~~~ branch : div by 4 ~~~~~
	andi t1, t0, 0x3				
	beqz t1, Div4
	
	# ~~~~ branch : div by 2 ~~~~~
	andi t1, t0, 0x1				
	beqz t1, Div2

	# ~~ else case ~~
	add t0, t0, t2				# add const 4095
	srli t0, t0, 1				# then scale
	j End

Div4:
	not t0, t0					# invert bits
	j End
	
Div2:
	addi t0, t0, -1

End:	# ~~~~ write to 7SEG ~~~~
	sw t0, 0(s2)	



	# ~~~~ syscall exit status ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 0			# EXIT_SUCCESS code
	ecall				# execute sys call

	
