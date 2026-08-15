# Author : WhisperingRock
#
# Purpose : machine code dump for which to compare results on OTTER MCU 
#
# Input : 
#
# Output :

main:
	lui 	x5, 	0xAA055				# x5 = 0xAA05_5000
	addi 	x8,		x5,		0x765		# x8 = 0xAA05_5000 + 0x0000_0765 = 0xAA05_5765
	slli 	x10,	x8,		3			# x10 = 0x502A_BB28
	slt 	x12,	x5,		x8			# x12 = 1
	xor 	x13,	x8,		x10			# x13 = 0xFA2F_EC4D
	beq 	x0,		x0,		main		# 0 == 0, return to main
