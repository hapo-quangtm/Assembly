#------------------------------------------------------------------
# @brief 	Nhap tu ban phim mot cau lenh Mips, kiem tra xem cau lenh ay co dung hay khong
# @param[in]	User input Mips'command
# @param[out]	Correct or Not Conrrect Mips Symtax
#------------------------------------------------------------------
.data
	input: .asciiz "Input a Mips command: "
	continueMessage: .asciiz "Do you want to exit? (0. No / 1. Yes): "
	errMessage: .asciiz "\nSymtax error!\n"
	NF: .asciiz "Cann't found this command form!\n"
	endMess: .asciiz "\nThis command is conrrect\n"
	hopLe1: .asciiz "Opcode: "
	hopLe11: .asciiz "Toan Hang: "
	hopLe2: .asciiz "Conrect\n"
	khongHopLe: .asciiz "Inconrect.\n"
	chuKyMess: .asciiz "Command's cycle: "
	command: .space 100
	opcode: .space 10
	token: .space 15
	number: .space 15
	ident: .space 15
	# Register = 1; Label = 3; Imm = 2; null = 0
	library: .asciiz "or***1111;xor**1111;lui**1201;jr***1001;jal**3002;addi*1121;add**1111;addiu1121;sub**1111;ori**1121;and**1111;andi*1131;beq**1132;bne**1132;j****3002;nop**0001;bgez*1202;bgtz*1202;xori*1131;sll**1131;slt**1111"
	labelGroup: .asciiz "1234567890qwertyuiopasdfghjklmnbvcxzQWERTYUIOPASDFGHJKLZXCVBNM_"
	registersLib: .asciiz "$zero $at   $v0   $v1   $a0   $a1   $a2   $a3   $t0   $t1   $t2   $t3   $t4   $t5   $t6   $t7   $s0   $s1   $s2   $s3   $s4   $s5   $s6   $s7   $t8   $t9   $k0   $k1   $gp   $sp   $fp   $ra	 $0"

.text
#readData
readData: 
  	li $v0, 4 		# print string service
	la $a0, input 		# print InputMessage
	syscall
	li $v0, 8 		# read string service
	la $a0, command 	# store input string in Command
	li $a1, 100 		# max buffer
	syscall
# end readData
main:
	li $t2, 0 		# $t2 = i = 0
readOpcode:
	la $a1, opcode 		# luu cac ki tu doc duoc vao opcode
	add $t3, $a0, $t2 	# truy cap vao dia chi cua Command o ki tu thu t1
	add $t4, $a1, $t2	# truy cap vao dia chi cua Opcode o ki tu thu t1
	lb $t1, 0($t3) 		# lay ki tu Command[i]
	sb $t1, 0($t4)		# luu ki tu vao Opcode[i]
	beq $t1, 32, done 	# gap ki tu ' ' -> luu ki tu nay vao opcode de xu ly
	beq $t1, 0, done 	# ket thuc chuoi command
	addi $t2, $t2, 1	# i = i+1
	j readOpcode
	
#<--xu ly opcode-->
done:
	li $t7,-10		#Moi lenh cach nhau 10 byte nen bat dau tu -10
	la $a2, library		#Dia chi cua library
xuLyOpcode:
	li $t1, 0 # i
	li $t2, 0 # j
	addi $t7,$t7,10 	# buoc nhay = 10 de den vi tri opcode dau tien trong library
	add $t1,$t1,$t7 	# lenh hien tai dang xet
	
	compare:
	add $t3, $a2, $t1 	# t3 tro thanh con tro cua library						//Vi tri cua con tro hien tai trong library
	lb $s0, 0($t3)		# ki tu hien tai
	beq $s0, 0, notFound 	# khong tim thay opcode nao trong library
	beq $s0, '*', check 	# gap ki tu '*' -> check xem opcode co giong nhau tiep ko?.			//'*' = 42
	add $t4, $a1, $t2	# vi tri ki tu dang xet cua lenh duoc nhap
	lb $s1, 0($t4)
	bne $s0,$s1,xuLyOpcode 	# so sanh 2 ki tu. dung thi so sanh tiep, sai thi nhay den phan tu chua khuon danh lenh tiep theo.
	addi $t1,$t1,1 		# i+=1
	addi $t2,$t2,1 		# j+=1
	j compare
	# end compare
	check:
	add $t4, $a1, $t2
	lb $s1, 0($t4)
	bne $s1, 32, check2 	# neu ki tu tiep theo khong phai 'space' => lenh khong hop le. chi co doan dau giong.
	
	checkContinue:
	add $t9,$t9,$t2 	# t9 = luu vi tri de xu ly token trong command
	li $v0, 4
	la $a0, hopLe1 		# Opcode:
	syscall
	la $a0, opcode		# opcode
	syscall
	la $a0, hopLe2		# correct
	syscall
	j readToanHang1
	
	check2: 		# neu ki tu tiep theo khong phai '\n' => lenh khong hop le. chi co doan dau giong.
	bne $s1, 10, notFound										# ASCII \n = 10
	j checkContinue
	
