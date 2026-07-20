# Author : WhisperingRock
#
# Purpose : Half word multiply
# Input : 
#			SWITCHES MMIO address to 32-bit unsigned value
#			7SEG MMIO address to 8-digits, each of 4-bits
#
# Output :
#			Write to 7SEG addr


.data
# ~~~~ Test Cases ~~~~

# ~~ TC1 : Zero ~~
#TC:		.word 0
# answer = 0		(verified)

# ~~ TC2 : Zero + One ~~
#TC:		.word 0x00000001
# answer = 0		(verified)

# ~~ TC3 : One + Zero~~
#TC:		.word 0x00010000
# answer = 0		(verified)

# ~~ TC4 : One ~~
#TC:		.word 0x00010001
# answer = 1		(verified)

# ~~ TC5 : num1 ~~
#TC:		.word 0x00130004
# answer = 0x0000_004C	(verified)

# ~~ TC6 : num1 reverse ~~
#TC:		.word 0x00040013
# answer = 0x0000_004C	(verified)

# ~~ TC7 : shift1 ~~
#TC:		.word 0xFFFFFFFF
# answer = 0xFFFE_0001	(verified)

# ~~ TC8 : shift2 ~~
#TC:		.word 0x0010FFFF
# answer = 0x000F_FFF0	(verified)

# ~~ TC9 : shift3 ~~
TC:		.word 0x0100FFFF
# answer = 0x00FF_FF00	(verified)

.global _start

.text
#.equ MMIO_SWITCHES, 0x11000000 # moved to Compact(Text @ 0) config
#.equ MMIO_SEVSEG, 	0x11000040	# sp moved tp 0x00003FFC
.equ MMIO_SWITCHES, 0x00007F00
.equ MMIO_SEVSEG, 	0x00007F40
.equ UPPER_WORD,	0xFFFF0000
.equ LOWER_WORD,	0x0000FFFF

_start:
	# ~~~~ init reg ~~~~
	li s1, MMIO_SWITCHES		# s1 is the addr for MMIO SWITCHES
	li s2, MMIO_SEVSEG			# s2 is the addr for MMIO 7SEG
								# a0 is a working variable for input and return
								# a1 is a working var for upper half of word
								# a2 is a working var for lower half of word
								# t0 is single use TC injection var
	
	# ~~~~ TC injection ~~~~
	lw t0, TC
	sw t0, 0(s1)

	# ~~~~ read SWITCHES ~~~~
	lw a0, 0(s1)

	# ~~~~ parse input val (and load args for func) ~~~~
	# ~~ a1 = (a0 & 0xFFFF0000) >> 16 ~~
	li t0, UPPER_WORD
	and a1, a0, t0
	srli a1, a1, 16
	# ~~ a0 = a0 & 0x0000FFFF ~~
	li t0, LOWER_WORD
	and a0, a0, t0

	# ~~~~ caller(_start) saves non-preserved ~~~~
	# "Not needed b/c we dont need t0"
	jal Multiply

	# ~~~~ write return to 7SEG ~~~~
	sw a0, 0(s2)	

	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 0			# EXIT_SUCCESS code
	ecall				# execute sys call


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Purpose : Multiply two unsigned 32-bit numbers
# Input :
#			a0 : 32-bit unsigned word
#			a1 : 32-bit unsigned word
# Temps :
#			t0 :
# Note  :
#			- consumes a1
# Return:	
#			a0 : product of a0 * a1
Multiply:
	
	# ~~~~ calle(Multiply) saves preserved ~~~~
	# ~~ 1. calle(Multiply) allocates space on stack ~~
	addi sp, sp, -12

	# ~~ 2. calle(Multiply) stores reg values on stack ~~
	sw ra, 8(sp)
	sw s1, 4(sp)
	sw s2, 0(sp)

	# ~~ 3. calle(Multiply) function execution ~~
	# ~ sum(t0) init ~
	addi t0, zero, 0
	# ~ while a1 <= 0
While:
	bleu a1, zero, EndWhile
	add t0, t0, a0
	addi a1, a1, -1
	j While
EndWhile:
	addi a0, t0, 0
	
	# ~~ 4. calle(Multiply) restores preserved from stack ~~
	lw ra, 8(sp)
	lw s1, 4(sp)
	lw s2, 0(sp)

	# ~~ 5. calle(Multiply) deallocates space on stack ~~
	addi sp, sp, 12

	# ~~ calle(Multiply) return ~~
	jr ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
