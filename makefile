BOOTLOADER=bootloader.asm
KERNEL=mainKernel.c

bootsect.bin:*.asm
	nasm -fbin bootloader.asm -o bootloader.bin

clean:
	rm *.bin
rq:
	qemu-system-x86_64 bootloader.bin 

rb:
	bochs

compile:
	rm *.img
	nasm -felf32 $(BOOTLOADER) -o boot.o
	i686-elf-gcc -c self_kernel/$(KERNEL) -o mainKernel.o -ffreestanding -O2 -Wall -Wextra -std=gnu99
	i686-elf-gcc -T linker.ld -o bootloader.bin -ffreestanding -O2 -nostdlib boot.o mainKernel.o -lgcc
	objcopy -O binary bootloader.bin bootloader.bin

harddrive:
	dd if=/dev/zero of=disk.img count=1008 bs=512
	dd if=bootloader.bin of=disk.img conv=notrunc

disassemble:
	objdump -D -Mintel,i8086 -b binary -m i386 bootloader.bin > dis


