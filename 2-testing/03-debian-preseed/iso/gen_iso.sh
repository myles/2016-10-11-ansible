#!/bin/bash

iso_img='debian-8.6.0-amd64-CD-1.iso'
preseed="preseed.cfg"
work_dir="img_dir"
preseed_final="debian-amd64-preseed.iso"
tmp_dir="loopdir"
irmod="irmod"

iso_img="${PWD}/${iso_img}"
preseed="${PWD}/${preseed}"
work_dir="${PWD}/${work_dir}"
preseed_final="${PWD}/${preseed_final}"
irmod="${PWD}/${irmod}"



if [ ! -f "${preseed}" ]
    then
    echo "${preceed} file not found"
    exit 1
fi

sudo rm -f "${preseed_final}"
sudo rm -rf "${work_dir}"
sudo umount "${tmp_dir}"
sudo rm -rf "${tmp_dir}"
sudo rm -rf "${irmod}"

if [ ! -f "${iso_img}" ]
    then
    wget -q "http://cdimage.debian.org/debian-cd/8.6.0/amd64/iso-cd/${iso_img}"
fi

mkdir "${tmp_dir}"
sudo mount "${iso_img}" "${tmp_dir}"
mkdir "${work_dir}"
sudo rsync -a -H --exclude=TRANS.TBL "${tmp_dir}/" "${work_dir}"
umount "${tmp_dir}"

mkdir ${irmod}
cd ${irmod}
sudo bash -c "gzip -dc ../${work_dir}/install.amd/initrd.gz | cpio --extract --verbose --make-directories --no-absolute-filenames"

sudo cp ${preseed} .
sudo bash -c "find . | cpio -H newc --create --verbose | gzip -9 > ../${work_dir}/install.amd/initrd.gz"

sudo  genisoimage -o ${preseed_final} -r -J -no-emul-boot -boot-load-size 4 -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat ${work_dir}

sudo umount "${tmp_dir}"
