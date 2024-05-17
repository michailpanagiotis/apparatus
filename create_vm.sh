#!/usr/bin/env bash
set -e

wget -O /tmp/bundle.bash -q https://github.com/timo-reymann/bash-tui-toolkit/releases/download/1.5.1/bundle.bash
source /tmp/bundle.bash

validate_vmid() {
   if (( $1 <= 100 )); then
     echo "Use a number greater than 100"
     exit 1
   fi

   if (( $1 >= 110 )); then
     echo "Use a number lower than 110"
     exit 1
   fi
}

# VM ID
VMID=$(with_validate 'input "Set a VM id (100-110)"' validate_vmid)
EMAIL=$(with_validate 'input "Set your email"' validate_present)
DISK_SIZE=$(with_validate 'input "Disk size (Gb)"' validate_present)

# Select image
images=("https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2" "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img" "https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2")
image_idx=$(list "Select one image" "${images[@]}")
CLOUD_IMAGE=${images[$image_idx]}

disks=("verbatim")
disk_idx=$(list "Select one disk" "${disks[@]}")
DISK=${disks[$disk_idx]}

IMAGE_FILE=$(basename $CLOUD_IMAGE)
RAM_SIZE=8192
NAME=$(echo "${IMAGE_FILE%.*}" | tr "_" "-")
GEN_MAC=02:$(openssl rand -hex 5 | awk '{print toupper($0)}' | sed 's/\(..\)/\1:/g; s/.$//')
IP=192.168.1.${VMID}/24
GATEWAY=192.168.1.1

echo "
--- Creating VM...
id: $VMID
email: $EMAIL
cloud image: $CLOUD_IMAGE
image file: $IMAGE_FILE
name: $NAME
disk: $DISK
disk size: $DISK_SIZE
ram size: $RAM_SIZE
mac: $GEN_MAC
ip: $IP
gateway: $GATEWAY
"

confirmed=$(confirm "Proceed?")

create_vm() {
  qm create $VMID \
    -memory $RAM_SIZE \
    -name $NAME \
    -net0 virtio,bridge=vmbr0,macaddr=$GEN_MAC \
    -agent 1 \
    -tablet 0 \
    -localtime 1 \
    -onboot 1 \
    -ostype l26 \
    -scsihw virtio-scsi-pci
}

create_disk() {
  if test -f $IMAGE_FILE; then
    echo "Image file '$IMAGE_FILE' exists, using it..."
  else
    echo "Image file '$IMAGE_FILE' does not exist, downloading..."
    wget $CLOUD_IMAGE
  fi

  DISK_RESIZE_STEP=$(($DISK_SIZE-2))
  qm importdisk $VMID $IMAGE_FILE $DISK -format qcow2
  qm set $VMID --scsihw virtio-scsi-pci --scsi0 ${DISK}:vm-${VMID}-disk-0
  qm resize $VMID scsi0 +${DISK_RESIZE_STEP}G
  rm -v $IMAGE_FILE
}

configure_cloud_init() {
  qm set $VMID --ide2 $DISK:cloudinit --boot c --bootdisk scsi0 --serial0 socket --vga serial0
  qm set $VMID --ciuser root
  qm set $VMID --cipassword apassword
}

config_network() {
  qm set $VMID --ipconfig0 ip=$IP,gw=$GATEWAY
  if [ ! -f "$HOME/.ssh/id_${VMID}" ]
  then
    ssh-keygen -t ed25519 -C "${EMAIL}" -N '' -f ~/.ssh/id_${VMID}
  fi
  qm set $VMID --sshkey ~/.ssh/id_${VMID}.pub
}

create_vm
create_disk
configure_cloud_init
config_network
