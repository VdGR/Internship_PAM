#!/bin/bash
# source: https://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/
# https://askubuntu.com/questions/304999/not-able-to-execute-a-sh-file-bin-bashm-bad-interpreter
#update, upgrade 
#sudo apt -y update 
#sudo apt -y upgrade
#install mysql
sudo apt -y install mysql-server 
sudo mysql --user=root -p$1 -e "UPDATE mysql.user SET authentication_string = PASSWORD('$1') WHERE User='root';"
sudo mysql --user=root -p$1 -e "UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root';"
sudo mysql --user=root -p$1 -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql --user=root -p$1 -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql --user=root -p$1 -e "DROP DATABASE IF EXISTS test;"
sudo mysql --user=root -p$1 -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql --user=root -p$1 -e "FLUSH PRIVILEGES;"