# <!--ket thuc xu ly opcode -->

#<--xu li toan hang-->

#------------------------------------------------------------------
# @brief 	Doc cac toan hang va kiem tra kieu cua cac toan hang do
#------------------------------------------------------------------
readToanHang1:
	# xac dinh kieu toan hang trong library
	# t7 dang chua vi tri khuon dang lenh trong library
	li $t1, 0
	addi $t7, $t7, 5 	# chuyen den vi tri toan hang 1 trong library
	add $t1, $a2, $t7 	# a2 chua dia chi library
	lb $s0, 0($t1)
	addi $s0,$s0,-48 	# chuyen tu char -> int
	li $t8, 0 		# khong co toan hang = 0
	beq $s0, $t8, checkNO				
	li $t8, 1 		# thanh ghi
	beq $s0, $t8, checkReg
	li $t8, 2 		# hang so nguyen
	beq $s0, $t8, checkImm
	li $t8, 3 		# dinh danh
	beq $s0, $t8, checkLabel
	j end
	
readToanHang2:
	# xac dinh kieu toan hang trong library
	# t7 dang chua vi tri khuon dang lenh trong library
	li $t1, 0
	la $a2, library
	addi $t7, $t7, 1 	# chuyen den vi tri toan hang 2 trong library
	add $t1, $a2, $t7 	# a2 chua dia chi library
	lb $s0, 0($t1)
	addi $s0,$s0,-48 	# chuyen tu char -> int
	li $t8, 0 		# khong co toan hang = 0
	beq $s0, $t8, checkNO
	li $t8, 1 		# thanh ghi = 1
	beq $s0, $t8, checkReg
	li $t8, 2 		# hang so nguyen = 2
	beq $s0, $t8, checkImm
	li $t8, 3 		# dinh danh = 3
	beq $s0, $t8, checkLabel
	j end

readToanHang3:
	# xac dinh kieu toan hang trong library
	# t7 dang chua vi tri khuon dang lenh trong library
	li $t1, 0
	la $a2, library
	addi $t7, $t7, 1 	# chuyen den vi tri toan hang 3 trong library
	add $t1, $a2, $t7 	# a2 chua dia chi library
	lb $s0, 0($t1)
	addi $s0,$s0,-48 	# chuyen tu char -> int
	li $t8, 0 		# khong co toan hang = 0
	beq $s0, $t8, checkNO
	li $t8, 1 		# thanh ghi = 1
	beq $s0, $t8, checkReg
	li $t8, 2 		# hang so nguyen = 2
	beq $s0, $t8, checkImm
	li $t8, 3 		# dinh danh = 3
	beq $s0, $t8, checkLabel
	j end

readChuKy:
	# xac dinh kieu toan hang trong library
	# t7 dang chua vi tri khuon dang lenh trong library
	li $t1, 0
	la $a2, library
	addi $t7, $t7, 1 	# chuyen den vi tri chu ky  trong library
	add $t1, $a2, $t7	# a2 chua dia chi library
	lb $s0, 0($t1)
	addi $s0,$s0,-48 	# chuyen tu char -> int
	li $v0, 4
	la $a0, chuKyMess
	syscall
	li $v0,1
	li $a0,0
	add $a0,$s0,$zero
	syscall
	j end

