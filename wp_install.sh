#!/bin/bash
# Writing question velue on variables 
echo "Please, type mysql root password Ex:WGds2213DS"
read dbpsw
echo "Please, type wordpress database name Ex:wp_db"
read dbname
echo "Please, type wordpress database user Ex:wp_usr"
read dbwpuser
echo "Please, type wordpress user password Ex:ghHH6544@dd"
read wppsw

# installing packets needed
echo "Installing database system...........Please wait"
yum install -y vim httpd mariadb-server wget php php-mysql > /tmp/wp_install.log
echo "Done........................................[OK]"
echo -e "************************************************\n" >> /tmp/wp_install.log
echo "Starting database system.............Please wait"
systemctl start mariadb.service httpd.service >> /tmp/wp_install.log
echo "Done........................................[OK]"
echo "Enabling database system.............Please wait"
systemctl enable mariadb.service httpd.service 2>> /tmp/wp_install.log
echo "Done........................................[OK]"
echo -e "************************************************\n" >> /tmp/wp_install.log  

# configuring mysql
echo "Configuring database.................Please wait"
echo -e "\n\n"$dbpsw"\n"$dbpsw"\n\n\n\n" | mysql_secure_installation 2>> /tmp/wp_install.log  >> /tmp/wp_install.log 
echo "Done........................................[OK]"
echo -e "************************************************\n" >> /tmp/wp_install.log 

# creating wordpress database
echo "Creating database....................Please wait"
mysql -u root -p"$dbpsw" <<EOF1
CREATE DATABASE $dbname;
CREATE USER '$dbwpuser'@'localhost' IDENTIFIED BY '$wppsw';
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbwpuser'@'localhost';
FLUSH PRIVILEGES;
EOF1
echo "Done........................................[OK]"

# Downloading wordpress
echo "Downloading wordpress................Please wait"
cd /var/www/html/
wget -q https://wordpress.org/latest.tar.gz
tar -xf latest.tar.gz
echo "Done........................................[OK]"

# Configuring wp-config.php
echo "Configuring wp-config.php............Please wait"
sed 's/database_name_here/'$dbname'/g' /var/www/html/wordpress/wp-config-sample.php | sed 's/username_here/'$dbwpuser'/g' | sed 's/password_here/'$wppsw'/g' > /var/www/html/wordpress/wp-config.php
echo "Done........................................[OK]"

# Configuring firewall rules
echo "Configuring firewall rules...........Please wait"
firewall-cmd --permanent --add-service=http >> /tmp/wp_install.log
firewall-cmd --reload >> /tmp/wp_install.log
echo "Done........................................[OK]"
echo -e "************************************************\n" >> /tmp/wp_install.log
echo "Restaring httpd service..............Please wait"
systemctl restart httpd.service
echo "Done........................................[OK]"

echo "************************************************************"
echo "* mysql password was set as $dbpsw                          "
echo "* wordpress database name was set as $dbname                "
echo "* wordpress database user was set as $dbwpuser              "
echo "* wordpress database password was set as $wppsw             "
echo "************************************************************"
