# Author : WhisperingRock
#
# Purpose : Difference between array elems 
# Input : 
#			Hardcoded values of fibonacci in array
#			LEDS MMIO address to 32 bits
#
# Output :
#			Write to LEDS addr


.data
FIB:	.word 0, 1, 1, 2, 3
		.word 5, 8, 13, 21, 34
		.word 55, 89, 144, 233, 377
		.word 610, 987, 1597, 2584, 4181
		.word 6765, 10946, 17711, 28657, 46368

# answer = 2, 2, 4, 6, 10, 16, 26, 42, 68, 110, 178, 
#			288, 466, 754, 1220, 1974, 3194, 5168, 8362
#			13530, 21892, 35422
# Verified - values match and does not exceed bounds

.global _start

.text
#.equ MMIO_SWITCHES, 	0x00007F00
#.equ MMIO_SEVSEG, 		0x00007F40
.equ MMIO_LEDS,			0x00007F20
.equ LAST_ELEM,			96			# 25th elem, 4 bytes apart

_start:
	# ~~~~ init reg ~~~~
	la a0, FIB					# a0 is the addr for head of FIB
	addi a1, a0, LAST_ELEM		# a1 is the addr for end of FIB
	li a2, MMIO_LEDS			# a2 is the addr for MMIO LEDS

	# ~~~~ caller(_start) saves non-preserved ~~~~
	# ~~ 1. caller(_start) allocates space on stack ~~
	addi sp, sp, -24
	# ~~ 2. caller(_start) stores reg values on stack ~~
	sw t2, 20(sp)
	sw t1, 16(sp)
	sw t0, 12(sp)
	sw a2, 8(sp)
	sw a1, 4(sp)
	sw a0, 0(sp)
	# ~~ 3. caller(_start) function execution ~~
	jal FIBDIFF 
	# ~~ 4. caller(_start) restores preserved from stack ~~
	lw t2, 20(sp)
	lw t1, 16(sp)
	lw t0, 12(sp)
	lw a2, 8(sp)
	lw a1, 4(sp)
	lw a0, 0(sp)
	# ~~ 5. caller(_start) deallocates space on stack ~~
	addi sp, sp, 24

	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 0			# EXIT_SUCCESS code
	ecall				# execute sys call


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Purpose : For all elements of the array, write (TO LEDS) the difference
#			between a elem and its left (3 over) neighbor, if they exist.
#
# Input :
#			a0 : [unsigned 32-bit] head address of array
#			a1 : [unsigned 32-bit] tail address of array
#			a2 : [unsigned 32-bit] LEDS MMIO addr
#
# Return:	
#			

FIBDIFF:
	
	# ~~~~ calle(FIBDIFF) saves preserved ~~~~
	# ~~ 1. calle(FIBDIFF) allocates space on stack ~~
	addi sp, sp, -4

	# ~~ 2. calle(FIBDIFF) stores reg values on stack ~~
	sw ra, 0(sp)

	# ~~ 3. calle(FIBDIFF) function execution ~~

	# ~ init vars ~
	addi t1, a0, 12		# t1 is the reference index and right neighbor
	addi t2, zero, 0	# t2 is the window differnce
	addi t3, zero, 0	# t3 is a working variable
	
	# ~ while the sliding window hasn't hit the right limit ~
While: # while t1 <= a1
	bgtu t1, a1, EndWhile
	
	# t2 = *(t1) - *(t0)
	lw t2, 0(t1)	# t2 = *(t1) (right neightbor)
	lw t3, 0(a0)	# t3 = *(a0) (left neightbor)
	sub t2, t2, t3	# t2 = t2 - t3

	# MMIO[LEDS] = t2
	sw t2, 0(a2)

	# slide window right
	addi a0, a0, 4
	addi t1, t1, 4

	j While
EndWhile:
	
	# ~~ 4. calle(FIBDIFF) restores preserved from stack ~~
	lw ra, 0(sp)

	# ~~ 5. calle(FIBDIFF) deallocates space on stack ~~
	addi sp, sp, 4

	# ~~ calle(FIBDIFF) return ~~
	jr ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
