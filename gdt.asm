;Procedure to enter protected mode

GDT:
GDT_NULL:
	dq 0 ; first segment, is null segment and is set to zero
		 ; otherwise intel doesn't like it :)

GDT_CODE:

	GDT_FIRST_DD:
		dw 0xFFFF ;4GB LIMIT (osdever says dw 0FFFFh but same thing)
		dw 0 ;BASE ADDRESS 0
	
	GDT_CONT_BASE_ADDR:
		db 0 ; next 8 (bits 0-7 from now) bits are continuation 
	
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
		db 0
	
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
	db 0 ;same as last time 

GDT_END:

GDT_DESC:
	dw GDT_END - GDT - 1
	dd GDT

