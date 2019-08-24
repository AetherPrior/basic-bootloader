bootsect.bin:*.asm
	nasm -fbin bootsect.asm -o bootsect.bin

clean:
	rm *.bin
run:
	qemu-system-x86_64 bootsect.bin
