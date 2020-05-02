Compiled via nasm and gcc  
Made to a flat binary using objcopy  

assembler:  
sudo apt-get install nasm  
OR  
sudo pacman -S nasm  
etc  

bochs:  
sudo apt-get install bochs  
  
qemu:  
sudo apt-get install qemu-x86_64  

Additionally, you will need multilib for 32bit compatibility   
  
make compile - compiles everything  
make harddrive - makes a harddrive to debug with bochs  
  
make rb - to run on bochs  
make rq - to run on QEMU    
  
make clean - cleanup  
