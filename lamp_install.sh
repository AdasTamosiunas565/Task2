#!/bin/bash

# Function to download, extract, compile, and install software
download_compile_install() {
  URL=$1
  FILENAME=$(basename "$URL")
  DIRNAME=$(basename "$FILENAME" .tar.gz)

  # Download
  wget "$URL"
  if [ $? -ne 0 ]; then
    echo "Failed to download $FILENAME"
    exit 1
  fi

  # Extract
  tar -xzvf "$FILENAME"
  if [ $? -ne 0 ]; then
    echo "Failed to extract $FILENAME"
    exit 1
  fi

  # Compile and install
  cd "$DIRNAME" || exit
  ./configure --prefix=/opt/"$DIRNAME"
  make
  sudo make install
  if [ $? -ne 0 ]; then
    echo "Failed to compile and install $DIRNAME"
    exit 1
  fi
}

# Install Apache
echo "Installing Apache..."
download_compile_install https://archive.apache.org/dist/httpd/httpd-2.4.52.tar.gz

# Install MariaDB
echo "Installing MariaDB..."
download_compile_install https://downloads.mariadb.org/interstitial/mariadb-10.7.3/source/mariadb-10.7.3.tar.gz

# Install PHP
echo "Installing PHP..."
download_compile_install https://www.php.net/distributions/php-8.1.4.tar.gz

# Start Apache
echo "Starting Apache..."
/opt/httpd-2.4.52/bin/apachectl start

# Start MariaDB
echo "Starting MariaDB..."
/opt/mariadb-10.7.3/bin/mysqld_safe &

# Test Apache
echo "Testing Apache..."
curl http://localhost:80

# Test PHP
echo "Testing PHP..."
/opt/php-8.1.4/bin/php -v

# Test MariaDB
echo "Testing MariaDB..."
/opt/mariadb-10.7.3/bin/mysql --version

echo "LAMP stack installation completed successfully!"
