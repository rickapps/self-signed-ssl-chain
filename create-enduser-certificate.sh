#!/bin/bash
# Edit the four lines below to suit 
country_code="US"
state_province="Colorado"
city_town="Denver"
dept_name="SSL\/TLS"

# You will need to edit the following lines to match the paths to your files.
# End user certs can be signed by either the root or intermediate CA.
signing_key="./intermediate_key.pem"
signing_cert="./intermediate.crt"
enduser_ext="./enduser.ext"

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
read -p "Enter the password you want to use for private key file: " password
# verify the password
read -p "Enter the password again: " password2
if [ "$password" == "$password2" ]; then
break
else
echo "Passwords do not match. Try again."
fi
done

# check for root certificate and private key files
if [ ! -f $signing_cert ] || [ ! -f $signing_key ] || [ ! -f $enduser_ext ]; then
    echo "Necessary support files not found. Run create-certificate-chain.sh first or alter this script."
    exit 1
fi

# Name the end user cert file and private key file.
enduser_cert=${domain_name}".crt"
enduser_key=${domain_name}".key"


if [ "$isWildCard" = true ] 
then
echo subjectAltName=DNS:${domain_name},DNS:*.${domain_name} | cat $enduser_ext - > enduserTmp.ext
domain_name="*."${domain_name}
else     
cp $enduser_ext enduserTmp.ext
fi                           

# Create a new private key for our end user cert.
# If we were renewing a root cert or an intermediate cert, we would reuse the original private key if we
# knew it was still secure. Generating a new key would break our chain and we would need to reissue all the
# end user certs that were signed by the root or intermediate cert.
openssl genrsa -des3 -passout pass:$password -out $enduser_key 4096

# Create a certificate signing request.
openssl req -new -key $enduser_key -passin pass:$password -out enduser.csr -subj "/C=$country_code/ST=$state_province/L=$city_town/O=$company_name/OU=$dept_name/CN=$domain_name"
# Create the enduser cert signed by the intermediate or root cert.
openssl x509 -CA $signing_cert -CAkey $signing_key -passin pass:$password -days 730 -req -in enduser.csr -out $enduser_cert -extfile enduserTmp.ext
# Remove the temporary file.
rm enduserTmp.ext
# Display the end user cert.
openssl x509 -in $enduser_cert -text -noout