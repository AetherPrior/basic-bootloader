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

pusha

mov ax,[0x7dfe]
mov dx,ax
call printh

;0xffff0+offset = 0x107dfe
;offset = 0x107dfe-0xffff0 = 0x7e0e
;if A20 is disabled then we get the location as 7dfe
;but if enabled we don't

call SegTest
mov ax,0x2400
int 15h
call SegTest
popa
ret
SegTest:
push bx
xor bx,bx
sub bx,1
mov es,bx
pop bx
mov bx,0x7e0e ;basically sending the offset to check
mov dx,[es:bx];if aa55 then there's a wrap, otherwise no
call printh
ret
;Turns out QEMU does enable the A20 line by default
