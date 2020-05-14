;[org 0x7c00]  ;start at 0x7c00
section .text
[bits 16]

mmap_entries equ 0x8000
[extern mainKernel]

global start   ;start is global and is our entry point

start:
jmp ZeroSeg  				;try jmp 0x0000:ZeroSeg
dw 0x00						;padding

OEMname:            db      "MYBOOT  "
    bytesPerSector:     dw       512
    sectPerCluster:     db       1
    reservedSectors:    dw       1
    numFAT:             db       2
    numRootDirEntries:  dw       240
    numSectors:         dw       5760
    mediaType:          db       0xf0
    numFATsectors:      dw       9
    sectorsPerTrack:    dw       36
    numHeads:           dw       2
    numHiddenSectors:   dd       0
    numSectorsHuge:     dd       0
    driveNum:           db       0
    reserved:           db       0x00
    signature:          db       0x29
    volumeID:           dd       0x54428E71
    volumeLabel:        db      "NO NAME    "
    fileSysType:        db      "FAT12   "


ZeroSeg:

	cli			;clear interrupts 
	xor ax,ax  	; clear ax
	
	mov ds,ax	;clear the seg registers, to prevent any offset buffer
	mov es,ax 
	mov fs,ax
	mov gs,ax
	mov ss,ax	;even after cli, apparently some processors don't like any code after mov ss...
				;but before mov sp...

	mov sp, 0x7c00		;0x7c00 = Start address
	cld			; clear the direction flag, which controlls the order of reading
				; string
	sti 		; set interrupt


	;extended read ah=42h
	
	mov ax,0x07e0
	mov es,ax
	xor di,di
	
	
	mov ax, 0x0010 	; number of sectors read
	mov cx, 0x0001	;absolute number (not addr of start sector (sector 0 is bootloader here))
	
	call readDisk
	
	call loadE820
	
	;mov dx,ax		
	;call printh
	
	;TODO Configure Proper video modes
	
	jmp sect2 		; works if sect2 is read


;********************************Subroutines***************************************	
printf:
	pusha
	strLoop:
	 lodsb
	 or al,al
	 jz end__
	 mov ah,0eh
	 int 10h
	 jmp strLoop
	end__:
	 popa
	 ret

;***********************************readDisk**************************************
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
	pusha
	mov ah, 0x41          ; Int 13h/AH=41h: Check if extensions present
    mov bx, 0x55aa
    int 0x13
    jc  ext_drv_none1      ; CF set - no extensions available for drive
    cmp bx, 0xaa55        ; Is BX 0xaa55?
    jnz ext_none          ;     If not, int 13h extensions not supported
                          ;     by BIOS at all.
	mov [drive_number],dl
	;reset state
	xor ax,ax

 	int 13h
	jc fail

	popa

	pusha

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

	popa
	ret
	ext_drv_none1:
		mov si, DRVFAIL
		call printf
		jmp $
	ext_none:
		mov si, NOSUPPORT
		call printf
		jmp $
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

;*******************************printh******************************************

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
	mov bx,dx				;0xdead
	shr bx,cl 				;0x000d:12 0x00de:8 0x0dea:4 0xdead:0
	and bx,0x000f			;0d 0e 0a 0d
	mov bx,[HEX_TABLE+bx]	;d  e   a  d
	
	push dx 				;push hex
	mov dx,bx				;move char to dx
	
	mov bx,HEX_PATTERN+1	;0x
	add bx,ax				;* * * *
	mov [bx],dl				;d e a d
	pop dx
	
	cmp ax,4		
	jne subp
	call printf
	popa 
	ret

;-4	size
;0	base_addr_low
;4	base_addr_high
;8	length_low
;12	length_high
;16	type


;**********************************************E820*********************************************8


