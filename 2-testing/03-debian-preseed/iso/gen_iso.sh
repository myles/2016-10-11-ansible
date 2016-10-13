#!/bin/bash

set -ex


help() {
cat << EOF
Usage: ${0##*/} [-h] -i debian.iso -p preseed.cfg outfile.iso
Given a Debian iso image, produce a new ISO image with preseed.cfg installed
in order to facilitate an automated install.

    -h              display help and exit
    -i debian.iso   specify input iso image
    -p preseed.cfg  debian preseed configuration for automated install
    outfile.iso     output iso image with preseed slipstreamed

This script creates several temporary directories in current directory and requires sudo, rsync and genisoimage commands to be available.

EOF
}

OPTIND=1

options="hi:p::"
iso_img=""
preseed=""

while getopts $options option
do
    case $option in
        i ) iso_img=`realpath $OPTARG`;;
        p ) preseed=`realpath $OPTARG`;;
        h ) help; exit 1;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
    esac
done
shift "$((OPTIND-1))"
preseed_final=$@

if [ -z "${iso_img}" ] || [ ! -f "${iso_img}" ]
then
    echo "Missing -i debian.iso argument" >&2
    exit 1
fi

if [ -z "${preseed}" ] || [ ! -f "${preseed}" ]
then
    echo "Missing -p preseed.cfg argument" >&2
    exit 1
fi

if [ -z "${preseed_final}" ]
then
    echo "Please specify output file" >&2
    exit 1
fi

work_dir="img_dir"
tmp_dir="loopdir"
irmod="irmod"

rel_workdir=${work_dir}
work_dir="${PWD}/${work_dir}"
loopdir="${PWD}/${loopdir}"
preseed_final="${PWD}/${preseed_final}"
irmod="${PWD}/${irmod}"


sudo rm -f "${preseed_final}"
sudo rm -rf "${work_dir}"
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


mkdir ${irmod}
cd ${irmod}
sudo bash -c "gzip -dc ../${rel_workdir}/install.amd/initrd.gz | cpio --extract --verbose --make-directories --no-absolute-filenames"

sudo cp ${preseed} .
sudo bash -c "find . | cpio -H newc --create --verbose | gzip -9 > ${work_dir}/install.amd/initrd.gz"
sudo  genisoimage -o ${preseed_final} -r -J -no-emul-boot -boot-load-size 4 -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat ${work_dir}

cd ..
sudo umount "${tmp_dir}"
sudo rm -rf "${work_dir}"
sudo rm -rf "${tmp_dir}"
sudo rm -rf "${irmod}"