#!/bin/bash
#check if arguments are valid
if [[ -z ${1} || -z ${2} || -z ${3} ]]; then
    echo "Not all arguments provided"
    echo "Intended Use: createzumi <target> <image> <zuminame>"
    exit 1
fi
devices=$(lsblk -d -o NAME)
readarray -t dev<<<"$devices"
if [[ ! " ${dev[*]} " =~ " ${1} " ]]; then
    echo "The device /dev/$1 can not be found"
    echo "Intended Use: createzumi <target> <image> <zuminame>"
    exit 1
fi
if [[ ! "$3" =~ ^[a-z][a-zA-Z0-9_]*$ ]]; then
    echo "Second argument should be a valid zumi name (starting with a letter)"
    echo "Intended Use: createzumi <target> <image> <zuminame>"
    exit 1
fi
#check if image exists
RESULT=$(find . -maxdepth 1 -type f \( -iname "*.img" ! -iname "boot.img" \) -printf "%f\n")
readarray -t local<<<"$RESULT"
if [[ ! " ${local[*]} " =~ " ${2} " ]]; then
    #The file is not already in the cwd, will try to check in repo
    wget -q --no-check-certificate 'https://docs.google.com/uc?export=download&id=1U3F7inaFRhLg3T51Jst-_G3ucuFwM9sE' -O ids.txt 2>&1 >/dev/null
    if [ $? -ne 0 ]; then
        echo "image not found locally and online repo access not successful."
        exit 1
    fi
    RESULT=`cat ids.txt`
    rm ids.txt
    readarray -t online<<<"$RESULT"
    declare -A links
    for image in ${online[@]}; do
        IFS="="
        read -ra pair <<< $image
        links[${pair[0]}]=${pair[1]}
    done
    if [[ ! " ${!links[*]} " =~ " ${2} " ]]; then
        echo "image not in cwd or online repo, available images:"
        echo "local : ${local[@]}"
        echo "online: ${!links[@]}"
        exit 1
    fi
    link="${links[$2]}"
    echo "image not found locally but in online repo, downloading.."
    if [[ ! " ${local[*]} " =~ "boot.img" ]]; then
        wget -q --show-progress --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=1rLlzk9SwZpBtGB7x4Ybn5gqLu2FWDIlt" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1rLlzk9SwZpBtGB7x4Ybn5gqLu2FWDIlt" -O boot.img && rm -rf /tmp/cookies.txt
    fi
    wget -q --show-progress --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$link" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$link" -O ${2}.gz && rm -rf /tmp/cookies.txt
    #unzipping
    echo "unzipping, this can take a few minutes..."
    gunzip "${2}.gz"
fi
#dd if=boot.img of=/dev/${1}p1 status=progress
#dd if=${2} of=/dev/${1}p2 status=progress
SDPATH=$(findmnt -nr -o target -S /dev/mmcblk0p2)
echo $3 > ${SDPATH}/etc/hostname
sed -i "9s/.*/127.0.1.1           $3/" ${SDPATH}/etc/hosts
sed -i "/ssid=/c\ssid=$3" ${SDPATH}/etc/hostapd/hostapd.conf
sed -i "/wpa_passphrase=/c\wpa_passphrase=$3" ${SDPATH}/etc/hostapd/hostapd.conf
exit 0
