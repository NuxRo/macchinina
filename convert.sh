#!/bin/bash


qemu-img convert -p -f raw -O qcow2 macchinina.img -o compat=0.10 macchinina-kvm.qcow2
qemu-img convert -p -f raw -O vmdk macchinina.img macchinina-vmware.vmdk
qemu-img convert -p -f raw -O vpc macchinina.img macchinina-hyperv.vhd

# xenserver ...
cp macchinina.img macchinina-xen.img
vhd-util convert -s 0 -t 1 -i macchinina-xen.img -o macchinina-xenstage.img
faketime '2010-01-01' vhd-util convert -s 1 -t 2 -i macchinina-xenstage.img -o macchinina-xen.vhd
rm -fv macchinina-xenstage.img.bak

# compress
bzip2 -v macchinina-kvm.qcow2 macchinina-vmware.vmdk macchinina-xen.vhd
zip --verbose macchinina-hyperv.vhd.zip macchinina-hyperv.vhd && rm -fv macchinina-hyperv.vhd