#------------------------------------------------------------------
# @brief 	Kiem tra neu toan hang la kieu thanh ghi
#------------------------------------------------------------------
checkReg:
	la $a0, command		# load address of command to $a0
	la $a1, token 		# load address of Token to $a0 => store register token
	li $t1, 0
	li $t2, -1							
	addi $t1, $t9, 0						
	readToken:
		addi $t1, $t1, 1 		# i
		addi $t2, $t2, 1 		# j
		add $t3, $a0, $t1		# command[i]
		add $t4, $a1, $t2		# token[i]
		lb  $s0, 0($t3)
		add $t9, $zero, $t1 		# vi tri toan hang tiep theo trong command
		beq $s0, 44, readTokenDone 	# gap dau ','
		beq $s0, 0, readTokenDone 	# gap ki tu ket thuc
		sb $s0, 0($t4)
		j readToken
	
	readTokenDone:
		sb $s0, 0($t4) 			# luu them ',' vao de so sanh
		li $t1, -1 			# i
		li $t2, -1 			# j
		li $t4, 0
		li $t5, 0
		add $t2, $t2, $k1
		la $a1, token
		la $a2, registersLib
		j compareToken

compareToken:
	addi $t1,$t1,1
	addi $t2,$t2,1
	add $t4, $a1, $t1
	lb $s0, 0($t4)
	beq $s0, 0, notFound			# neu o vi tri toan trong command la Null thi bao loi
	
	add $t5, $a2, $t2
	lb $s1, 0($t5)
	beq $s1, 0, notFound
	beq $s1, 32, checkLengthToken		# neu gap dau space thi se nhay den checkLengthToken 
	bne $s0,$s1, jump	
	j compareToken
	
	checkLengthToken:
		beq $s0, 10, compareE		#\n
		beq $s0, 44, compareE		#','
		j compareNE
	jump:
		addi $k1,$k1,6
		j readTokenDone
	compareE:
		la $a0, hopLe11 		# opcode hop le
		syscall
		li $v0, 4
		la $a0, token
		syscall
		li $v0, 4
		la $a0, hopLe2
		syscall
		addi $v1, $v1, 1 		# dem so toan hang da doc.
		li $k1, 0 			# reset buoc nhay
		beq $v1, 1, readToanHang2
		beq $v1, 2, readToanHang3
		beq $v1, 3, readChuKy
		j end
	compareNE:
		la $a0, hopLe11			# Toan Hang:
		syscall
		li $v0, 4
		la $a0, token
		syscall
		li $v0, 4
		la $a0,khongHopLe
		syscall
		j notFound

#------------------------------------------------------------------
# @brief 	Kiem tra neu kieu cua toan hang la mot hang so nguyen
#------------------------------------------------------------------
checkImm: 
	la $a0, command
	la $a1, number 				# luu day chu so vao number de so sanh tung chu so co thuoc vao numberGroup hay khong.
	li $t1, 0
	li $t2, -1
	addi $t1, $t9, 0
	readNumber:
		addi $t1, $t1, 1 		# i
		addi $t2, $t2, 1 		# j
		add $t3, $a0, $t1
		add $t4, $a1, $t2
		lb $s0, 0($t3)
		add $t9, $zero, $t1 		# vi tri toan hang tiep theo trong command
		beq $s0, 44, readNumberDone 	# gap dau ','
		beq $s0, 0, readNumberDone 	# gap ki tu ket thuc
		sb $s0, 0($t4)
		j readNumber
	readNumberDone:
		sb $s0, 0($t4) 			# luu them ',' vao de compare
		li $t1, -1 			# i
		li $t4, 0
		la $a1, number
		j compareNumber
compareNumber:
	addi $t1, $t1, 1
	add $t4, $a1, $t1
	lb $s0, 0($t4)
	beq $s0, 0, notFound
	beq $s0, 45, compareNumber 		# bo dau '-'
	beq $s0, 10, compareNumE
	beq $s0, 44, compareNumE
	li $t2, 48				#48 ASCII = 0
	li $t3, 57				#57 ASCII = 9
	slt $t5, $s0, $t2			#compare with 0
	bne $t5, $zero, compareNumNE
	slt $t5, $t3, $s0			#compare with 9
	bne $t5, $zero, compareNumNE
	j compareNumber

	compareNumE:
		la $a0, hopLe11
		syscall
		li $v0, 4
		la $a0, number
		syscall
		li $v0, 4
		la $a0, hopLe2
		syscall
		addi $v1, $v1, 1 		# dem so toan hang da doc.
		li $k1, 0 			# reset buoc nhay
		beq $v1, 1, readToanHang2
		beq $v1, 2, readToanHang3
		beq $v1, 3, readChuKy
		j end
	compareNumNE:	
		la $a0, hopLe11			# Toan Hang:
		syscall
		li $v0, 4
		la $a0, number
		syscall
		li $v0, 4
		la $a0,khongHopLe
		syscall
		j notFound
		
