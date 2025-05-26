#!/bin/bash


# REVOKE ALL ON database_name FROM 'username'@'host';
# DROP USER 'username'@'localhost';

# SQL command to create a table

CREATE USER 'admin'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;   
SCRIPT="
create database prism_dev;
"
# Execute the SQL command using the mysql command-line tool
mysql -u"root" -p"$MYSQL_ROOT_PASSWORD" -e "$SCRIPT"


# GRANT ALL PRIVILEGES ON auction_app.* TO 'admin'@'%' IDENTIFIED BY 'admin';
GRANT SELECT, INSERT, UPDATE, DELETE ON auction_app.* TO 'admin'@'%' IDENTIFIED BY 'admin';
