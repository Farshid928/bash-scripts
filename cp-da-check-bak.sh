#Get updates from https://bit.ly/2Uw0CAU
#This script has been tested in zsh shell, I suggest you to use this shell environment >> https://bit.ly/2w1WUFJ
#This script works on cpanel and directadmin servers. In directadmin servers only full backups in cron will be check.
#In the servers with compressed backups it'll take some times to complete the process.

echo '####################'
rm bPATH.txt bPATH2.txt 2>/dev/null
	if (test -d /usr/local/cpanel)
	then
		echo Hostname: $(hostname)
		echo "Server type: cPanel!"

		bTYPE=$(cat /var/cpanel/backups/config | grep BACKUPTYPE | awk -v FS=':' '{print $2}' | cut -c 2-)
		echo Backup Type: $bTYPE

		if [ $bTYPE = 'incremental' ]
		then
			bPATH2=$(find /backup -maxdepth 2 -name '20*' -type d -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d' ')
			echo Backup Path: $bPATH2
			echo Backup Date: $(echo $bPATH2 | awk -F "/" '{print $NF}')
			echo $bPATH2 > /root/bPATH2.txt
			
		elif [ $bTYPE = 'compressed' ]
		then
			bPATH=$(find /backup -maxdepth 2 -name '20*' -type d -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d' ')
				echo Backup Path: $bPATH
				echo Backup Date: $(echo $bPATH | awk -F "/" '{print $NF}')
		fi

	elif (test -d /usr/local/directadmin)
	then
		echo Hostname: $(hostname)
		echo "Server Type: DirectAdmin!"
		cat /usr/local/directadmin/data/admin/backup_crons.list | grep -v  option > 1.tmp
		APPEND=$(cat 1.tmp | awk -v FS='&' '{print $2}' | awk -v FS='=' '{print $2}')
			
		if [ $APPEND = "nothing" ]
		then
		cat 1.tmp | awk -v FS='&' '{print $8}' | awk -v FS='=' '{print $2}' > 2.tmp
			sed -i 's|%2F|/|g' 2.tmp
			sed -i 's|%5F|_|g' 2.tmp
			bPATH=$(cat 2.tmp)
		else
			cat 1.tmp | awk -v FS='&' '{print $8}' | awk -v FS='=' '{print $2}' > 2.tmp
			sed -i 's|%2F|/|g' 2.tmp
			sed -i 's|%5F|_|g' 2.tmp
			bPATH=$(cat 2.tmp)
			bPATH=$(ls -td $bPATH/* | head -1)
		fi

		echo Backup Date: $(stat -c %y $bPATH | awk -v FS=' ' '{print $1}')
		echo Backup Path: $bPATH
		rm 1.tmp 2.tmp
	else
		echo "This is not a cPanel or DirectAdmin Server. Nothing will be check"
	fi
	
	echo '--------------------'
	echo $bPATH > /root/bPATH.txt

	rm /root/userlist928.txt 2>/dev/null
	rm /root/userlist929.txt 2>/dev/null

	#Check Cpanel Incremental Backups
	if grep -q "backup" bPATH2.txt 2>/dev/null
	then
		for USERS in /var/cpanel/users/*; do
			echo $USERS |  awk -v FS='/' '{print $5}' >> /root/userlist928.txt
		done

		sed -e s/nobody//g -i /root/userlist928.txt
		sed -e s/system//g -i /root/userlist928.txt
		sed -i '/^$/d' /root/userlist928.txt
		USRCOUNT=$(wc -l /root/userlist928.txt |  awk -v FS=' ' '{print $1}')
		cd $bPATH2/accounts/
		BKPCOUNT=$(find . -mindepth 1 -maxdepth 1 -type d | wc -l)
		echo Number of accounts: $USRCOUNT
		echo Number of backup files: $BKPCOUNT

		while read USER  ; do
			if [ ! -e $bPATH2/accounts/"$USER" ]; then
				echo $USER >> /root/userlist929.txt
			fi
		done < /root/userlist928.txt
		echo '--------------------'
		if [ -s /root/userlist929.txt ]
		then
			echo The users which have no backup:
			while read USER  ; do
				echo -n Username: $USER -
				echo ‌ Createion Date: $(date -d @$(cat /var/cpanel/users/$USER | grep STARTDATE | awk -v FS='=' '{print $2}') +'%Y-%m-%d')
			done < /root/userlist929.txt
		else
			echo 'Great! All users have backup!'
		fi

		rm /root/bPATH2.txt
		
	#Check Cpanel Compressed Backups
	elif  (test -d /usr/local/cpanel)
	then
		for USERS in /var/cpanel/users/*; do
			echo $USERS.tar.gz |  awk -v FS='/' '{print $5}' >> /root/userlist928.txt
		done

		sed -e s/nobody.tar.gz//g -i /root/userlist928.txt
		sed -e s/system.tar.gz//g -i /root/userlist928.txt
		sed -i '/^$/d' /root/userlist928.txt
		USRCOUNT=$(wc -l /root/userlist928.txt | awk -v FS=' ' '{print $1}')
		cd $bPATH/accounts/
		BKPCOUNT=$(ls -1q *.gz | wc -l)
		echo Number of accounts: $USRCOUNT
		echo Number of backup files: $BKPCOUNT

		while read USER  ; do
			if [ ! -e $bPATH/accounts/"$USER" ]; then
				echo $USER >> /root/userlist929.txt
			fi
		done < /root/userlist928.txt

		echo '--------------------'

		if [ -s /root/userlist929.txt ]
		then
			echo The users which have no backup:
			while read USER  ; do
				USER2=$(echo $USER | awk -v FS='.' '{print $1}')
				echo -n Username: $USER2 -
				echo ‌ Createion Date: $(date -d @$(cat /var/cpanel/users/$USER2 | grep STARTDATE | awk -v FS='=' '{print $2}') +'%Y-%m-%d')
			done < /root/userlist929.txt
		else
			echo 'Great! All users have backup!'
		fi
		echo '--------------------'
		cd $bPATH/accounts
		rm /root/corrupted928.txt 2>/dev/null
				for USER in *.gz
				do
					if ! (tar -tzvf $USER >/dev/null 2>&1)
					then
						echo $USER >> /root/corrupted928.txt
					fi
				done
		if [ -s /root/corrupted928.txt ]
		then
			echo The corrupted backup files:
			while read USER  ; do
				echo $USER
			done < /root/corrupted928.txt
		else
			echo 'Okay! none of backup files are corrupted!'
		fi

	else
		#Check DirectAdmin Backups
		for USERS in /usr/local/directadmin/data/users/*; do
			USER=$(echo $USERS | awk -v FS='/' '{print $7}' )
			TYPE=$(cat /usr/local/directadmin/data/users/$USER/user.conf | grep usertype | awk -v FS='=' '{print $2}')
			CREATOR=$(cat /usr/local/directadmin/data/users/$USER/user.conf | grep creator | awk -v FS='=' '{print $2}')
			
			if [ $TYPE = 'admin' ]
			then
				BAKNAME=admin.$CREATOR.$USER.tar.gz
			elif [ $TYPE = 'reseller'  ]
			then
				BAKNAME=reseller.$CREATOR.$USER.tar.gz
			elif [ $TYPE = 'user'  ]
			then
				BAKNAME=user.$CREATOR.$USER.tar.gz
			fi

			echo $BAKNAME >> /root/userlist928.txt
		done

	USRCOUNT=$(wc -l /root/userlist928.txt | awk -v FS=' ' '{print $1}')
	cd $bPATH/
	BKPCOUNT=$(ls -1q *.gz | wc -l)
	echo Number of accounts: $USRCOUNT
	echo Number of backup files: $BKPCOUNT
	echo '--------------------'

		while read USER  ; do
			if [ ! -e $bPATH/"$USER" ]; then
				echo $USER >> /root/userlist929.txt
			fi
		done < /root/userlist928.txt
		
		if [ -s /root/userlist929.txt ]
		then
			echo The users which have no backup:
			while read USER  ; do
				USER2=$(echo $USER | awk -v FS='.' '{print $3}')
				echo -n Username: $USER2 -
				echo ‌ Createion Date: $(cat /usr/local/directadmin/data/users/$USER2/user.conf | grep date_created | awk -v FS='=' '{print $2}' | awk -v FS=' ' '{print $3" "$2" "$5}')
			done < /root/userlist929.txt
		else
			echo Great! All users have backup!
		fi
		echo '--------------------'
		cd $bPATH
		rm /root/corrupted928.txt 2>/dev/null
		
		for USER in *.gz
		do
			if ! (tar -tzvf $USER >/dev/null 2>&1)
			then
				echo $USER >> /root/corrupted928.txt
			fi
			done
			
		if [ -s /root/corrupted928.txt ]
		then
			echo The corrupted backup files:
			while read USER  ; do
				echo $USER
		done < /root/corrupted928.txt
		else
			echo 'Okay! none of backup files are corrupted!'
		fi
	fi
	rm bPATH.txt 2>/dev/null
	rm /root/userlist928.txt 2>/dev/null
	rm /root/userlist929.txt 2>/dev/null
echo '####################'