loadE820:
	pusha
	;most of this code is from the osdev wiki (Detecting Memory x86)

	mov di,0x8004 			;entries stored at 0x8000, without moving di the code can be stuck at int 0x15
	xor ebx, ebx			; ebx must be 0 to start
	xor bp, bp				; keep an entry count in bp
	mov edx, 0x0534D4150	; Place "SMAP" into edx
	mov eax, 0xe820
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24					; ask for 24 bytes
	int 0x15
	jc short noE820			; carry set on first call means "unsupported function"
	mov edx, 0x0534D4150	; Some BIOSes apparently trash this register?
	cmp eax, edx			; on success, eax must have been reset to "SMAP"
	jne short e820Fail
	test ebx, ebx			; ebx = 0 implies list is only 1 entry long (worthless)
	je short  e820Fail
	jmp short loadMap

e820Load:
	mov eax, 0xe820				; eax, ecx get trashed on every int 0x15 call
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24					; ask for 24 bytes again
	int 0x15 					; does NOT increment di
	jc short e820Done			; carry set means "end of list already reached"
	mov edx, 0x0534D4150		; repair potentially trashed register

loadMap:
	jcxz skipEnt			;skip zero length entries
	cmp cl, 20				; got a 24 byte ACPI 3.X response?
	jbe short noText
	test byte [es:di + 20], 1	; if so: is the "ignore this data" bit clear?
	je short  skipEnt

noText:
	mov ecx, [es:di + 8]	; get lower uint32_t of memory region length
	or ecx, [es:di + 12]	; "or" it with upper uint32_t to test for zero
	jz  skipEnt				; if length uint64_t is 0, skip entry
	inc bp					; got a good entry: ++count, move to next storage spot
	add di, 24
	


skipEnt:					;routine to skip entries
	test ebx, ebx			; if ebx resets to 0, list is complete
	jne short e820Load

e820Done:
	mov [mmap_entries], bp	; store the entry count
	clc						; there is "jc" on end of list to this point, so the carry must be cleared
	popa
	mov ax,[mmap_entries]   ;get number of entries to ax
	ret

noE820:
e820Fail:
	mov si, E820_ERR_MESSAGE
	call printf
	stc
	popa
	ret




DISKFAILMSG db "disk read ERROR",0

align 4
drive_number db 00

HEX_PATTERN: db "0x****",0ah,0dh,0
HEX_TABLE: db "0123456789abcdef"

E820_ERR_MESSAGE db "E820 IS NOT SUPPORTED",0ah,0dh,0
DRVFAIL db "drive no sup",0
NOSUPPORT db "NO SUPPORT",0
times 510 - ($-$$) db 0	;padding
dw 0xaa55				;Magic number












;*******************************ENABLING A20 LINE*********************************

;sector 2  

sect2:
	call EnableA20

	mov si, MESSAGE
	call printf

	;call checklm
	jmp enterProtected

	


;************************************************TestA20 code**************************************
;8086 used segments to read 20bits of an address as it's 16bit
;the address bus had 20 lines a0 to a19
;segment:offset
;segment -> 0000-f000
;offset  -> 0000-ffff
;addr = segment*16+offset
;eg: seg=f000 and off=ffff
;addr = f0000+ffff = fffff
;eg2 f800*0x10+8000h = 100000h; this requires the 21st bit
;so the processor just truncates the 1 to get address 0
;devs used to use this feature
;so when the 80286 was made, it needed the backwards compatibility
;so the a20 line needed to be enabled
;the bios sometimes enables it but sometimes doesn't

TestA20:


						;if the segmented location of a constant memory location is equal to the unsegmented location, 
						;(ffff:aa55 == 0000:aa55)
						;then a20 is disabled as it's wrapped
						;else it's fine
						;we'll choose our magic number, stored in 0x7dfe

pusha					;push all registers

mov ax,[0x7dfe]			;move [0x7dfe] which is aa55
mov cx,ax				;copy to cx register



							;call printh	;debugging

							;0xffff0+offset = 0x107dfe
							;offset = 0x107dfe-0xffff0 = 0x7e0e
							;if A20 is disabled then we get the location as 7dfe
							;but if enabled we don't

							;call SegTest 	;debugging
							;mov ax,0x2400	;debugging. part of enabling the a20 line
							;int 15h	;debugging. part of enabling the a20 line



