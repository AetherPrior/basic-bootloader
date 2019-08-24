
;ALT+SHIFT  for multi cursor IN SUBL AND VSCODE
testvideo:
	push 0a000h
	pop es
	mov cx,0x00ff

	set_palette:
		mov al,cl
		mov dx,0x3c8
		out dx,al
		mov dx,0x3c9
		out dx,al
		out dx,al
		out dx,al
		loop set_palette

		mov bx, 320
		
	XOR_pattern:
	;display an XOR pattern to show video mode capabilities
		xor dx,dx
		mov ax,di
		div bx

		xor ax,dx
		mul cx
		div bx

		mov [es:di],ax
		inc di
		cmp di, 0xfa00
		jne XOR_pattern
		push 0x0a000
		pop es
		inc cx
		xor di,di
		jmp XOR_pattern
	call keyb
	ret
	
