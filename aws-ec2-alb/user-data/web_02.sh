#!/bin/sh
apt update -y
apt install apache2 -y
echo "<img src='https://media.tenor.com/8mn-qJqothsAAAAC/two-marques-brownlee.gif'>" > /var/www/html/index.html