bootsect.bin:*.asm
	nasm -fbin bootloader.asm -o bootloader.bin

clean:
	rm *.bin
rq:
	qemu-system-x86_64 bootloader.bin 

rb:
	bochs
