# Mars bot
.eqv HEADING 0xffff8010 
.eqv MOVING 0xffff8050
.eqv LEAVETRACK 0xffff8020
.eqv WHEREX 0xffff8030
.eqv WHEREY 0xffff8040

# Key matrix
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012

.data
# postscript-DCE => numpad 0
# (rotate,time,0=untrack | 1=track;)
pscript1: .asciiz "90,2000,0;180,3000,0;180,5790,1;80,500,1;70,500,1;60,500,1;50,500,1;40,500,1;30,500,1;20,500,1;10,500,1;0,500,1;350,500,1;340,500,1;330,500,1;320,500,1;310,500,1;300,500,1;290,500,1;285,490,1;90,8000,0;270,500,1;260,500,1;250,500,1;240,500,1;230,500,1;220,500,1;210,500,1;200,500,1;190,500,1;180,500,1;170,500,1;160,500,1;150,500,1;140,500,1;130,500,1;120,500,1;110,500,1;100,500,1;90,900,1;90,5000,0;270,3000,1;0,5800,1;90,3000,1;180,2900,0;270,2995,1;90,3500,0;"
# postscript-HIEU => numpad 4
pscript2: .asciiz "90,2000,0;180,3000,0;180,5790,1;0,2900,0;90,3000,1;0,2900,0;180,5790,1;90,1500,0;0,5790,1;90,4500,0;270,3000,1;180,5790,1;90,3000,1;0,2900,0;270,2995,1;90,4500,0;0,2900,0;180,5000,1;170,200,1;160,200,1;150,200,1;140,200,1;130,200,1;90,2300,1;50,200,1;40,200,1;30,200,1;20,200,1;10,200,1;0,5000,1;90,1000,0;"
# postscript-ELFSJ => numpad 8
pscript3: .asciiz "180,3000,0;90,5000,0;270,3000,1;180,5790,1;90,3000,1;0,2900,0;270,2990,1;90,4500,0;0,2900,0;180,5790,1;90,3000,1;90,1500,0;0,5790,1;90,3000,1;180,2900,0;270,2995,1;90,9000,0;0,2850,0;90,100,0;300,250,1;280,350,1;270,350,1;260,300,1;250,300,1;240,300,1;220,300,1;210,500,1;200,500,1;180,300,1;160,500,1;140,500,1;120,500,1;100,500,1;90,300,1;110,300,1;120,300,1;140,500,1;160,500,1;180,500,1;190,300,1;200,300,1;210,300,1;220,300,1;230,300,1;240,300,1;250,300,1;270,500,1;280,500,1;90,4000,0;0,5790,0;90,3500,1;270,1700,0;180,4700,1;190,200,1;200,200,1;210,200,1;220,200,1;230,200,1;240,200,1;250,200,1;270,300,1;280,300,1;180,1000,0"

.text 
# Nhan dau vao tu key matrix
	li $t3, IN_ADRESS_HEXA_KEYBOARD
	li $t4, OUT_ADRESS_HEXA_KEYBOARD
An_0: 
	li $t5, 0x01 		# row-1 of key matrix
	sb $t5, 0($t3) 		# gan gia tri cua $t5 cho $t3
	lb $a0, 0($t4) 		# lay dia chi thanh ghi $t4 load vao $a0
	bne $a0, 0x11, An_4	# Neu gia tri cua $a0 khac phim 0 thi chuyen qua kiem tra phim 4
	la $a1, pscript1	# Neu la phim 0 thi chay postscript cua phim 0
	j START
An_4:
	li $t5, 0x02 		# row-2 of key matrix
	sb $t5, 0($t3) 		# gan gia tri cua $t5 cho $t3
	lb $a0, 0($t4)		# lay dia chi thanh ghi $t4 load vao $a0
	bne $a0, 0x12, An_8	# Neu gia tri cua $a0 khac phim 4 thi chuyen qua kiem tra phim 8
	la $a1, pscript2	# Neu la phim 4 thi chay postscript cua phim 4
	j START
An_8:
	li $t5, 0X04 		# row-3 of key matrix
	sb $t5, 0($t3)		# gan gia tri cua $t5 cho $t3
	lb $a0, 0($t4)		# lay dia chi thanh ghi $t4 load vao $a0
	bne $a0, 0x14, COME_BACK # khi cac so 0,4,8 khong duoc chon -> quay lai doc tiep
	la $a1, pscript3
	j START			# Neu la phim 8 thi chay postscript cua phim 8
