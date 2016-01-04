#!/bin/bash

#Deklarasi variable warna
Merah='\033[0;31m'
batas='\033[0m'

printf "${Merah}LAMP FROM Source Installer by Dias${batas}\n"

function buildtools(){
#sudo apt-get update && sudo apt-get -y upgrade
 sudo apt-get -y install build-essential
 sudo apt-get -y install python-dev
 sudo apt-get -y install libaio1 libaio-dev
}

function apache()
{
printf "${Merah}Membuat direktori tampung sementara${batas}\n"
 mkdir apachebin
 cd apachebin

#Download Source File yang dibutuhkan

printf "${Merah}Downloading Apache Source${batas}\n"
wget --progress=dot http://mirror.wanxp.id/apache//httpd/httpd-2.4.18.tar.gz 2>&1
printf "${Merah}Downloading Apr Source${batas}\n"
wget --progress=dot http://mirror.wanxp.id/apache//apr/apr-1.5.2.tar.gz 2>&1
printf "${Merah}Downloading Apr-Util Source${batas}\n"
wget --progress=dot http://mirror.wanxp.id/apache//apr/apr-util-1.5.4.tar.gz 2>&1
printf "${Merah}Downloading PCRE (Perl Compatible Regular Expression) Source${batas}\n"
wget --progress=dot ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz 2>&1

#Unpack seluruh file TAR

printf "${Merah}Unpacking Source File...${batas}\n"
tar -xvf httpd-2.4.18.tar.gz
tar -xvf apr-1.5.2.tar.gz
tar -xvf apr-util-1.5.4.tar.gz
tar -xvf pcre-8.37.tar.gz

#Memindahkan File APR

mv apr-1.5.2 httpd-2.4.18/srclib/apr
mv apr-util-1.5.4 httpd-2.4.18/srclib/apr-util

#Konfigurasi PCRE

printf "${Merah}Memulai konfigurasi untuk PCRE${batas}\n"
cd  pcre-8.37
printf "${Merah}Prefix yang digunakan /usr/local/pcre${batas}\n"
./configure --prefix=/usr/local/pcre
printf "${Merah}Menjalankan perintah Make${batas}\n"
make
printf "${Merah}Menjalankan perintah Make Install${batas}\n"
make install

#Konfigurasi & Enable Module pada Apache
cd ..
cd httpd-2.4.18

#Konfigurasi untuk Apache
./configure --prefix=/usr/local/apache --with-included-apr --with-pcre=/usr/local/pcre --enable-ssl --enable-headers --enable-so

printf "${Merah}Jalankan perintah Make${batas}\n"
make

printf "${Merah}Jalankan perintah Make Install${batas}\n"
make install

printf "${Merah}Menjalankan Service Apache${batas}\n"
cd /usr/local/apache/bin
./apachectl start

printf "${Merah}Apache berhasil di install coba akses localhost / 127.0.0.1${batas}\n"
}

function php(){
printf "${Merah}Membuat direktori tampung sementara untuk source php & Libxml${batas}\n"
if [ ! -d "phpbin" ]; then
mkdir phpbin
fi
cd phpbin

printf "${Merah}Downloading Sources${batas}\n"
wget --progress=dot http://php.net/distributions/php-5.6.16.tar.gz 2>&1
wget --progress=dot  http://xmlsoft.org/sources/libxml2-2.9.3.tar.gz 2>&1

printf "${Merah}Extracting Sources${batas}\n"
tar -xvf  php-5.6.16.tar.gz
tar -xvf  libxml2-2.9.3.tar.gz

printf "${Merah}Installing Libxml${batas}\n"
cd libxml2-2.9.3

printf "${Merah}Konfigurasi Libxml${batas}\n"
 ./configure --prefix=/usr/local --disable-static --with-history 

printf "${Merah}Menjalankan perintah Make${batas}\n"
make

printf "${Merah}Menjalankan perintah make install ${batas}\n"
make install

cd ..

printf "${Merah}Memulai instalasi PHP ${batas}\n"
 cd php-5.6.16
printf "${Merah}Konfigurasi PHP untuk meload otomatis ekstensi Mysql${batas}\n"
 ./configure --with-apxs --with-mysql=mysqlnd --with-mysqli=mysqlnd

printf "${Merah}Perintah wajib untuk PHP (make test)${batas}\n"
make test

printf "${Merah}Menjalankan perintah Make${batas}\n"
make

printf "${Merah}Menjalankan perintah make install ${batas}\n"

make install

printf "${Merah}Konfigurasi agar module php terload otomatis dengan apache${batas}\n"
printf "Menghapus httpd.conf dan mengganti dengan yang baru\n"

target="/usr/local/apache/conf/httpd.conf"
if [ -f "$target" ]
then
 rm /usr/local/apache/conf/httpd.conf"
 printf "Downloading new httpd.conf"
 cd /usr/local/apache/conf
 wget -O wget -O httpd.conf http://pastebin.com/raw/bT84QFKN
else
 printf "${Merah}File konfigurasi tidak ditemukan, instalasi dibatalkan${batas}\n"
 exit 0
fi

 cd /usr/local/apache/bin/

printf "${Merah}Menjalankan ulang service apache${batas}\n"
./apachectl stop
./apachectl start

printf "${Merah}Membuat file php untuk percobaan${batas}\n"
echo "<?php phpinfo(); ?>" > /usr/local/apache/htdocs/coba.php

printf "${Merah} file berhasil dibuat pada direktori /usr/local/apache/htdocs/coba.php${batas}\n"

}

PS3='Silahkan dipilih :'
opsi=("Install Build Tools" "Download & Install Apache From Source" "Download & Install PHP from Source" "Keluar")

select opt in "${opsi[@]}"
do

case $opt in
	"Install Build Tools")
	buildtools
	;;
	"Download & Install Apache From Source")
	apache
	;;
	"Download & Install PHP from Source")
	php
	;;
	"Keluar")
	exit 0
	;;
*) echo invalid Option;;
esac
done


