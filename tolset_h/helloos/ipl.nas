; hello-os
; TAB = 4

CYLS	EQU		10

		ORG		0x7c00			; このプログラムの読み込み先

; 以下はFAT12フォーマットフロッピーディスクのための記述

		JMP		entry
		DB		0x90
		DB		"HELLOIPL"		; ブートセクタの名前を自由に書いてよい
		DW		512				; 1セクタの大きさ（512で固定）
		DB		1				; クラスタの大きさ（1で固定）
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

; プログラム本体

entry:
		MOV		AX,0			; レジスタの初期化
		MOV		SS,AX
		MOV 	SP,0x7c00
		MOV		DS,AX

; ディスクを読む

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; シリンダ0
		MOV		DH,0			; ヘッド0
		MOV		CL,2			; セクタ2

readloop:
		MOV		SI,0			; 失敗回数用のカウンタ

retry:
		MOV		AH,0x02
		MOV		AL,1
		MOV		BX,0
		MOV		DL,0x00
		INT		0x13
		JNC		next			; エラーが起きなければnextへ
		ADD		SI,1			; エラー回数加算
		CMP		SI,5
		JAE		error
		MOV		AH,0x00
		MOV		DL,0x00
		INT		0x13
		JMP		retry

next:
		MOV		AX,ES			; アドレスを0x0200進める
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

; 読み込みが終わったらmorios.sysを実行

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
		DB		0x0a, 0x0a		; 改行ふたつ
		DB		"load error"
		DB		0x0a
		DB		0

		RESB 	0x7dfe-$

		DB		0x55, 0xaa
