
;AH 	02h
;AL 	Sectors To Read Count
;CH 	Cylinder
;CL 	Sector <passed as arguments>
;DH 	Head
;DL 	Drive
;ES:BX 	Buffer Address Pointer


;Results 
;CF 	Set On Error, Clear If No Error
;AH 	Return Code
;AL 	Actual Sectors Read Count 
;*****************************************************

;AH 	42h = function number for extended read
;DL 	drive index (e.g. 1st HDD = 80h)
;DS:SI 	segment:offset pointer to the DAP, see below
;DAP : Disk Address Packet offset range 	size 	description
;00h 	1 byte 	size of DAP (set this to 10h)
;01h 	1 byte 	unused, should be zero
;02h..03h 	2 bytes 	number of sectors to be read, (some Phoenix BIOSes are limited to a maximum of 127 sectors)
;04h..07h 	4 bytes 	segment:offset pointer to the memory buffer to which sectors will be transferred (note that x86 is little-endian: if declaring the segment and offset separately, the offset must be declared before the segment)
;08h..0Fh 	8 bytes 	absolute number of the start of the sectors to be read (1st sector of drive has number 0) using logical block addressing. 

;*********************************************************
readDisk:
;
; pusha
; mov ah,2
; mov dl,00h ;change to 0 if you want to boot from iso (floppy) [pen/flash drive emulates a floppy] 
;	    	;may work for CD as well IDK
; mov ch,0
; mov dh,0
; 
; 
; mov bx,0
; 
; mov es,bx
; push bx
; mov bx,7c00h+512;7e00 ;start offset to read sectors
; int 0x13
; pop bx
; 
; jc fail
;
; cmp al,2
; jne fail
; popa
; ret
;	

;reset disk state

	mov [drive_number],dl

	;reset state
	push ax
	xor ax,ax

 	int 13h
	jc fail
	pop ax

	pusha
	push ds
	push si 

	mov word [DAP_START_SECTOR] , cx
	mov word [DAP_NUM_SECTORS] , ax
	mov word [DAP_OFFSET], di
	mov word [DAP_SEGMENT], es
	xor ax,ax
	mov ds, ax
	mov si, DAP
	
	;mov dl, 0x00 
	;0x80 for hard drive
	;0x00 for first floppy 
	;rather than forcing dl to a value, use the one provided by bios
	mov ah, 0x42
	int 13h
	jc fail

	pop si
	pop ds
	popa
	ret
align 4
DAP:
	DAP_SIZE: 			db 0x10
	DAP_UNUSED: 		db 0x00
	DAP_NUM_SECTORS: 	dw 0x00
	DAP_PTR_TO_SECTOR:	
		DAP_OFFSET: 	dw 0x00
		DAP_SEGMENT:	dw 0x00

	DAP_START_SECTOR: 	dq 0x00

fail:
 mov si,DISKFAILMSG
 call printf
 ;mov dx,ax
 ;call printh
 jmp $
DISKFAILMSG db "disk read ERROR",0
