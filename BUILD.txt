# I do not build the kernel as part of Buildroot, but separately for some historic reason - this should be "fixed"
# You can build your own bzImage with configs/kernel/dotkernelconfig and put it in overlayfs/boot/

# get our stuff
git clone https://github.com/NuxRo/macchinina.git macchinina.git

# build buildroot, modify the config if you need to with
# make BR2_CONFIG=../configs/buildroot/dotbuildrootconfig menuconfig
tar xzf macchinina.git/buildroot-2014.11.tar.gz
cd buildroot-2014.11
make BR2_CONFIG=../macchinina.git/configs/buildroot/dotbuildrootconfig
cd ..

# create the underlying disk image and partitions
qemu-img create -f raw macchinina.img 50M
parted -s ./macchinina.img "mklabel msdos"
parted -s ./macchinina.img "mkpart primary 1049kB 10M"
parted -s ./macchinina.img "mkpart primary 10M 100%"
parted -s ./macchinina.img "set 1 boot on"

# write an mbr to it
dd bs=440 conv=notrunc count=1 if=/usr/share/syslinux/mbr.bin of=./macchinina.img

# we need to format the partitions
kpartx -a -p macchinina ./macchinina.img
mkfs.ext2 -L boot /dev/mapper/loop0macchinina1
mkfs.ext4 -L rootfs /dev/mapper/loop0macchinina2

# mount the partitions and copy over the data
mkdir -p mnt/macchinina
mount /dev/mapper/loop0macchinina2 mnt/macchinina
mkdir mnt/macchinina/boot/
mount /dev/mapper/loop0macchinina1 mnt/macchinina/boot/
tar -C mnt/macchinina/ --exclude=lib/modules --exclude=lib/firmware -xf buildroot-2014.11/output/images/rootfs.tar

# install extlinux bootloader
extlinux --install mnt/macchinina/boot/extlinux/

# unmount partitions and finish
umount mnt/macchinina/boot
umount mnt/macchinina/
kpartx -d ./macchinina.img


