videoMode:
;	VbeSignatiure resb 4
;	VbeVersion resb 2
;	OemStringPtr resb 2
;	Capabilities resb 4
;	VideoModePtr resb 2

;TODO, configure a PROPER video mode
;************************VESA lite, use 13H for now**********************************

push ax
mov ax, 0x0013
int 10h
pop ax
ret
