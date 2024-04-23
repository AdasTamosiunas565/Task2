#!/bin/bash

# System update
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential wget

# Installation directory
installation_dir="/opt"

# Function to download, extract, compile, and install a component
install_component() {
    local version="$1"
    local url="$2"
    local dir_name="$3"

    # Check if component is already installed
    if [ ! -d "$installation_dir/$dir_name" ]; then
        # Download and extract
        wget -P /tmp "$url"
        tar -xzvf "/tmp/$(basename "$url")" -C /tmp

        # Compile and install
        cd "/tmp/$(basename "$url" .tar.gz)"
        ./configure --prefix="$installation_dir/$dir_name"
        make && sudo make install
    fi
}

# Install Apache 2.2.34 (older version)
install_component "2.2.34" "https://archive.apache.org/dist/httpd/httpd-2.2.34.tar.gz" "apache"

# Install MariaDB 10.3.31 (older version)
install_component "10.3.31" "https://downloads.mariadb.org/interstitial/mariadb-10.3.31/source/mariadb-10.3.31.tar.gz" "mariadb"

# Install PHP 7.4.27 (older version)
install_component "7.4.27" "https://www.php.net/distributions/php-7.4.27.tar.gz" "php"

# Start Apache
sudo "$installation_dir/apache/bin/apachectl" start

# Start MariaDB
sudo "$installation_dir/mariadb/bin/mysqld" --basedir="$installation_dir/mariadb" --datadir="$installation_dir/mariadb/data" --pid-file="$installation_dir/mariadb/mysqld.pid" --socket="$installation_dir/mariadb/mysql.sock" --port=3306 --user=mysql &
