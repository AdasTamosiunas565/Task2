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
        tar -xzvf /tmp/$(basename "$url") -C /tmp

        # Compile and install
        cd /tmp/$(basename "$url" .tar.gz)
        ./configure --prefix="$installation_dir/$dir_name"
        make && sudo make install
    fi
}

# Install Apache
install_component "2.4.52" "https://archive.apache.org/dist/httpd/httpd-2.4.52.tar.gz" "apache"

# Install MariaDB
install_component "10.7.1" "https://downloads.mariadb.org/interstitial/mariadb-10.7.1/source/mariadb-10.7.1.tar.gz" "mariadb"

# Install PHP
install_component "8.1.3" "https://www.php.net/distributions/php-8.1.3.tar.gz" "php"

# Start Apache and MariaDB
sudo "$installation_dir/apache/bin/apachectl" start
sudo "$installation_dir/mariadb/bin/mysqld_safe" --datadir="$installation_dir/mariadb/data" &

echo "Installation completed."
