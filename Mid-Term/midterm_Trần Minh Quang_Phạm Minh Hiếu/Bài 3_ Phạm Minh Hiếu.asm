.data
# Noi dung input
Message: .asciiz "Nhap so nguyen tu 0 den 999 999 999:"
# Doc so
Message1: .asciiz "mot "
Message2: .asciiz "hai "
Message3 : .asciiz "ba "
Message4: .asciiz "bon "
Message5: .asciiz "nam "
Message6: .asciiz "sau "
Message7: .asciiz "bay "
Message8: .asciiz "tam "
Message9: .asciiz "chin "
Message0: .asciiz "khong "
Message_linh: .asciiz "linh "
Message_muoi: .asciiz "muoi "

Mess_ch: .asciiz "muoi "
Mess_tr: .asciiz "tram "
Mess_trieu: .asciiz "trieu "
Mess_nghin: .asciiz "nghin "

Mess_er1: "Du lieu nhap vao khong the doc duoc. Moi ban nhap so nguyen tu 0 den 999 999 999"
Mess_er2: "Ban chua nhap du lieu.\nHay nhap mot so nguyen"
Mess_er3: "Ngoai pham vi tinh toan.\nHay nhap mot so nguyen lon hon 0"
Mess_er4: "Ngoai pham vi tinh toan.\nHay nhap mot so nguyen nho hon 999 999 999"

.text
#########################################################################################
# Y nghia cac thanh ghi

# $s0: Luu so n nhap vao, luu du trong qua trinh tach lop
# $s2: Luu thuong trong trong qua trinh tach lop
# $t6: Giá tri cua chu so se duoc in
# $t0: danh dau lop dang duoc doc
# $t3: danh dau viec gap chu so co nghia
# $t1: luu ket qua so sanh
# $t7: Luu case chu so tuong ung

# THUAT TOAN
# Tach lop trieu
#	Chia so dau vao cho 1 000 000. th??ng => lop Trieu, du => Lop nghin va lop don vi
#	Kiem tra chu so co nghia
#	In lop Trieu
# Tach lop Nghin
#	Chia du thu duoc cho 1 000. thuong => lop nghin, du =>  lop don vi
#	Kiem tra chu so co nghia
#	In lop Nghin
# Kiem tra chu so co nghia
#	Neu bien danh dau tim duoc chu so co nghia luu o $t3 =0 thì kiem tra chu so co nghia
#	Chia lop dau vao cho 100. Neu thuong thu duoc bang 0 => in tu hàng chuc
#	Chia lop dau vào cho 10. Neu thuong thu duoc bang 0 => chi in hàng don vi.
# In lop don vi
# Thuat toan in:
#	Tach hang: Chia gia tr? cua lop cho 100 thuong => hang tram,
#		   roi lay du thu duoc chia cho 10, thuong => hang chuc, du => hang don vi
#	In tung hang, moi lan in 1 chu so thì goi case tuong ung
#	
##################################################################################
main:	
# Input so n luu vao thanh ghi $s0
	li $v0, 51		
	la $a0, Message
	syscall 
#Check loi
	beq $a1, -1, er1	# Neu nhap sai kieu du lieu, in thong bao và quay lai man hinh nhap so
	beq $a1, -2, done	# An cancel thi thoat chuong trinh
	beq $a1, -3, er2	# Neu khong nhap input, in thong bao và quay lai man hinh nhap so
	
 		
  	bltz $a0, er3		#Neu so nhap vao <0, in thong bao và quay lai man hinh nhap so
  
  	li $t1,999999999
  	slt $t0,$t1,$a0
  	bne $t0,$zero,er4  	#Neu so nhap vao >999 999 999, in thong bao và quay lai man hinh nhap so
	
	
	add $s0, $0, $a0	# n=$s0
	beq $s0, $0, khong	# Neu so nhap vao bang 0 thi in ra man hinh
	j Doc_lop_trieu
done:
	li $v0, 10
        syscall
##################################################################
#Truong hop dau vao bang 0 truc tiep in ra man hinh
khong:
	li $v0, 4
	la $a0, Message0
	syscall
#################################################################
# thuat toan tach lop
# Chia n cho 1 000 000, Thuong luu vao s2, Du luu vao thanh ghi $s0, $s0 = n mod 1 000 000
# doc ket qua phan thuong (lop trieu)
# Chia n = $s0 cho 1000, Thuong luu vao s2 , Du luu vao thanh ghi $s0, $s0 = n mod 1 000
# doc ket qua phan thuong (lop nghin)
# doc ket qua thanh ghi $s0 (lop don vi)
#################################################################
Doc_lop_trieu:
	li $t0, 1			# Danh dau lop trieu dang xu ly
	div $s2, $s0, 1000000		# lay n/1 000 000, thuong luu vao $s2
	beq $s2,$zero, Doc_lop_Nghin	# Neu khong co lop trieu chuyen sang tach lop nghin
	mfhi $s0			# du luu o thanh ghi hi gán vào $s0
	j check				# kiem tra chu so co nghia
	
In_trieu:		
	li $v0, 4			#in chu trieu
	la $a0, Mess_trieu
	syscall
	
Doc_lop_Nghin:
	li $t0, 2			# Danh dau lop nghin dang xu ly
	div $s2, $s0, 1000		# lay n/1 000, thuong luu vao $s2
	beq $s2,$zero, Doc_lop_Donvi	# Neu khong co lop nghin chuyen sang tach lop don vi
	mfhi $s0			# du luu o thanh ghi hi gán vào $s0
	j check				# kiem tra chu so co nghia
	