SegTest:
push bx		;save previous value
xor bx,bx	;zero the bx register
sub bx,1	;bx = 0xffff
mov es,bx	;es = 0xffff
pop bx		;get the previous saved value

mov bx,0x7e0e	;basically sending the offset to check
				;es:bx = 0xffff0+0x7e0e = 0x107dfe
				;if a20 is disabled we get 0x7dfe, which has the value 0xaa55

mov dx,[es:bx]	;if aa55 then there's a wrap, otherwise no
sub dx,cx		;dx - cx . cx has [0x7dfe] which is aa55
				;zero flag will be set if zero

popa
ret


;************************************************EnableA20********************************************
EnableA20:


call TestA20
jnz EndA20		;Is it already enabled? if so go to end  
				;the TestA20 routine sets the zero flag if A20 is disabled (after subtracting 0x7dfe)

;DO IT THE FAST WAY



in al,0x92
or al,2
out 0x92,al

call TestA20 ;Returns 0 if A20 is still disabled 
jnz EndA20



;BIOS INTERRUPT METHOD

mov cx,5 	;counter
BIOS:
mov ax,0x2401	;set ax to value
int 0x15	

call TestA20	
jnz EndA20

loop BIOS	;try 5 times



;Keyboard Controller method

cli		;don't let any interrupts happen

call Wait_8042_command
mov al,0xAD		;command: disable keyboard
out 0x64,al		;output: port

call Wait_8042_command
mov al,0xd0		;command: read
out 0x64,al		;output: port

call Wait_8042_data
in al,0x60		;read the data
push ax			;store data

call Wait_8042_command
mov al,0xD1		;command: write
out 0x64,al		;output: port

call Wait_8042_command
pop ax
or al,2			;bit #2 (10b) set for A20 
out 0x60,al		;output: port 0x60 (huh?)

call Wait_8042_command
mov al,0XAE		;command: enable port
out 0x64,al		;output: port

call Wait_8042_command

sti			;enable interrupts

call TestA20		;test this thing once again
jnz EndA20		;is it STILL not open??

jz FAILURE		;Sorry, can't do anything





Wait_8042_command:
in al,0x64 		;waits until the controller lets you send a command
test al,2
jnz Wait_8042_command
ret

Wait_8042_data:
in al,0x64		;waits until the controller reads the data (?)
test al,1
jz Wait_8042_data
ret

FAILURE:
mov si,FAILA20
call printf
jmp $

EndA20:
mov si,SUCCESSA20
call printf

ret



checklm:

cpudetect:

