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


FAILA20 db "A20 LINE COULD NOT BE ENABLED",0
SUCCESSA20 db "A20 ENABLED",10,13,0

