enterProtected:
	
	;cli




	xor ax,ax
	mov ds,ax
	
	


	lgdt [GDT_DESC]

	mov eax, cr0
	or eax, 1
	mov cr0, eax



	jmp 08h:clear_pipe ;fix CS and clear all garbage instructions
	
	[BITS 32]
	clear_pipe:
		;clear all garbage instructions
		mov ax, 10h  ;data segment, not codeseg 
		mov ds, ax
		mov ss, ax
	
		;segment part set 
		;set offset part
	
		mov esp, 090000h        ;safe offset for stack to exist 
		mov byte [0B8000h], 'P'
		mov byte [0B8001h], 1Bh

	stp:	
		cli
		hlt
	