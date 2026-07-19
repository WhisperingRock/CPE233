# Author : WhisperingRock
#
# Purpose : Confirm decoded machine code (by hand)
#			functionality matches what the RARS compiler 
#			produces. 



.data
A:	.word 0x1234		# dummy value to see change

.global _start

.text
.equ	MMIO, 0x11000000

_start:
	# ~~~~ init registers ~~~~
	li t1, MMIO
	lw t2, A
	sw t2, 0(t1)

	# ~~~~ decoded instr ~~~~
	#lui x10, 0x11000
	#addi x30, x0, 0x00A
#loop:
	#lh x15, 0(x10)					
	#sra x20, x15, x30
	#xor x12, x20, x15
	#sw x12, 0x040(x10)
	#jal x0, loop		#loop label is 4 spaces back
	
	lui a0, 0x11000				# a0 = x10
	addi t5, zero, 0x00A			# zero = x0, t5 = x30
loop:
	lh a5, 0(a0)					# a5 = x15
	sra s4, a5, t5					# s4 = x20
	xor a2, s4, a5					# a2 = x12 
	sw a2, 64(a0)
	jal zero, loop

	# ~~~~ syscall exit status ~~~~
	li a7, 10		# load syscall call num for exit()
	li a0, 0		# EXIT_SUCCESS code
	ecall			# make the system call