In_nghin:	
	li $v0, 4			# in chu nghin
	la $a0, Mess_nghin
	syscall
	
Doc_lop_Donvi:
	li $t0, 3			# Danh dau lop don vi dang xu ly
	beq $s0, $0, done
	add $s2, $s0, $0		# Chuyen lop don vi luu o $s0 vào $s2 de xu ly
	j check				# kiem tra chu so co nghia

#############################################
# Ham kiem tra chu so co nghia
check:
	beq $t3, 1, In_tram		# $t3 = 0 => chua tung in, $t3=1 => in binh thuong khong phai kiem tra chu so co nghia
	div $t1, $s2, 10		# lay $s2 chia 10, thuong luu vao $t1
	beq $t1,$zero, In_donvi		# Neu $t1 = 0 lop co 2 chu so 0 o dau => doc hang don vi
	div $t1, $s2, 100		# lay $s2 chia 100, thuong luu vao $t1
	beq $t1,$zero, In_chuc		# Neu $t1 = 0 lop co co hang tram = 0 => doc hang chuc
	j In_tram			# Bat dau doc lop hien tai
	
#############################################
# In hang tram, hang chuc, hang don vi

In_tram:
	div $t6, $s2, 100		# lay n/100, thuong luu vao $t6
	mfhi $s2			# du luu o thanh ghi hi gán vào $s2
	jal case_0			# in chu so hang tram
	nop
 	li $v0, 4			# in chu tram
	la $a0, Mess_tr
	syscall
	beq $s2, $0, Back_doc_lop	# n?u lop chi co chu hang tram thi doc lop tiep theo

In_chuc:
	div $t6, $s2, 10		# lay n/100, thuong luu vao $t6
	mfhi $s2			# du luu o thanh ghi hi gán vào $s2	
	beq $t6, $0, in_linh		# neu hang chuc bang 0 => in chu "linh"
	li $t1, 1 
	beq $t6, $t1 , in_muoi		# neu hang chuc bang 1 => in chu "muoi"
	jal case_2			# in chu so hang chuc 
	nop
 	li $v0, 4			# in chu muoi (o hang chuc)
	la $a0, Mess_ch
	syscall
	
In_donvi:
	add $t6, $s2, $0		# in hang don vi luu o $s2
	beq $t6,$zero, Back_doc_lop	# neu hang don vi = 0 => in ten lop hoac ket thuc chuong trinh
	mfhi $s2			# du luu o thanh ghi hi gán vào $s2
	
	jal case_0			# in chu so hang don vi
	nop
Back_doc_lop:
	li $t3,1			# kiem tra da in chu so nào ra man hinh chua
	beq $t0,1, In_trieu		# Truong hop cac chu so dang doc o lop trieu => in ten lop
	beq $t0,2, In_nghin		# Truong hop cac chu so dang doc o lop nghin => in ten lop
	beq $t0,3, done			# Truong hop cac chu so dang doc o lop don vi => ket thuc chuong trinh
in_linh:
	li $v0, 4			# in chu linh
	la $a0, Message_linh
	syscall
	j In_donvi
	
in_muoi:
	li $v0, 4			# in chu muoi
	la $a0, Message_muoi
	syscall
	j In_donvi	
#################################################################
## case doc chu tuong ung voi so
#################################################################
case_0: 
	bne $t6, $0, case_1
	li $v0, 4
	la $a0, Message0
	syscall
	j break_case
case_1:	
	addi $t7, $0, 1
	bne $t6, $t7, case_2
	li $v0, 4
	la $a0, Message1
	syscall
	j break_case
case_2: 
	addi $t7, $0, 2
	bne $t6, $t7, case_3
	li $v0, 4
	la $a0, Message2
	syscall
	j break_case
case_3: 
	addi $t7, $0, 3
	bne $t6, $t7, case_4
	li $v0, 4
	la $a0, Message3
	syscall
	j break_case
case_4: 
	addi $t7, $0, 4
	bne $t6, $t7, case_5
	li $v0, 4
	la $a0, Message4
	syscall
	j break_case
case_5: 
	addi $t7, $0, 5
	bne $t6, $t7, case_6
	li $v0, 4
	la $a0, Message5
	syscall
	j break_case
case_6: 
	addi $t7, $0, 6
	bne $t6, $t7, case_7
	li $v0, 4
	la $a0, Message6
	syscall
	j break_case
case_7: 
	addi $t7, $0, 7
	bne $t6, $t7, case_8
	li $v0, 4
	la $a0, Message7
	syscall
	j break_case
case_8: 
	addi $t7, $0, 8
	bne $t6, $t7, case_9
	li $v0, 4
	la $a0, Message8
	syscall
	j break_case
case_9: 
	li $v0, 4
	la $a0, Message9
	syscall
	j break_case
break_case:
	jr $ra
#################################################################
# Thong bao loi
er1:
	li $v0, 55
	la $a0, Mess_er1
	syscall
	j main
er2:
	li $v0, 55
	la $a0, Mess_er2
	syscall
	j main	
er3:
	li $v0, 55
	la $a0, Mess_er3
	syscall
	j main	
er4:
	li $v0, 55
	la $a0, Mess_er4
	syscall
	j main	