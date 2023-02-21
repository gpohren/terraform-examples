#!/bin/sh
apt update -y
apt install apache2 -y
echo "<img src='https://media.tenor.com/cdgu_rxP5vwAAAAd/cat-hiss.gif'>" > /var/www/html/index.html