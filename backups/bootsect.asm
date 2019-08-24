[org 0x7c00]
[bits 16]
section .data ; constants, put under the magic number, at the end 
section .bss  ; variables, similarly at the end
section .text ; code
global main   ;main is global and is our entry point
main:
;clear the seg registers, to prevent any offset buffer
cli ;clear interrupts 
jmp 0x0000:ZeroSeg
ZeroSeg:
	xor ax,ax  	; clear ax
	mov ss,ax
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	
	;cleared the seg

	mov sp,main
	cld		; clear the direction flag, which controlls the order of reading
			; string
	sti 		; set interrupt
	push ax
	xor ax,ax
 	int 13h
	pop ax

;mov si,MESSAGE		; testing the printf subroutine
;call printf

mov al,1 		; read 1 sector
mov cl,2 		; sectors start from 1, sector 1 is bootloader, so read sector 2
call readDisk

call sect2 		; works if sect2 is read

call TestA20		;Testing if a20 line is enabled

;mov dx,[0x7dfe] 	; 0x7c00+512
;call printh		; testing the printh subroutine
jmp $

%include "./printf.asm"
%include "./readDisk.asm"
%include "./printh.asm"
%include "./TestA20.asm"

MESSAGE db "Hello, World!",0x0a,0x0d,0
DISKSUCCESSMSG db "Welcome to my first OS!",0ah,0dh,0

times 510 - ($-$$) db 0
dw 0xaa55


;sector 2 code
sect2:
	mov ax,0013h
	int 0x10
	push 0a000h
	pop es
	mov cx,0
	scrfill:
		mov [es:di],dword 3
		inc di
		loop scrfill
	keyb:
		mov ah,00h
		int 16h
		cmp ah,0
		je keyb
	mov ax,0x0003
	int 0x10
	mov si,DISKSUCCESSMSG
	call printf
	ret
times 512-($-sect2) db 0
