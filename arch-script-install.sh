##

loadkeys fr


curl -s https://eoli3n.github.io/archzfs/init | bash

##


selectdisk(){
                items=$(ls -lha /dev/disk/by-id)
                options=()
                IFS_ORIG=$IFS
                IFS=$'\n'
                for item in ${items}
                do
                                options+=("${item}" "")
                done
                IFS=$IFS_ORIG
                result=$(whiptail --backtitle "${APPTITLE}" --title "${1}" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
                if [ "$?" != "0" ]
                then
                                return 1
                fi
                result2=$(printf "$result" | awk '{print $9}')
                DISK=/dev/disk/by-id/${result2}
                echo "Vous avez choisi le disque ${DISK}"
                return 0
}

selectdisk

echo ""

echo "###########"
echo "512M pour /boot"
echo "32G pour le swap"
echo "Le reste pour les données"
echo "###########"

echo ""

sgdisk --zap-all $DISK
sgdisk  -n 0:0:+512M    -t 0:EF00 $DISK
sgdisk  -n 0:0:+32G     -t 0:8200 $DISK
sgdisk  -n 0:0:0        -t 0:BF00 $DISK

zpool create -f -o ashift=13         \
             -O acltype=posixacl       \
             -O relatime=on            \
             -O xattr=sa               \
             -O dnodesize=legacy       \
             -O normalization=formD    \
             -O mountpoint=none        \
             -O canmount=off           \
             -O devices=off            \
             -O compression=lz4        \
             -R /mnt                   \
             zroot $DISK-part3
