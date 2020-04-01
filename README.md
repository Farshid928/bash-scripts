# bash-scripts
some bash scripts in order to make life easier!

1. <a href="https://github.com/Farshid928/bash-scripts/blob/master/xfer-cp-accts-to-da.sh">xfer-cp-accts-to-da.sh</a>:
Auto transfer cpanel users to directadmins via bash script.

The script executes these steps:
1. Creat a full backup of account on cpanel. (This full backup does not include the public_html directory)
2. Transfer backup to directadmin server and restore that.
3. After the full backup in directadmin restores the user public_html directory information in cpanel transfer to the user public_html directory in directadmin.
4. Deletes cpanel full backups from both servers in order to prevent space occupancy.
5. Changes the account ip in the cpanel to the directadmin server ip to load the site from the directadmin server.
6. Suspends the user in cpanel server so that the user does not have access to the previous panel.

These steps are performed respectively for each cpanel user account.

2. <a href="https://github.com/Farshid928/bash-scripts/blob/master/cp-da-remote-bak.sh">cp-da-remote-bak.sh</a>:
Transfer Last backup files of cPanel or Directadmin servers based on backup type (Compressed or Incremental).
This scripts transfers backups to home directory and places it into a directoy named after the source server.

3. <a href="https://github.com/Farshid928/bash-scripts/blob/master/sync-cluster-dns-cp.sh">sync-cluster-dns-cp.sh</a>: Sync dns zones in a cpanel clustered server.
This script syncs dns zone(s) for all domains (main domain, parked doamin(s) and addon domain(s) in a cpanel cluster dns netwok.

4. <a href="https://github.com/Farshid928/bash-scripts/blob/master/cp-da-check-bak.sh">cp-da-check-bak.sh</a>: Chek cpanel and directadmin full backups.
This scripts whill will check the last full backup if on cpanel and directadmin servers. Number of users will be compare compared with number of backup files and if a user has no backup files, the username will be shown to you displayed. In addition in on the servers with compressed full backups, the tar.gz file will be check checked to see if it's extractable in order to be extractable
