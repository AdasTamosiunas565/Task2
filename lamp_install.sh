#!/bin/bash

# System update
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential wget

# Installation directory
installation_dir="/opt"

# Function to download, extract, compile, and install software
download_compile_install() {
  local url="$1"
  local dir_name="$2"

  # Check if component is already installed
  if [ ! -d "$installation_dir/$dir_name" ]; then
      # Download and extract
      wget -P /tmp "$url"
      tar -xzvf "/tmp/$(basename "$url")" -C /tmp

      # Compile and install
      cd "/tmp/$(basename "$url" .tar.gz)"
      ./configure --prefix="$installation_dir/$dir_name"
      make
      if [ $? -ne 0 ]; then
          echo "Failed to compile $dir_name"
          exit 1
      fi
      sudo make install
      if [ $? -ne 0 ]; then
          echo "Failed to install $dir_name"
          exit 1
      fi
  fi
}

# Install Apache
echo "Installing Apache..."
download_compile_install "https://archive.apache.org/dist/httpd/httpd-2.4.52.tar.gz" "apache"

# Install MariaDB
echo "Installing MariaDB..."
download_compile_install "https://downloads.mariadb.org/interstitial/mariadb-10.7.1/source/mariadb-10.7.1.tar.gz" "mariadb"

# Install PHP
echo "Installing PHP..."
download_compile_install "https://www.php.net/distributions/php-8.1.3.tar.gz" "php"

# Start Apache
echo "Starting Apache..."
sudo "$installation_dir/apache/bin/apachectl" start

# Start MariaDB
echo "Starting MariaDB..."
sudo "$installation_dir/mariadb/bin/mysqld" --basedir="$installation_dir/mariadb" --datadir="$installation_dir/mariadb/data" --pid-file="$installation_dir/mariadb/mysqld.pid" --socket="$installation_dir/mariadb/mysql.sock" --port=3306 --user=mysql &

# Test Apache
echo "Testing Apache..."
curl http://localhost:80

# Test PHP
echo "Testing PHP..."
"$installation_dir/php/bin/php" -v

# Test MariaDB
echo "Testing MariaDB..."
"$installation_dir/mariadb/bin/mysql" --version

echo "LAMP stack installation completed successfully!"
