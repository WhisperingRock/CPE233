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

# ~~ TC1 : Zero ~~
#TC:		.word 0
# answer = 0 (verified)

# ~~ TC2 : Under ~~
#TC:		.word 0xFFF
# answer = 0x1FFE (verified)
 
# ~~ TC3 : One before ~~
#TC:		.word 0x07FFF
# answer = 0xFFFE (verified)

# ~~ TC4 : On boundary ~~
#TC:		.word 0x08000
# answer = 0x2000 (verified)

# ~~ TC5 : Above boundary ~~
#TC:		.word 0x08001
# answer = 0x2000 (verified)

# ~~ TC6 : Above boundary 2 ~~
#TC:		.word 0x12345678
# answer = 0x048D159E (verified)

# ~~ TC7 : 32-bit unsigned ceiling ~~
TC:		.word 0xFFFFFFFF
# answer = 0x3FFFFFFF (verified)

.global _start

.text
.equ MMIO_SWITCHES, 0x11000000
.equ MMIO_SEVSEG, 0x11000040
.equ CONST, 32768

_start:
	# ~~~~ init reg ~~~~
	li t1, MMIO_SWITCHES		# t1 is the addr for MMIO SWITCHES
	li t2, CONST				# t2 is the constant 32768
	li t3, MMIO_SEVSEG			# t3 is the addr for MMIO 7SEG
								# t4 is a test case variable
	
	# ~~~~ TC injection ~~~~
	lw t4, TC
	sw t4, 0(t1)

	# ~~~~ read SWITCHES ~~~~
	lw t0, 0(t1)				# load SW value into t0

	# ~~~~ unsigned branch ~~~~~
	bgeu t0, t2, Div4

	# ~~ else (false) case ~~
	slli t0, t0, 1				# multiply by 2
	j End

	# ~~ if (true) case ~~
Div4:
	srli t0, t0, 2				# logical shift for unsigned

	# ~~~~ write to 7SEG ~~~~
End:
	sw t0, 0(t3)	

	# ~~~~ syscall exit status ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 0			# EXIT_SUCCESS code
	ecall				# execute sys call

	
