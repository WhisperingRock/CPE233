# Author : WhisperingRock
#
# Purpose : Read 10 conseq inputs from SWITCHES into array,
#			sort array in ASC order, 
#			then write the the entire array to LEDS consecutively
# Input : 
#			SWITCHES MMIO address to 32 bits
#			LEDS MMIO address to 32 bits
#
# Output :
#			Write 10 to LEDS addr


.data
ARR:	.word -7:10

# ~~~~ Test Cases ~~~~
# ~~ TC1: worst bubble case ~~
TC:		.word 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
# answer = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 

.global _start

.text
.equ MMIO_SWITCHES, 	0x00007F00
#.equ MMIO_SEVSEG, 		0x00007F40
.equ MMIO_LEDS,			0x00007F20
.equ ARR_N_ELEM,		10

_start:
	# ~~~~ init reg ~~~~
	la s0, ARR					# s0 is the addr for head of ARR
	addi s1, zero, ARR_N_ELEM	# s1 is the const num elem in ARR
	li s2, MMIO_SWITCHES		# s2 is the addr for MMIO SWITCHES
	li s3, MMIO_LEDS			# s3 is the addr for MMIO LEDS


	# ~~~~ caller(_start) saves non-preserved ~~~~
	# ~~ 1. caller(_start) allocates space on stack ~~
	# ~~ 2. caller(_start) stores reg values on stack ~~
	# ~~ 3. caller(_start) function execution ~~
	# ~ read from MMIO[SWITCHES] ~~
	addi a0, s0, 0				# a0 is the base addr for ARR
	addi a1, s1, 0				# a1 is the num of elem in ARR
	addi a2, s2, 0				# a2 is the r/w base address (set to SW to read)
	addi a3, zero, 0			# a3 is the "toMMIO" set to 0 for read
	jal ReadOrWrite
	# ~~ 4. caller(_start) restores preserved from stack ~~
	# ~~ 5. caller(_start) deallocates space on stack ~~

	# ~~~~ caller(_start) saves non-preserved ~~~~
	# ~~ 1. caller(_start) allocates space on stack ~~
	# ~~ 2. caller(_start) stores reg values on stack ~~
	# ~~ 3. caller(_start) function execution ~~
	# ~ sort array ~~
#	addi a0, s0, 0				# a0 is the base addr for ARR
#	addi a1, s1, 0				# a1 is the num of elem in ARR
#	jal BUBBLESORT
	# ~~ 4. caller(_start) restores preserved from stack ~~
	# ~~ 5. caller(_start) deallocates space on stack ~~

	# ~~~~ caller(_start) saves non-preserved ~~~~
	# ~~ 1. caller(_start) allocates space on stack ~~
	# ~~ 2. caller(_start) stores reg values on stack ~~
	# ~~ 3. caller(_start) function execution ~~
	# ~ write to MMIO[LEDS] ~~
	addi a0, s0, 0				# a0 is the base addr for ARR
	addi a1, s1, 0				# a1 is the num of elem in ARR
	addi a2, s3, 0				# a2 is the r/w base address (set to LED to write)
	addi a3, zero, 1			# a3 is the "toMMIO" set to 1 for write
	jal ReadOrWrite
	# ~~ 4. caller(_start) restores preserved from stack ~~
	# ~~ 5. caller(_start) deallocates space on stack ~~


	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 0			# EXIT_SUCCESS code
	ecall				# execute sys call


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Purpose : Read from from the MMIO address n times and place into array
#			or write the contents of array onto MMIO addr conseq n times.
#			
#
# Input :
#			a0 : [unsigned 32-bit] base address of array
#			a1 : [unsigned 32-bit] num elem in array
#			a2 : [unsigned 32-bit] base addres of MMIO
#			a3 : [unsigned 32-bit] r/w command (0-read, 1-write)
#			t3 : [unsigned 32-bit] base addr for test case array (if needed)
#
# Note :
#			- modifying a1 to save a register (caller preserve)
# Return:	
#			

ReadOrWrite:
	
	# ~~~~ calle(READORWRITE) saves preserved ~~~~
	# ~~ 1. calle(READORWRITE) allocates space on stack ~~
	addi sp, sp, -20

	# ~~ 2. calle(READORWRITE) stores reg values on stack ~~
	sw s3, 16(sp)
	sw s2, 12(sp)
	sw s1, 8(sp)
	sw s0, 4(sp)
	sw ra, 0(sp)

	# ~~ 3. calle(READORWRITE) function execution ~~

	# ~ init vars ~
	addi t0, zero, 0			# t0 = i = 0
	addi t1, zero, 0			# t1 = arr + i
								# t2 is local temp
	la t3, TC					# t3 is a test case var (array base addr)
								# t4 is a test case var (dummy)
	
	slli a1, a1, 2				# shift s.t. we dont use reg for i and 4i
	
	# ~ for(i=0; i < 10; i++) ~
For_ROW:
	bgeu t0, a1, End_For_ROW
	add t1, a0, t0				# t1 = arr + 4i


	beqz a3, ReadMMIO
	# ~ write to MMIO addr ~
	lw t2, 0(t1)				# t2 = *(arr + 4i)
	sw t2, 0(a2)				# MMIO[LEDS]= t2
	j End_ReadMMIO


ReadMMIO:
	# ~~~~ TC injection point ~~~~
	addi t4, t0, 0				# t4 = 4i
	add t4, t4, t3				# t4 = TC + 4i
	lw t4, 0(t4)				# t4 = *(TC + 4i)
	sw t4, 0(a2)				# MMIO[SWITCHES] = t4
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# ~ read from MMIO addr ~
	lw t2, 0(a2)				# read SW : t2 = MMIO[SWITCHES]
	sw t2, 0(t1)				# store in arr : *(arr+4i) = t2	
End_ReadMMIO:


	addi t0, t0, 4				# i++
	j For_ROW 
End_For_ROW:
	
	# ~~ 4. calle(READORWRITE) restores preserved from stack ~~
	lw s3, 16(sp)
	lw s2, 12(sp)
	lw s1, 8(sp)
	lw s0, 4(sp)
	lw ra, 0(sp)

	# ~~ 5. calle(READORWRITE) deallocates space on stack ~~
	addi sp, sp, 20

	# ~~ calle(READORWRITE) return ~~
	jr ra
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