;to detect if we can go to long mode, 
;we first need to find out if cpuid is supported by the processor
;to do that, we attempt to flip the 21st bit of the flags register
;the 21st bit is the ID bit and WILL NOT CHANGE if the processor doesn't
;support

	pusha
	pushfd 		;push eflags
	pop eax 	;pop into eax
	
	mov ecx,eax 	;copy value
	xor eax, 1<<21	;attempt to flip bit

	push eax 
	popfd			;pop modified value into eflags register
					;this may or may not modify eflags depending on whether
					;processor supports CPUID
	pushfd			;push eflags
	pop eax			;pop into eax
	xor eax,ecx 	;compare if original value is retained
	jz NoID			;if so, no support :(

long_mode:
					;Check if extended functions is available in cpuid
	mov eax, 0x80000000
	cpuid			;cpu- identification
	cmp eax, 0x80000001
	jb NoExFunc 	;jump if below
	
	mov eax, 0x80000001
	cpuid
	test edx, 1<<29 ;check if Long Mode bit is set in edx
	jz NoLM
	mov si,LM_SUCCESS
	call printf
	popa
	ret





NoID:
	mov si,ID_FAIL
	call printf
	ret

NoExFunc:
	mov si,EXFUNC_FAIL
	call printf
	ret
NoLM:
	mov si,LM_FAIL
	call printf
	ret
YesLM:
	mov si,LM_SUCCESS
	call printf
	ret


;*****************************************enterProtected*************************
enterProtected:
	
	cli

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
		mov es, ax
		;segment part set 
		;set offset part
	
		mov esp, 090000h        ;safe offset for stack to exist 
		mov byte [0B8000h], 'P'
		mov byte [0B8001h], 1Bh

		;jmp $
		call mainKernel
		jmp $

global gdt_flush
gdt_flush:
	lgdt [GDT_DESC]
	mov ax, 0x10      
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    jmp 0x08:flush2   ; 0x08 is the offset to our code segment: Far jump!
flush2:
    ret               ; Returns back to the C code!

extern idtp
global idt_load
idt_load:
	lidt [idtp]
	ret


MESSAGE db "In sector 2",0x0a,0x0d,0

FAILA20 db "A20 LINE COULD NOT BE ENABLED",0
SUCCESSA20 db "A20 ENABLED",10,13,0

LM_SUCCESS db "Long Mode is available",10,13,0
ID_FAIL db "CPUID UNSUPPORTED",10,0
EXFUNC_FAIL db "Extended functions UNSUPPORTED",10,0
LM_FAIL db "Long Mode unavailable",10,0

;DISKSUCCESSMSG db "Exiting real mode, bye!",0ah,0dh,0



times 512-($-sect2) db 0











sect3:
;[BITS 16]
;keyb:
;		mov ah,00h
;		int 16h
;		cmp ah,0
;		je keyb
;		ret

;***************************************GLOBAL DESCRIPTOR TABLE***************************************
global GDT
GDT:
GDT_NULL:
	dq 0 ; first segment, is null segment and is set to zero
		 ; otherwise intel doesn't like it :)

GDT_CODE:

	GDT_FIRST_DD:
		dw 0xFFFF ;4GB LIMIT (osdever says dw 0FFFFh but same thing)
		dw 0x0000 ;BASE ADDRESS 0
	
	GDT_CONT_BASE_ADDR:
		db 0x00 ; next 8 (bits 0-7 from now) bits are continuation 
	
	GDT_SEGMENT_DESC:
		db 10011010b ; bit 8 set by cpu
					 ; bit 9 to set if want readable
					 ; bit 10 set for conforming 
					 ; (for less privileged code segs to have access)
					 ; bit 11 for code or data seg (1 for code)
					 ; bit 12 set if either data or codeseg
					 ; bit 13,14 for privilege (0 most 3 least)
					 ; OS needs most
					 ; bit 15 present flag ?_?
	
	GDT_LIMIT_DESC:
		db 11001111b ; bits 0-3 last bits of segment limit
					 ; bit 4 is just available to system programmers (lolwut)
				 	 ; bit 5 reserved by intel
				 	 ; bit 6 size bit (tell cpu if 32 bit)
				 	 ; bit 7 granularity
				 	 ; setting this bit muls segment limit by 4 kb
				 	 ; 000FFFFfh X 01000h = FFFFf000
	GDT_REM_BASE_ADDR:
		db 0x00
	
GDT_DATA:
	dw 0FFFFh ;copied from GDT_CODE
	dw 0

	db 0

	db 10010010b; bit 8 access (same as before)
			    ; bit 9 WRITEABLE access
			    ; bit 10 expand direction (we want 0, down)
			    ; bit 11 for code seg (we want data seg)
			    ; bit 12-15 same as codeseg
	db 11001111b ;same as last time
	db 0x00 ;same as last time 

GDT_TSS_KERNEL: ;initialized later
	dd 0
	dd 0
GDT_END:

GDT_DESC:
	dw GDT_END - GDT - 1
	dd GDT

times 512-($-sect3) db 0