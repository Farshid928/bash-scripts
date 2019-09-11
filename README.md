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

