#!/bin/bash

mkdir -p initrd/{bin,sbin,usr,etc,proc,sys,newroot}
touch initrd/etc/mdev.conf
wget -O initrd/bin/busybox http://www.busybox.net/downloads/binaries/latest/busybox-x86_64
chmod +x initrd/bin/busybox
ln -s busybox initrd/bin/sh
ln -s ../bin initrd/usr/bin
ln -s ../bin initrd/usr/sbin

cat > initrd/init << "EOF"
#!/bin/sh

#Create all the symlinks to /bin/busybox
/bin/busybox --install -s

#Mount things needed by this script
/bin/mount -t proc proc /proc
/bin/mount -t sysfs sysfs /sys
/bin/mount -t devtmpfs none /dev

#Disable kernel messages from popping onto the screen
echo 0 > /proc/sys/kernel/printk

#Clear the screen
clear


#Function for parsing command line options with "=" in them
#get_opt("init=/sbin/init") will return "/sbin/init"
get_opt() {
	echo "$@" | cut -d "=" -f 2
}

#Defaults
init="/sbin/init"
root=`/bin/busybox blkid | grep rootfs| cut -d ":" -f 1`

#Process command line options
for i in $(cat /proc/cmdline); do
	case $i in
		root\=*)
			root=$(get_opt $i)
			;;
		init\=*)
			init=$(get_opt $i)
			;;
	esac
done

# expand the root part
rootpart=`blkid | grep rootfs| cut -d ":" -f 1`
vdisk=`echo $rootpart| sed s/[0-9]//g`
/bin/echo "d
2
n
p
2
20480

w
" | /bin/busybox fdisk -u $vdisk > /dev/null


#Mount the root device
/bin/echo newroot is $root
/bin/mount $root /newroot

# we need to move these, as per http://landley.net/writing/rootfs-programming.html, busybox' switch_root is a bit dumb, util-linux one would do it automatically
mount --move /sys /newroot/sys
mount --move /proc /newroot/proc
mount --move /dev /newroot/dev

#Check if $init exists and is executable
if [[ -x "/newroot/${init}" ]] ; then
	#Unmount all other mounts so that the ram used by
	#the initramfs can be cleared after switch_root
	#umount /sys /proc
	# no need for this anymore as we --move the mounts, see above
	
	#Switch to the new root and execute init
	exec switch_root /newroot "${init}"
fi

#This will only be run if the exec above failed
echo "Failed to switch_root, dropping to a shell"
exec sh
EOF

chmod +x initrd/init

cd initrd
find . | cpio -H newc -o > ../initrd.cpio
cd ..
cat initrd.cpio | gzip > initrd.igz
