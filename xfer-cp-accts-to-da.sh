#!/bin/sh
#You can get the script updates from  https://bit.ly/2ktJVHn

#Note that you need to add the DirectAdmin IP server from the "Add a New IP Address" section on the WHM panel before running the script.
#If you do not intend to change the IP after transferring the account, remove the following line from the script:
#/usr/local/cpanel/bin/setsiteip -u $USER $DEST

#Note that the connection between servers must be established via the ssh key.

#Important note that none of cpanel accounts should be suspended! If so, the script will not work correctly.

DEST="192.168.1.1" #Your DirectAdmin Server IP
PORT="22" #Your Directadmin Server ssh Port
cd /var/cpanel/users
for USER in *; do
if [ "$USER" != "system" ]
then
       echo "starting transfer process for $USER"
	sleep 2

        #backup cpanel account (public_html excludes) and transfer to directadmin server.
        /scripts/pkgacct $USER --skippublichtml
        rsync -av -e "ssh -p $PORT" /home/cpmove-$USER.tar.gz root@$DEST:/backup/

	#Restore backup in directadmin server.
	ssh -p $PORT root@$DEST "
		chown admin.admin /backup/
		chown admin.admin /backup/cpmove-$USER.tar.gz
		echo 'action=restore&ip%5Fchoice=select&ip=$DEST&local%5Fpath=%2Fbackup&owner=admin&select%30=cpmove-$USER.tar.gz&type=admin&value=multiple&when=now&where=local' >> /usr/local/directadmin/data/task.queue
		echo "backup is restoring in DirectAdmin!"
		sleep 2
		while \$(grep -Fq "action=restore" /usr/local/directadmin/data/task.queue 2>/dev/null); do printf "%s""$i" .; sleep 2; done;
		while \$(test ! -d /home/$USER/public_html); do printf "%s""$i" .; sleep 2; done;
		printf '\n'
		echo "backup restoration completed in DirectAdmin!"
		sleep 2
	"
	
	#transfer public_html files and dirs to destinaton server	
	rsync -av -e "ssh -p $PORT" /home/$USER/public_html/ root@$DEST:/home/$USER/public_html/
	ssh -p $PORT root@$DEST "
		chown -R $USER.$USER /home/$USER/public_html/
		find /home/$USER/public_html/ -type d -exec chmod 755 {} \;
	"

	#remove backup files in order to free space
	ssh -p $PORT root@$DEST "rm /backup/cpmove-$USER.tar.gz"
	rm /home/cpmove-$USER.tar.gz

	#change user ip in order to transfer site loding to destination server.
	/usr/local/cpanel/bin/setsiteip -u $USER $DEST	

	/scripts/suspendacct $USER "User transferred to Direct Admin."

	echo "transfer process for $USER has been completed!"
	sleep 2
	printf '\n'
fi
done
