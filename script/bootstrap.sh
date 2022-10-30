#!/bin/bash

host=$(hostname -f)
a="<html> <head> <title>MyApp</title> <style>"
b="body {margin-top: 40px; background-color: #1874cd;} </style>"
c="</head><body> <div style=color:white;text-align:center>"
d="<h1>Amazon EC2 Apache App</h1>"
e="<h2>Congratulations!</h2>"
f="<p>Apache server running on EC2: <b>${host:0:13}</b>"
g="${host:13}.</p></div></body></html>"
message="${a} ${b} ${c} ${d} ${e} ${f}${g}"

yum update
yum install httpd -y
systemctl start httpd.service
systemctl enable httpd.service
echo ${message} | sudo tee /var/www/html/index.html