[org 0x7c00]  ;start at 0x7c00
[bits 16]

section .data ; constants, put under the magic number, at the end 
section .bss  ; variables, similarly at the end
section .text ; code

global main   ;main is global and is our entry point

main:
			;clear the seg registers, to prevent any offset buffer

cli 		;clear interrupts 

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
	cld			; clear the direction flag, which controlls the order of reading
				; string
	sti 		; set interrupt
	push ax
	xor ax,ax
 	int 13h
	pop ax



;*******************************READ SECTORS**************************************


mov al,2 		; read 2 sectors
mov cl,2 		; sectors start from 1, sector 1 is bootloader, so read sector 2
call readDisk




;***************************LOAD BIOS MEMORY VIA E280****************************

	
call loadE820
mov dx,ax		;trial 1: received 6 entries
call printh

;TODO Configure Proper video modes
;call videoMode








;*********************************GO TO SECOND SECTOR****************************


call sect2 		; works if sect2 is read

%include "./printf.asm"
%include "./readDisk.asm"
%include "./printh.asm"
%include "./loadE820.asm"
%include "./videoMode.asm"

%include "./gdt.asm"



times 510 - ($-$$) db 0	;padding
dw 0xaa55				;Magic number





;*******************************ENABLING A20 LINE*********************************

;sector 2  

sect2:
	call EnableA20

	mov si, MESSAGE
	call printf

	;call checklm

	mov si,DISKSUCCESSMSG
	call printf

	call keyb



;*******************************ENTRY TO PROTECTED MODE**************************
call videoMode
call enterProtected


;*******************************TEST CODE********************************


call testvideo


	mov si,DISKSUCCESSMSG
	call printf

jmp $



%include "./TestA20.asm"
%include "./EnableA20.asm"
%include "./checklm.asm"
%include "./enterProtected.asm"


MESSAGE db "Hello, World!",0x0a,0x0d,0
DISKSUCCESSMSG db "Welcome to my first OS!",0ah,0dh,0



times 512-($-sect2) db 0

sect3:

%include "./testvideo.asm"
keyb:
		mov ah,00h
		int 16h
		cmp ah,0
		je keyb
		ret