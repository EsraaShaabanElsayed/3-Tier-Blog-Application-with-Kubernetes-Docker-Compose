#!/bin/bash
mkdir -p certs/
cd certs/
openssl genrsa -out  nginx-selfsigned.key 2048
openssl req -new -x509 -key nginx-selfsigned.key -out nginx-selfsigned.crt -days 365 -subj "/CN=blog-app.com/O=GoApp/C=EG"