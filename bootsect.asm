[org 0x7c00]  ;start at 0x7c00
[bits 16]

;section .data ; constants, put under the magic number, at the end 
;section .bss  ; variables, similarly at the end
;section .text ; code

global main   ;main is global and is our entry point

main:






			;clear the seg registers, to prevent any offset buffer

		;clear interrupts 

jmp ZeroSeg  ;try jmp 0x0000:ZeroSeg
dw 0x00			;padding
%include "./pbp.asm"
ZeroSeg:
	cli 
	xor ax,ax  	; clear ax
	
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	mov ss,ax	;even after cli, apparently some processors don't like any code after mov ss...
				;but before mov sp...

	mov sp, 0x7c00		;0x7c00 = main?
	cld			; clear the direction flag, which controlls the order of reading
				; string
	sti 		; set interrupt





;*******************************READ SECTORS**************************************


;mov al,2		; read 2 sectors
;mov cl,2 		; sectors start from 1, sector 1 is bootloader, so read sector 2

;extended read ah=42h

mov ax,0x07e0
mov es,ax
xor di,di


mov ax, 0x0002 	; number of sectors read
mov cx, 0x0001	;absolute number (not addr of start sector (sector 0 is bootloader here))

call readDisk


;***************************LOAD BIOS MEMORY VIA E280****************************	
call loadE820
mov dx,ax		;trial 1: received 6 entries
call printh

;TODO Configure Proper video modes

;*********************************GO TO SECOND SECTOR****************************


jmp sect2 		; works if sect2 is read

align 4
drive_number db 00

%include "./printf.asm"
%include "./readDisk.asm"
%include "./printh.asm"
%include "./loadE820.asm"

times 510 - ($-$$) db 0	;padding
dw 0xaa55				;Magic number












;*******************************ENABLING A20 LINE*********************************

;sector 2  

sect2:
	call EnableA20

	mov si, MESSAGE
	call printf

	;mov si,DISKSUCCESSMSG
	;call printf

;*******************************ENTRY TO PROTECTED MODE**************************
	call checklm
	call enterProtected
	jmp $

%include "./TestA20.asm"
%include "./EnableA20.asm"
%include "./checklm.asm"
%include "./enterProtected.asm"


MESSAGE db "In sector 2",0x0a,0x0d,0
DISKSUCCESSMSG db "Exiting real mode, bye!",0ah,0dh,0



times 512-($-sect2) db 0











sect3:

keyb:
		mov ah,00h
		int 16h
		cmp ah,0
		je keyb
		ret

%include "./gdt.asm"


;
times 512-($-sect3) db 0