COME_BACK:
	j An_0 			# khi cac so 0,4,8 khong duoc chon -> quay lai doc tiep

# xu li mars bot 
START:
	jal GO
READ_PSCRIPT: 
	addi $t0, $zero, 0 	# luu gia tri rotate
	addi $t1, $zero, 0 	# luu gia tri time
	
READ_ROTATE:
 	add $t7, $a1, $t6 	# dich bit, $t6 la i
	lb $t5, 0($t7)  	# doc cac ki tu cua script
	beq $t5, 0, END 	# Neu $t5 = NULL ket thuc pscript
 	beq $t5, 44, READ_TIME 	# gap ki tu ',' thi chuyen qua doc thoi gian
 	mul $t0, $t0, 10 	# Dich chu so doc duoc sang trai 1 hang
 	addi $t5, $t5, -48 	# So 0 co thu tu 48 trong bang ascii.
 	add $t0, $t0, $t5  	# cong cac chu so lai voi nhau de ra goc
 	addi $t6, $t6, 1 	# tang so bit can dich chuyen len 1, i =i+1
 	j READ_ROTATE 		# quay lai doc tiep den khi gap dau ','
READ_TIME: 			# doc thoi gian chuyen dong.
 	add $a0, $t0, $zero
	jal ROTATE
 	addi $t6, $t6, 1
 	add $t7, $a1, $t6 	# dich bit
	lb $t5, 0($t7) 
	beq $t5, 44, READ_TRACK #gap ki tu ',' thi chuyen qua kiem tra Track
	mul $t1, $t1, 10
 	addi $t5, $t5, -48
 	add $t1, $t1, $t5	# cong cac chu so lai voi nhau de ra thoi gian
 	j READ_TIME 		# quay lai doc tiep den khi gap dau ','
 	
READ_TRACK:
 	addi $v0,$zero,32 	# Giu cho Mars bot chay
 	add $a0, $zero, $t1	# Gia tri thoi gian mars bot chay =$t1
 	addi $t6, $t6, 1 
 	add $t7, $a1, $t6
	lb $t5, 0($t7) 		# doc track
 	addi $t5, $t5, -48
 	beq $t5, $zero, CHECK_UNTRACK # 1=track | 0=untrack
 	jal UNTRACK
	jal TRACK
	j INCREAMENT
	
CHECK_UNTRACK:
	jal UNTRACK
	
INCREAMENT:
	syscall			# chay mars bot voi thong so o tren
 	addi $t6, $t6, 2 	# bo qua dau ';'
 	j READ_PSCRIPT
 
# cac chuong trinh con cua MarsBot lay tu bai giang
#----------------------------------------------------------- 
# GO procedure, to start running 
# param[in]    none 
#-----------------------------------------------------------
GO: 
 	li $at, MOVING 
 	addi $k0, $zero,1 
 	sb $k0, 0($at) 
 	jr $ra
#----------------------------------------------------------- 
# STOP procedure, to stop running
# param[in]    none
#----------------------------------------------------------- 
STOP: 
	li $at, MOVING 
 	sb $zero, 0($at)
 	jr $ra
#----------------------------------------------------------- 
# TRACK procedure, to start drawing line  
# param[in]    none
#-----------------------------------------------------------   
TRACK: 
	li $at, LEAVETRACK 
 	addi $k0, $zero,1 
	sb $k0, 0($at) 
 	jr $ra
#----------------------------------------------------------- 
# UNTRACK procedure, to stop drawing line 
# param[in]    none 
#----------------------------------------------------------- 
UNTRACK:
	li $at, LEAVETRACK 
 	sb $zero, 0($at) 
 	jr $ra
#----------------------------------------------------------- 
# ROTATE procedure, to rotate the robot 
# param[in]    $a0, An angle between 0 and 359 
#                   0 : North (up) 
#                   90: East  (right)
#                  180: South (down) 
#                  270: West  (left) 
#----------------------------------------------------------- 
ROTATE: 
	li $at, HEADING 
 	sw $a0, 0($at) 
 	jr $ra

END:
	jal STOP
	li $v0, 10
	syscall
	


