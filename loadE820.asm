;-4	size
;0	base_addr_low
;4	base_addr_high
;8	length_low
;12	length_high
;16	type





loadE820:
	pusha
	;most of this code from the osdev wiki (Detecting Memory x86)
	mov di,0x8004 ;entries stored at 0x8000, without moving di the code can be stuck at int 0x15
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

mmap_entries equ 0x8000
E820_ERR_MESSAGE db "E820 IS NOT SUPPORTED/CALL FAILED",0ah,0dh,0