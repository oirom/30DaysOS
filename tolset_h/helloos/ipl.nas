; hello-os
; TAB = 4

CYLS	EQU		10

		ORG		0x7c00			; ���̃v���O�����̓ǂݍ��ݐ�

; �ȉ���FAT12�t�H�[�}�b�g�t���b�s�[�f�B�X�N�̂��߂̋L�q

		JMP		entry
		DB		0x90
		DB		"HELLOIPL"		; �u�[�g�Z�N�^�̖��O�����R�ɏ����Ă悢
		DW		512				; 1�Z�N�^�̑傫���i512�ŌŒ�j
		DB		1				; �N���X�^�̑傫���i1�ŌŒ�j
		DW		1
		DB		2
		DW		224
		DW		2880
		DB		0xf0
		DW		9
		DW		18
		DW		2
		DD		0
		DD		2880
		DB		0, 0, 0x29
		DD		0xffffffff
		DB		"HELLO-OS   "
		DB		"FAT12   "
		RESB	18

; �v���O�����{��

entry:
		MOV		AX,0			; ���W�X�^�̏�����
		MOV		SS,AX
		MOV 	SP,0x7c00
		MOV		DS,AX

; �f�B�X�N��ǂ�

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; �V�����_0
		MOV		DH,0			; �w�b�h0
		MOV		CL,2			; �Z�N�^2

readloop:
		MOV		SI,0			; ���s�񐔗p�̃J�E���^

retry:
		MOV		AH,0x02
		MOV		AL,1
		MOV		BX,0
		MOV		DL,0x00
		INT		0x13
		JNC		next			; �G���[���N���Ȃ����next��
		ADD		SI,1			; �G���[�񐔉��Z
		CMP		SI,5
		JAE		error
		MOV		AH,0x00
		MOV		DL,0x00
		INT		0x13
		JMP		retry

next:
		MOV		AX,ES			; �A�h���X��0x0200�i�߂�
		ADD		AX,0x0020
		MOV		ES,AX
		ADD		CL,1
		CMP		CL,18
		JBE		readloop
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop

; �ǂݍ��݂��I�������morios.sys�����s

		MOV		[0x0ff0],CH
		JMP		0xc200

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e
		MOV		BX,15
		INT		0x10
		JMP		putloop
fin:
		HLT
		JMP		fin
msg:
		DB		0x0a, 0x0a		; ���s�ӂ���
		DB		"load error"
		DB		0x0a
		DB		0

		RESB 	0x7dfe-$

		DB		0x55, 0xaa
