# Author : WhisperingRock
#
# Purpose : Delay 
# Input : 
#			SWITCHES MMIO address to 32-bit unsigned value
#			7SEG MMIO address to 8-digits, each of 4-bits
#
# Output :
#			Write to 7SEG addr


.data
# ~~~~ Test Cases ~~~~

# ~~ TC1 : simple ~~
TC:		.word 0x12345678
# answer = 0		(verified)

.global _start

.text
#.equ MMIO_SWITCHES, 	0x11000000	# moved to Compact(Text @ 0) config
#.equ MMIO_SEVSEG, 		0x11000040	# sp moved tp 0x00003FFC
.equ MMIO_SWITCHES, 	0x00007F00
.equ MMIO_SEVSEG, 		0x00007F40
.equ HALF_SEC_DELAY,	0x00BEBC20	# 12,500,000 instr for 0.5s delay
.equ OFFSET,			0x007F2819	# loop and bias compensation (see notes)

_start:
	# ~~~~ init reg ~~~~
	li s1, MMIO_SWITCHES		# s1 is the addr for MMIO SWITCHES
	li s2, MMIO_SEVSEG			# s2 is the addr for MMIO 7SEG
								# s3 is a working variable for input and return
	li a0, HALF_SEC_DELAY		# a0 is reserved for const
	li a1, OFFSET				# a1 is reserved for offset
								# t0 is single use TC injection var
	
	# ~~~~ TC injection ~~~~
	lw t0, TC
	sw t0, 0(s1)

	# ~~~~ read SWITCHES ~~~~
	lw s3, 0(s1)

	# ~~~~ caller(_start) saves non-preserved ~~~~
	# "Not needed b/c we dont need t0"
	sub a0, a0, a1						# a0 = delay - offset ; +1 bias
	jal Delay							# +1 bias

	# ~~~~ write return to 7SEG ~~~~
	sw s3, 0(s2)	

	# ~~~~ syscall exit ~~~~
	li a7, 10			# load syscall num for exit()
	li a0, 0			# EXIT_SUCCESS code
	ecall				# execute sys call


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Purpose : delay(busy wait) of 0.5s
# Input :
#			a0 : [unsigned 32-bit] delay amount in instruction count
# Note : 
#			- Consuming a0 in the process
# Return:	
#			

Delay:
	
	# ~~~~ calle(Delay) saves preserved ~~~~
	# ~~ 1. calle(Delay) allocates space on stack ~~
	addi sp, sp, -16							# +1 bias

	# ~~ 2. calle(Delay) stores reg values on stack ~~
	sw ra, 12(sp)								# +1 bias
	sw s1, 8(sp)								# +1 bias
	sw s2, 4(sp)								# +1 bias
	sw s3, 0(sp)								# +1 bias



	# ~~ 3. calle(Delay) function execution ~~
	# ~ while a0 <= 0
While: # loop = 3x instr
	bleu a0, zero, EndWhile 
	addi a0, a0, -1
	j While
EndWhile:
	
	# ~~ 4. calle(Delay) restores preserved from stack ~~
	lw ra, 12(sp)								# +1 bias
	lw s1, 8(sp)								# +1 bias
	lw s2, 4(sp)								# +1 bias
	lw s3, 0(sp)								# +1 bias

	# ~~ 5. calle(Delay) deallocates space on stack ~~
	addi sp, sp, 16								# +1 bias

	# ~~ calle(Delay) return ~~
	jr ra										# +1 bias
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
