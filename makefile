bootsect.bin:*.asm
	nasm -fbin bootsect.asm -o bootsect.bin

clean:
	rm *.bin
rq:
	qemu-system-x86_64 bootsect.bin 

rb:
	bochs
