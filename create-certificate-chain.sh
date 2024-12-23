#!/bin/bash
# Edit the four lines below to suit 
country_code="US"
state_province="Colorado"
city_town="Denver"
dept_name="SSL\/TLS"

read -p "Name of your company? " company_name
read -p "Domain name for your intranet? " domain_name
while true; do
read -p "Wildcard? Include all subdomains for this domain? (y/n) " yn
case $yn in
    [yY] ) isWildCard=true
    break;;
    [nN] ) isWildCard=false
    break;;
    * ) echo Answer y or n
esac
done
read -p "Your email address? " email_address
while true; do
read -p "Enter the password you want to use for private key files: " password
# verify the password
read -p "Enter the password again: " password2
if [ "$password" == "$password2" ]; then
break
else
echo "Passwords do not match. Try again."
fi
done

root_CN_name=${company_name}" Root CA"
intermediate_CN_name=${company_name}" Intermediate CA"
if [ "$isWildCard" = true ] 
then
echo subjectAltName=DNS:${domain_name},DNS:*.${domain_name} | cat enduser.ext - > enduserTmp.ext
domain_name="*."${domain_name}
else     
cp enduser.ext enduserTmp.ext
fi                           
# Create our three private/public key pairs; root, intermediate, enduser
# All three files will be encrypted with the same password.
openssl genrsa -des3 -passout pass:$password -out rootCA_key.pem 4096
openssl genrsa -des3 -passout pass:$password -out intermediate_key.pem 4096
openssl genrsa -des3 -passout pass:$password -out enduser_key.pem 4096

# Create three certificate signing requests.
openssl req -new -key rootCA_key.pem -passin pass:$password -out rootCA.csr -subj "/C=$country_code/ST=$state_province/L=$city_town/O=$company_name/OU=$dept_name/CN=$root_CN_name"
openssl req -new -key intermediate_key.pem -passin pass:$password -out intermediate.csr -subj "/C=$country_code/ST=$state_province/L=$city_town/O=$company_name/OU=$dept_name/CN=$intermediate_CN_name"
openssl req -new -key enduser_key.pem -passin pass:$password -out enduser.csr -subj "/C=$country_code/ST=$state_province/L=$city_town/O=$company_name/OU=$dept_name/CN=$domain_name"

# Create the root certificate. It is signed using the same private key used to create the request.
# Note that this alone does not make it a valid root. It also must contain certain X.509 extensions
# such as CA:TRUE
openssl x509 -req -in rootCA.csr -key rootCA_key.pem -passin pass:$password -days 1825 -out rootCA.crt -extfile rootCA.ext
# Create the intermediate certificate. X.509 extension CA:TRUE must also be applied to this certificate so it can sign others.
openssl x509 -CA rootCA.crt -CAkey rootCA_key.pem -passin pass:$password -days 1825 -req -in intermediate.csr -out intermediate.crt -extfile intermediate.ext
# Create the enduser cert signed by the intermediate cert.
openssl x509 -CA intermediate.crt -CAkey intermediate_key.pem -passin pass:$password -days 730 -req -in enduser.csr -out enduser.crt -extfile enduserTmp.ext

# Convert the root cert to a pem file so it can be added to the trusted store
# Copy the pem file to /etc/pki/ca-trust/source/anchors, then run update-ca-trust
# Above is for fedora, location and update store command varies with distribution. 
openssl x509 -in rootCA.crt -out rootCA.pem -outform PEM
# Convert the other two certificates into PEM files so they can be added to your webserver
# You will also need to add enduser_key.pem to your webserver store. You may need to
# remove the password protection prior to uploading.
openssl x509 -in intermediate.crt -out intermedidate_cert.pem -outform PEM
openssl x509 -in enduser.crt -out enduser_cert.pem -outform PEM