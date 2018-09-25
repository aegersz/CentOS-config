#!/usr/bin/env bash

#
# mirror live web system (SGT zone) to the intranet (AEST zone)
#

# ADJUST TIME OFFSET FOR DST !
diff=-2
bdate=$(date '+%d-%m-%Y' -d "$diff hours")
btime=$(date '+%d-%m-%Y_%H-%M-%S' -d "$diff hours")

echo
echo    Copy html directories as is ...
rsync   -zpaAPve ssh --delete --exclude-from=/data/exclusions-special root@site-name.org:/var/www/html/ /forum/html_special/
echo
echo    Merge html directories ...
rsync   -zpaAPve ssh --exclude-from=/data/exclusions root@site-name.org:/var/www/html/ /forum/html/
chown   -R apache:apache /var/www/html
echo
echo    Copy html directories locally ...
rsync   -paAPv /forum/html/ /var/www/html/
echo
echo    Copy database_smf209_$bdate.sql ...
rsync   -zpaAPve ssh root@site-name.org:/SQL/database_smf209_$bdate.sql \
                /forum/SQL/
echo
echo    Archive database_smf209_$bdate.sql to database_smf209_$btime.sql ...
rsync   -paAPv /forum/SQL/database_smf209_$bdate.sql \
                /forum/SQL/database_smf209_$btime.sql
echo
echo    Restore the database ...
mysql  -udbuser -pdbpass smf209 < /forum/SQL/database_smf209_$bdate.sql
echo
echo    "Run repair_settings.php !"
echo
echo    Copy root directories ...
rsync   -zpaAPve ssh --exclude-from=/data/exclusion2 root@site-name.org:/root/ /forum/root/
echo
echo    Copy bin directories ...
rsync   -zpaAPve ssh root@site-name.org:/bin/ /forum/bin/
echo
echo    Copy etc directories ...
rsync   -zpaAPve ssh root@site-name.org:/etc/ /forum/etc/
echo
echo    Copy the SMF unique files ...
rsync   -zpaAPve ssh --include-from=/data/inclusions --exclude="*" root@site-name.org:/var/www/html/ /forum/html_unique/
echo
echo    Copy the SQL unique files ...
rsync   -zpaAPve ssh root@site-name.org:/SQL/db*.sql /forum/SQL/
echo
echo    "Copy home directories (automailer) ..."
rsync   -zpaAPve ssh root@site-name.org:/home/automailer/ /forum/home/automailer/
echo
#rsync  -zpaAPve ssh root@site-name.org:/home/ /forum/home/
#rsync  -zpaAPve ssh root@site-name.org:/tmp/backup-config-manifests/ /forum/tmp
#rsync  -zpaAPve ssh root@site-name.org:/boot/ /forum/boot/
#rsync  -zpaAPve ssh root@site-name.org:/var/log/ /forum/var/log/

