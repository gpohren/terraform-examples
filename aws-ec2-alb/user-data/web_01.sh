#!/bin/sh
apt update -y
apt install apache2 -y
echo "<img src='https://media.tenor.com/-_UckaWN2AkAAAAC/one-michael.gif'>" > /var/www/html/index.html