# Author : WhisperingRock
#
# Purpose : quick crunch for verification table 
#			
# Input : 
#
# Output :
#			


.data

# ~~~~ ADD ~~~~
#A:	.word 0xA50F96C3
#B:	.word 0x5AF0693C
# answer = 0xFFFF_FFFF

#A:	.word 0x84105F21
#B:	.word 0x7B105FDE
# answer = 0xFF20_BEFF

#A:	.word 0xFFFFFFFF
#B:	.word 0x0000_0001
# answer = 0x0


# ~~~~ SUB ~~~~
#A:	.word 0x00000000
#B:	.word 0x00000001
# answer = 0xFFFF_FFFF

#A:	.word 0xAA806355
#B:	.word 0x550162AA
# answer = 0x557F_00AB

#A:	.word 0x550162AA
#B:	.word 0xAA806355
# answer = 0xAA80_FF55


# ~~~~ AND ~~~~
#A:	.word 0xA55A00FF
#B:	.word 0x5A5A62FF
# answer = 0x005A_00FF

#A:	.word 0xC3C3F966
#B:	.word 0xFF669F5A
# answer = 0xC342_9942


# ~~~~ OR ~~~~
#A:	.word 0x9A9AC300
#B:	.word 0x65A3CC0F
# answer = 0xFFBB_CF0F

#A:	.word 0xC3C3F966
#B:	.word 0xFF669F5A
# answer = 0xFFE7_FF7E


# ~~~~ XOR ~~~~
#A:	.word 0xAA5500FF
#B:	.word 0x5AA50FF0
# answer = 0xF0F0_0F0F

#A:	.word 0xA5A56C6C
#B:	.word 0xFF00C6FF
# answer = 0x5AA5_AA93


# ~~~~ SRL ~~~~
#A:	.word 0x805A6CF3
#B:	.word 0x00000010
# answer = 0x0000_805A

#A:	.word 0x705A6CF3
#B:	.word 0x00000005
# answer = 0x0382_D367

#A:	.word 0x805A6CF3
#B:	.word 0x00000000
# answer = 0x805A_6CF3

#A:	.word 0x805A6CF3
#B:	.word 0x00000100		# 256 mod 32 = 0, shifting 0
# answer = 0x805A_6CF3


# ~~~~ SLL ~~~~
#A:	.word 0x805A6CF3
#B:	.word 0x00000010
# answer = 0x6CF3_0000

#A:	.word 0x805A6CF3
#B:	.word 0x00000005
# answer = 0x0B4D_9E60

#A:	.word 0x805A6CF3
#B:	.word 0x00000100		# 256 mod 32 = 0, shifting 0
# answer = 0x805A_6CF3


# ~~~~ SRA ~~~~
#A:	.word 0x805A6CF3
#B:	.word 0x00000010
# answer = 0xFFFF_805A

#A:	.word 0x705A6CF3
#B:	.word 0x00000005
# answer = 0x0382_D367

#A:	.word 0x805A6CF3
#B:	.word 0x00000000
# answer = 0x805A_6CF3

#A:	.word 0x805A6CF3
#B:	.word 0x00000100		# 256 mod 32 = 0, shifting 0
# answer = 0x805A_6CF3


# ~~~~ SLT : set if less ~~~~
#A:	.word 0x7FFFFFFF
#B:	.word 0x80000000
# answer = 0x0000_0000

#A:	.word 0x80000000
#B:	.word 0x00000001
# answer = 0x0000_0001

#A:	.word 0x00000000
#B:	.word 0x00000000
# answer = 0x0000_0000

#A:	.word 0x55555555
#B:	.word 0x55555555
# answer = 0x0000_0000


# ~~~~ SLTU : unsigned set if less ~~~~
#A:	.word 0x7FFFFFFF
#B:	.word 0x80000000
# answer = 0x0000_0001

#A:	.word 0x80000000
#B:	.word 0x00000001
# answer = 0x0000_0000

#A:	.word 0x00000000
#B:	.word 0x00000000
# answer = 0x0000_0000

#A:	.word 0x55AA55AA
#B:	.word 0x55AA55AA
# answer = 0x0000_0000


# ~~~~ LUI-COPY (Mov?) ~~~~
#A:	.word 0x01234567
#B:	.word 0x76543210
# answer = 0x0123_4567

A:	.word 0xFEDCBA98
B:	.word 0x89ABCDEF
# answer = 0xFEDC_BA98

.global _start

.text
.equ LUI_B1, 0x76543210

_start:

	# ~~~~ init reg ~~~~
	lw t0, A
	lw t1, B
	addi t2, zero, 0

	# ~~~~ instr of choice ~~~~
	#add t2, t0, t1
	#sub t2, t0, t1
	#and t2, t0, t1
	#or t2, t0, t1
	#xor t2, t0, t1
	#srl t2, t0, t1
	#sll t2, t0, t1
	#sra t2, t0, t1
	#slt t2, t0, t1
	#sltu t2, t0, t1
	mv t2, t0				# LUI-COPY ???

