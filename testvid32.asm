testvid32:
	mov ebx,0a0000h

	set_palette:
		mov al,cl
		mov dx,0x3c8
		out dx,al
		mov dx,0x3c9
		out dx,al
		out dx,al
		out dx,al
		loop set_palette


	XOR_PATTERN:
		mov ecx,320
		mov eax, ebx
		div ecx
		;eax has y

		;
		;
		;   y*320 + x = ebx 
		;   x^y
		;	
		;	
		;	
		;	
		;	
		;	
		
		mov edx,eax
		;edx has y
		mul ecx
		;eax has y offset

		mov ecx,ebx
		sub ebx,eax
		;ebx has x now

		mov eax,ebx

		xor eax,edx
		;y in edx
		;x in eax

		mov ebx,ecx

		mov [ebx], BYTE al
		

		
		inc ebx
		cmp ebx, 0x0afa00
		jne testvid32
