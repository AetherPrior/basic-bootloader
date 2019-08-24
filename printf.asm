printf:
pusha
strLoop:
 lodsb
 or al,al
 jz end
 mov ah,0eh
 int 10h
 jmp strLoop
end:
 popa
 ret
