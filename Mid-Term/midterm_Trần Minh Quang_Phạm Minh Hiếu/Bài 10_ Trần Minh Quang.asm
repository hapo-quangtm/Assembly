#------------------------------------------------------------------
# $s0 chứa giá trị của i 
# $s1 chứa giá trị của i^2
# $s2 chứa giá trị của 2^i
# $s3 chứa giá trị của hexa i 
#------------------------------------------------------------------

#------------------------------------------------------------------
# @brief 	Nhap tu ban phim mot so nguyen va tra ve cac gia tri binh phuong, hexa, luy thua cua 2
# @param[in]	User input integer i
# @param[out]	power(2,i), square(i), hexadecimal(i)
#------------------------------------------------------------------
.data
str1: .asciiz "Input an interger: "
str2: .asciiz "\nGia Tri i: "
str3: .asciiz "\ni\tpower(2,i)\tsquare(i)\tHexadecimal(i)\n"
str4: .asciiz "\t"
str5: .asciiz "\n"
hex:  .space 10
.text
main:
#------------------------------------------------------------------
	#print: i power(2,i) square(i) Hexadecimal(i)
	li 	$v0, 4
	la 	$a0, str3	
	syscall
Init:
	li 	$v0, 51
	la 	$a0, str1
	syscall

	beq 	$a1, -1, Init			# if $a1 == -1, nhap lai (kieu nhap vao khong dung)
	beq 	$a1, -3, Init			# if $a1 == -3, nhap lai (khong co gia tri nao nhap vao)
	beq 	$a1, -2, EXIT			# if $a1 == -2, exit 	 (nguoi dung cancel)
	
	move 	$s0, $a0			# i luu vao $s0
	
	blt 	$s0, 0, Init			# check if i < 0
	bgt 	$s0, 30, Init			# check if i > 30
	beq 	$s0, 0, EXIT			# if i == 0, exit
	
	j 	Power
	nop  
H2:
	j 	Square
	nop
H3:
	j 	Hexadecimal
	nop
H1:
	j 	INKETQUA
	
#------------------------------------------------------------------
# @label INKETQUA: in bang ket qua duoi man hinh (Run I/O)
#------------------------------------------------------------------
INKETQUA:

#------------------------------------------------------------------
	#print i
	li 	$v0, 1
	la 	$a0, ($s0)	
	syscall
#------------------------------------------------------------------
	# print \t
	la 	$a0, str4
	li 	$v0, 4  
	syscall
#------------------------------------------------------------------
	#print power
	li 	$v0, 1
	la 	$a0, ($s2)
	syscall
#------------------------------------------------------------------
	# print \t\t
	la 	$a0, str4
	li 	$v0, 4  
	syscall
	syscall
#------------------------------------------------------------------
	#print square
	li 	$v0, 1
	la 	$a0, ($s1)
	syscall
#------------------------------------------------------------------
	# print \t\t
	la 	$a0, str4
	li 	$v0, 4  
	syscall
	syscall
#------------------------------------------------------------------
	#print Hexadecimal
	li 	$v0, 4
	la 	$a0, hex
	syscall	
#------------------------------------------------------------------
	#print \n
	la $a0, str5
	li $v0, 4
	syscall
	j 	Init
#------------------------------------------------------------------
# @label Power: tinh gia tri 2^i
# @param[in];	$s0 - gia tri i nhap vao
# @param[out]:  $s2 - gia tri 2^i
#------------------------------------------------------------------
Power:
	addi 	$t1, $zero, 1			# j = 1
	addi 	$s2, $zero, 2			# power = 1
	addi 	$t3, $zero, 2			# $t3 = 2
for:	slt 	$t4, $t1, $s0			# if i == j 
	beq 	$t4, $zero, H2			# thoat khoi vong lap
	mul 	$s2, $s2, $t3			# power *= 2
	mfhi	$s2
	mflo 	$s2
	addi 	$t1, $t1, 1			# j += 1
	j 	for
#------------------------------------------------------------------
# @label Square: tinh gia tri i^2
# @param[in]: 	 $s0 - gia tri i nhap vao 
# @param[out]:   $s1 - gia tri i^2
#------------------------------------------------------------------

Square:
	mult 	$s0, $s0
	mfhi 	$s1
	mflo 	$s1
	j 	H3
	
#------------------------------------------------------------------
# @label Hexadecimal: tra ve gia tri hexa cua so nhap vao
# @param[in]: 	      $s0 - gia tri i nhap vao
# @param[out]: 	      $s3 - gia tri hexa cua i
#------------------------------------------------------------------
Hexadecimal:
	la		$a0, hex				# nap dia chi cua hex vao $a0
	add		$a1, $zero, $s0				# $a1 = i
	
	li		$t1, 48					# them 0x vao string hex
	sb		$t1, 0($a0)				
	addi		$a0, $a0, 1				
	li		$t1, 120					
	sb		$t1, 0($a0)				
	addi		$a0, $a0, 1		
	
	li		$t0, 8					# counter = 0
	li		$t2, 0					# flag $t2=0
	
hexLoop:
	beqz		$t0, hexDone				# counter == 0 => hexDone
	andi		$t1, $a1, 0xf0000000			# lay 4 bits ngoai cung ben trai
	srl		$t1, $t1, 28				# di chuyen 4 bit nay ve ngoai cung ben phai
	beq		$t1, $t2, continue			# $t1 == $t2 (= 0) => ignore 0
	ble		$t1, 9, less				# $t1 <= 9 => ASCII Code
	addi		$t1, $t1, 55				# [A-F]
	j		writeHex
	
less:	
	addi		$t1, $t1, 48				# [1-9]
	
writeHex:	
	addi		$t2, $t2, -1				# remove flag 
	sb		$t1, 0($a0)				# viet ma ASCII vao hex string
	addi		$a0, $a0, 1
	
continue:	
	sll		$a1, $a1, 4				# dich trai 4 bit tiep theo
	addi		$t0, $t0, -1				# counter -= 1
	j		hexLoop	
	
hexDone:
	j		H1
EXIT:
	li 	$v0, 10
	syscall
