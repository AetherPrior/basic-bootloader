checklm:

cpudetect:

;to detect if we can go to long mode, 
;we first need to find out if cpuid is supported by the processor
;to do that, we attempt to flip the 21st bit of the flags register
;the 21st bit is the ID bit and WILL NOT CHANGE if the processor doesn't
;support

	pusha
	pushfd ;push eflags
	pop eax;pop into eax
	
	mov ecx,eax ;copy value
	xor eax, 1<<21;attempt to flip bit

	push eax 
	popfd	;pop modified value into eflags register
		;this may or may not modify eflags depending on whether
		;processor supports CPUID
	pushfd	;push eflags
	pop eax	;pop into eax
	xor eax,ecx ;compare if original value is retained
	jz NoID	;if so, no support :(

long_mode:
;Check if extended functions is available in cpuid
	mov eax, 0x80000000
	cpuid			;cpu- identification
	cmp eax, 0x80000001
	jb NoExFunc ;jump if below
	
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
