readDisk:
 pusha
 mov ah,2
 mov dl,80h ;change to 0 if you want to boot from iso (floppy) [pen/flash drive emulates a floppy] 
	    ;may work for CD as well IDK
 mov ch,0
 mov dh,0
 push bx
 mov bx,0
 mov es,bx
 pop bx
 mov bx,7c00h+512
 int 0x13
 jc fail

 popa
 ret
fail:
 mov si,DISKFAILMSG
 call printf
 jmp $
DISKFAILMSG db "disk read ERROR",0
