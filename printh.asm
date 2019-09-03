printh:
;to print a 16-bit address
;let dx be the argument
	pusha
	xor ax,ax
	mov cl,10h
	mov si,HEX_PATTERN
subp:	
	sub cl,4                ;12 8 4 0	
	inc ax                  ; 1 2 3 4
	mov bx,dx		;0xdead
	shr bx,cl 		;0x000d:12 0x00de:8 0x0dea:4 0xdead:0
	and bx,0x000f		;0d 0e 0a 0d
	mov bx,[HEX_TABLE+bx]	;d  e   a  d
	
	push dx 		;push hex
	mov dx,bx		;move char to dx
	
	mov bx,HEX_PATTERN+1	;0x
	add bx,ax		;* * * *
	mov [bx],dl		;d e a d
	pop dx
	
	cmp ax,4		;
	jne subp
	call printf
	popa 
	ret
HEX_PATTERN: db "0x****",0ah,0dh,0
HEX_TABLE: db "0123456789abcdef"

	
