#!/bin/bash
country_code="US"
state_province="Colorado"
city_town="Denver"
dept_name="SSL/TLS"

read -p "Name of your company?" company_name
read -p "Domain name to for your intranet?" domain_name
read -p "Your email address?" email_address

root_CA_name= "${company_name} Root CA"
intermediate_CA_name= "${company_name} Intermediate CA"

# Create our three private/public key pairs; root, intermediate, enduser
# All three files will be encrypted with the same password.
openssl genrsa -des3 -passout pass:$password -out rootCA_key.pem 4096
openssl genrsa -des3 -passout pass:$password -out intermediate_key.pem 4096
openssl genrsa -des3 -passout pass:$password -out enduser_key.pem 4096

# Create three certificate signing requests.
openssl req -new -key rootCA_key.pem -out rootCA.csr -subj "/C=$country_code/ST=$state_province/L=$city_town/O=$company_name/OU=$dept_name/CN=$root_CA_name"
openssl req -new -key intermediate_key.pem -out intermediate.csr -subj "/C=$country_code/ST=$state_province/L=$city_town/O=$company_name/OU=$dept_name/CN=$intermediate_CA_name"
openssl req -new -key enduser_key.pem -out enduser.csr -subj "/C=$country_code/ST=$state_province/L=$city_town/O=$company_name/OU=$dept_name/CN=$domain_name"

exit 1

# Create a private key that is used to sign the root cert. Store in file ca.key
openssl genrsa -out ca.key 4096
# Create self-signed root cert
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt

# Generate a private key for the intermediate certificate signing request
openssl genrsa -out private_keyA.key 4096
# Create the request
openssl req -new -key private_keyA.key -out requestA.csr

# Sign your request with the root key
openssl x509 -req -days 1095 -in requestA.csr -signkey ca.key -out intermediate_cert.crt



openssl x509 -signkey ca.key -days 1095 -req -in ca.csr -set_serial 01 -out ca.crt
# Look at the cert
openssl x509 -text -noout -in domain.crt
# Create intermediate request. Sign the request with the intermediate key
openssl req -new -newkey rsa:4096 -nodes -out inter.csr -keyout inter.key -addext basicConstraints=CA:TRUE
# Sign the intermediate request with the root's CA key
openssl x509 -CA ca.crt -CAkey ca.key -days 365 -req -in inter.csr -set_serial 02 -out inter.crt
# Create the top-level certificate request
openssl req -new -newkey rsa:4096 -nodes -out test.csr -keyout test.key
openssl x509 -CA inter.crt -CAkey inter.key -days 365 -req -in test.csr -set_serial 03 -out test.crt
