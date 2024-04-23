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

# Install Apache (newer version)
install_component "2.4.54" "https://archive.apache.org/dist/httpd/httpd-2.4.54.tar.gz" "apache"

# Install MariaDB (use apt installation)
sudo apt install -y mariadb-server

# Install PHP (newer version)
install_component "8.1.4" "https://www.php.net/distributions/php-8.1.4.tar.gz" "php"

# Start Apache
sudo "$installation_dir/apache/bin/apachectl" start

echo "Installation completed."
