#!/bin/bash
#This script syncs dns zone(s) for all domains (main domain, parked doamin(s) and addon domain(s) in a cpanel cluster dns netwok.


echo "Enter username then press enter:"

read USER

if [ -e /var/cpanel/users/"$USER" ]; then

printf '\n'
echo syncing dns zones for $USER...
printf '\n'

#get main domain:
cat /var/cpanel/userdata/$USER/main | grep main_domain | cut -c 14- > synczone.txt

#get parked domain(s):
awk '/parked_domains/,/sub_domains/' /var/cpanel/userdata/$USER/main | grep -v _domain | cut -c 5- >> synczone.txt

#get addon domain(s):
awk '/addon_domains/,/main_domain/' /var/cpanel/userdata/$USER/main | awk -v FS=':' '{print $1}' | grep -v _domain | cut -c 3- >> synczone.txt

#clear empty lines
sed -i '/^$/d' synczone.txt

while read DOMAIN  ; do
	/scripts/dnscluster synczone $DOMAIN
done < synczone.txt
rm synczone.txt

printf '\n'
echo "Done!"

else
    echo "This user does not exist on this server!"
fi
