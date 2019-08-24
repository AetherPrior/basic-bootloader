Compiled via nasm:
sudo apt-get install nasm
OR
sudo pacman -S nasm
etc

nasm bootsect.asm -fbin -o bootsect.bin


alternately, you can run:

make

make run

booting done with QEMU:

sudo apt-get install qemu-system-x86

qemu-system-x86_64 bootsect

files:

bootsect.asm --main file 

printf.asm --print routine

printh.asm --routine to print hex numbers (for addresses)

readDisk.asm -- to read more sectors

TestA20.asm -- testing if A20 line is enabled

checklm -- checks for long mode

loadE820 -- detects the memory via e820 

videoMode -- currently switches to 320x200 256 color mode (mode 13h)
