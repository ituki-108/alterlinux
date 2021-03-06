## Support new kernel

This is the procedure to make Alter Linux compatible with the new kernel. Here we explain the procedure to add `linux-fooo`. Replace this character when you do.
You need to add two types of packages to the repository. The kernel body and headers package.


### 1. Create a arch repository

`build.sh` tries to install the kernel using pacman. If you want to add a kernel that is not in the official repository, first create a pacman repository.  
You can easily create a repository using GitHub.  

### 2. Add to kernel list

Add the kernel name to `kernel_list`. This variable is used to judge whether the value passed to `build.sh` is correct.  
The value to add to the list is the character after `linux-`. In this case it will be `fooo`.  

```bash
echo "fooo" >> ./system/kernel_list
```

### 3. Create the file
You need to create 6 files for that kernel. Below is a list of kernels.  
The easiest way is to rename the existing file, copy it, and fix the path to the kernel.  
The file name has been replaced with `fooo`.  

1. syslinux/pxe/archiso_pxe-fooo.cfg
2. syslinux/pxe-plymouth/archiso-fooo.cfg
3. syslinux/sys/archiso_sys-fooo.cfg
4. syslinux/sys-plymouth/archiso_sys-fooo.cfg
5. efiboot/loader/entries/cd/archiso-x86_64-cd-fooo.conf
6. efiboot/loader/entries/usb/archiso-x86_64-usb-fooo.conf
7. airootfs/usr/share/calamares/modules/unpackfs/unpackfs-fooo.conf
8. airootfs/usr/share/calamares/modules/initcpio/initcpio-fooo.conf

#### 1 and 2

Change the paths on lines 7, 18, and 29.  

#### 3 and 5\4

Change the path on line 7.  

#### 5 and 6

Change the path on the second line.  

#### 7
Change the paths on lines 95 and 97.  

#### 8
Change the path on line 18.  

### 4.プルリクエストを送る
Please post a pull request [here](https://github.com/FascodeNet/alterlinux/pulls).  