#------------------------------------------------------------------
# @brief 	Kiem tra neu kieu cua toan hang la mot nhan
#------------------------------------------------------------------
checkLabel:
	la $a0, command
	la $a1, ident 				# luu ten thanh ghi vao indent de so sanh
	li $t1, 0
	li $t2, -1
	addi $t1, $t9, 0
	readIndent:
		addi $t1, $t1, 1 		# i
		addi $t2, $t2, 1 		# j
		add $t3, $a0, $t1
		add $t4, $a1, $t2
		lb $s0, 0($t3)
		add $t9, $zero, $t1 		# vi tri toan hang tiep theo trong command
		beq $s0, 44, readIdentDone 	# gap dau ','
		beq $s0, 0, readIdentDone 	# gap ki tu ket thuc
		sb $s0, 0($t4)
		j readIndent
	readIdentDone:
		sb $s0, 0($t4) 			# luu them ',' vao de compare
		loopj:
		li $t1, -1 			# i
		li $t2, -1 			# j
		li $t4, 0
		li $t5, 0
		add $t1, $t1, $k1
		la $a1, ident
		la $a2, labelGroup
		j compareIdent
compareIdent:
	addi $t1,$t1,1
	add $t4, $a1, $t1
	lb $s0, 0($t4)
	beq $s0, 0, notFound
	beq $s0, 10, compareIdentE
	beq $s0, 44, compareIdentE
	loop:
	addi $t2,$t2,1
	add $t5, $a2, $t2
	lb $s1, 0($t5)
	beq $s1, 0, compareIdentNE
	beq $s0, $s1, jumpIdent 		# so sanh ki tu tiep theo trong ident
	j loop 					# tiep tuc so sanh ki tu tiep theo trong labelGroup
	
	jumpIdent:
		addi $k1,$k1,1
		j loopj
		
	compareIdentE:
		la $a0, hopLe11 		# opcode hop le
		syscall
		li $v0, 4
		la $a0, ident
		syscall
		li $v0, 4
		la $a0, hopLe2
		syscall
		addi $v1, $v1, 1 		# dem so toan hang da doc.
		li $k1, 0 			# reset buoc nhay
		beq $v1, 1, readToanHang2
		beq $v1, 2, readToanHang3
		beq $v1, 3, readChuKy
		j end
	compareIdentNE:	
		la $a0, hopLe11			# Toan Hang:
		syscall
		li $v0, 4
		la $a0, ident
		syscall
		li $v0, 4
		la $a0,khongHopLe
		syscall
		j notFound

#------------------------------------------------------------------
# @brief 	Kiem tra neu nguoi dung bo trong vi tri cua toan hang (NULL)
#------------------------------------------------------------------
checkNO:					
	la $a0, command
	li $t1, 0
	li $t2, 0
	addi $t1, $t9, 0
	add $t2, $a0, $t1
	lb $s0, 0($t2)
	addi $v1, $v1, 1 			# dem so toan hang da doc.
	li $k1, 0 				# reset buoc nhay
	beq $v1, 1, readToanHang2
	beq $v1, 2, readToanHang3
	beq $v1, 3, readChuKy

continue: 					# lap lai chuong trinh.
	li $v0, 4
	la $a0, continueMessage
	syscall
	li $v0, 5
	syscall
	add $t0, $v0, $zero
	beq $t0, $zero, resetAll
	j TheEnd
resetAll:
	li $v0, 0 
	li $v1, 0
	li $a0, 0 
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
	li $k0, 0
	li $k1, 0
	j readData
notFound:
	li $v0, 4
	la $a0, NF
	syscall
	j continue
error:
	li $v0, 4
	la $a0, errMessage
	syscall
	j continue
end:
	li $v0, 4
	la $a0, endMess
	syscall
	j continue
TheEnd:
