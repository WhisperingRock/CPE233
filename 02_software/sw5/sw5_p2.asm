# Author : WhisperingRock
#
# Purpose :   Stack using the stack
# Input : 
#			- SWITCHES & LEDS MMIO address to 32 bits
#
# Output :
#			- conseq write to LEDS addr


.data
# ~~~~ Test Cases ~~~~

# ~~ TC1 : loop limited 1 ~~
#TC:		.word 5, 4, 3, 2, 1
# answer : 1, 2, 3, 4, 5 (conseq writes)
# verified!

# ~~ TC2 : stopcode limited 1 ~~
#TC:		.word 5, 4, 0xFFFFFFFF, 2, 1
# answer : 4, 5 (conseq writes)
# verified!

# ~~ TC3 : immediate stopcode ~~
#TC:		.word 0xFFFFFFFF, 5, 4, 3, 2, 1
# answer : *no writes*
# verified!

# ~~ TC4 : loop limit is zero ~~
# ~ NOTE : change LIMIT to 0 ~
#TC:		.word 5, 4, 3, 2, 1
# answer : *no writes*
# verified!

# ~~ TC5 : near ceiling ~~
#TC:		.word 0xFFFFFFFB, 0xFFFFFFFC, 0xFFFFFFFD, 0xFFFFFFFE, 0xFFFFFFFF, 0
# answer : 0xFFFFFFFE, 0xFFFFFFFD, 0xFFFFFFFC, 0xFFFFFFFB, (conseq writes)
# verified!

# ~~ TC6 : stopcode and loop limits at same time ~~
#TC:		.word 5, 4, 3, 2, 1, 0xFFFFFFFF, 999
# answer : 1, 2, 3, 4, 5 (conseq writes)
# verified!

# ~~ TC7 : beyond loop limit ~~
TC:		.word 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
# answer : 6, 7, 8, 9, 10 (conseq writes)
# verified!

.global _start

.text

.equ MMIO_SWITCHES, 	0x00007F00
#.equ MMIO_SEVSEG, 		0x00007F40
.equ MMIO_LEDS,			0x00007F20

.equ LIMIT, 5
.equ STOPCODE, 0xFFFFFFFF

_start:
	# ~~~~ init reg + TC injection ~~~~
	la s0, TC					# s0 is the addr for TC array
	li s1, MMIO_SWITCHES		# a2 is the addr for MMIO SWITCHES
	li s2, MMIO_LEDS			# a2 is the addr for MMIO LEDS

	# ~~~~ caller(_start) saves non-preserved ~~~~
	# ~~ 1. caller(_start) allocates space on stack ~~
	# ~~ 2. caller(_start) stores reg values on stack ~~
	# ~~ 3. caller(_start) function execution ~~
	addi a0, s1, 0				# addr1 
	addi a1, s2, 0				# addr2
	li a2, LIMIT 				# loop limit
	li a3, STOPCODE				# stop value
	jal Stack
	# ~~ 4. caller(_start) restores preserved from stack ~~
	# ~~ 5. caller(_start) deallocates space on stack ~~

	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 0			# EXIT_SUCCESS code
	ecall				# execute sys call


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Purpose : Read values from addr1 onto the stack until the loop limit 
#			or stop code is reached. Then write the values, from the stack
#			to addr2. 
#			
#
# Input :
#			a0 : [unsigned 32-bit] read address
#			a1 : [unsigned 32-bit] write address
#			a2 : [unsigned 32-bit] loop limit
#			a3 : [unsigned 32-bit] stop code
#
# Note :
#			- using s0 as a global for TC injection
# Return:	
#			

Stack:
	
	# ~~~~ calle(Stack) saves preserved ~~~~
	# ~~ 1. calle(Stack) allocates space on stack ~~
	addi sp, sp, -16

	# ~~ 2. calle(Stack) stores reg values on stack ~~
	sw s2, 12(sp)
	sw s1, 8(sp)
	sw s0, 4(sp)
	sw ra, 0(sp)

	# ~~ 3. calle(Stack) function execution ~~
	# ~ init ~
	addi t0, zero, 0				# t0 = i = 0
									# t1, t2, t3 = read and logic temps
									# t4 = TC arr index variable
	# ---- TC Injection ----
	slli t4, t0, 2					# t4 = 4i (TC)
	add t4, t4, s0					# t4 = TC + 4i
	lw t4, 0(t4)					# t4 = *(TC + 4i)
	sw t4, 0(a0)					# MMIO[addr1] = t4
	# ----------------------
	lw t1, 0(a0)					# t1 = MMIO[addr1]
ReadWhile:
	sltu t2, t0, a2					# t2 = (i < limit)
	seqz t2, t2
	xor t3, t1, a3					# t3 = (t1 != stopcode)
	seqz t3, t3
	or t3, t3, t2					# t3 = t3 && t2
	bgt t3, zero, End_ReadWhile 	# while (i < limit) && (t1 != stopcode)
	addi sp, sp, -4						# sp -= 4
	sw t1, 0(sp)						# RAM[sp] = read
	addi t0, t0, 1						# i++
	# ---- TC Injection ----
	slli t4, t0, 2						# t4 = 4i (TC)
	add t4, t4, s0						# t4 = TC + 4i
	lw t4, 0(t4)						# t4 = *(TC + 4i)
	sw t4, 0(a0)						# MMIO[addr1] = t4
	# ----------------------
	lw t1, 0(a0)						# t1 = MMIO[addr1]
	j ReadWhile
End_ReadWhile:
WriteWhile:					
	beqz t0, End_WriteWhile			# while(i > 0)
	lw t1, 0(sp)						# t1 = RAM[sp]
	addi sp, sp, 4						# sp += 4
	addi t0, t0, -1						# i--
	sw t1, 0(a1)						# MMIO[addr2] = t1
	j WriteWhile
End_WriteWhile:
	
	# ~~ 4. calle(Stack) restores preserved from stack ~~
	lw s2, 12(sp)
	lw s1, 8(sp)
	lw s0, 4(sp)
	lw ra, 0(sp)

	# ~~ 5. calle(Stack) deallocates space on stack ~~
	addi sp, sp, 16

	# ~~ calle return ~~
	jr ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

RaiseError:
	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 1			# EXIT_FAILURE code
	ecall				# execute sys call

