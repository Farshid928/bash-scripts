#!/bin/sh
#! This script transfers last backup files from cPanel or Directadmin servers to the server which this script is running on.
#! Get updates from: https://bit.ly/2RP3Rlv

HOST=192.168.1.1 #Enter Your Hostname or Server IP
PORT=22 #Enter ssh Port

ssh -p $PORT root@$HOST "
	rm bPATH.txt bPATH2.txt 2>/dev/null
  if (test -d /usr/local/cpanel)
  then
	  echo Hostname: \$(hostname)
    echo "Server type: cPanel!"

		bTYPE=\$(cat /var/cpanel/backups/config | grep BACKUPTYPE | awk -v FS=':' '{print \$2}' | cut -c 2-)
		echo Backup Type: \$bTYPE

    if [ \$bTYPE = 'incremental' ]
		then

      bPATH2=\$(find /backup -maxdepth 2 -name '20*' -type d -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d' ')
		
			echo Backup Path: \$bPATH2
			echo Backup Date: \$(echo \$bPATH2 | awk -F "/" '{print \$NF}')
			echo \$bPATH2 > /root/bPATH2.txt
			
    elif [ \$bTYPE = 'compressed' ]
    then
		  bPATH=\$(find /backup -maxdepth 2 -name '20*' -type d -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d' ')
      echo Backup Path: \$bPATH
			echo Backup Date: \$(echo \$bPATH | awk -F "/" '{print \$NF}')
		fi
	
  elif (test -d /usr/local/directadmin)
  then
    echo Hostname: \$(hostname)
    echo "Server Type: DirectAdmin!"
		cat /usr/local/directadmin/data/admin/backup_crons.list | grep -v  option > 1.tmp
		APPEND=\$(cat 1.tmp | awk -v FS='&' '{print \$2}' | awk -v FS='=' '{print \$2}')
                
    if [ \$APPEND = "nothing" ]
    then
      cat 1.tmp | awk -v FS='&' '{print \$8}' | awk -v FS='=' '{print \$2}' > 2.tmp
			sed -i 's|%2F|/|g' 2.tmp
			sed -i 's|%5F|_|g' 2.tmp
			bPATH=\$(cat 2.tmp)
		else
      cat 1.tmp | awk -v FS='&' '{print \$8}' | awk -v FS='=' '{print \$2}' > 2.tmp
      sed -i 's|%2F|/|g' 2.tmp
      sed -i 's|%5F|_|g' 2.tmp
      bPATH=\$(cat 2.tmp)
			bPATH=\$(ls -td \$bPATH/* | head -1)
		fi
		
		echo Backup Date: \$(stat -c %y \$bPATH | awk -v FS=' ' '{print \$1}')
		echo Backup Path: \$bPATH	
		rm 1.tmp 2.tmp

  else
		echo "This is not a cPanel or DirectAdmin Server. no backup file will be Transfer"	
  fi 
   echo \$bPATH > /root/bPATH.txt
"
bPATH=$(ssh -p $PORT root@$HOST  "cat /root/bPATH.txt")
rsync -av -e "ssh -p $PORT" root@$HOST:/root/bPATH2.txt . 2>/dev/null

if grep -q "backup" bPATH2.txt 2>/dev/null
then
	
  while read incPATH
	do
	  rsync -av -e "ssh -p $PORT" root@$HOST:$incPATH/accounts/ /home/$HOST/ --delete
	done < bPATH2.txt
	rm bPATH2.txt
  
elif ssh -p $PORT root@$HOST  'test -d /usr/local/cpanel'
then
  rsync -av -e "ssh -p $PORT" root@$HOST:$bPATH/accounts/ /home/$HOST/
 else
  rsync -av -e "ssh -p $PORT" root@$HOST:$bPATH/ /home/$HOST/
fi
rm bPATH.txt 2>/dev/null
