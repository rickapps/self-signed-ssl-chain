### Overview ###
 Create your own **trusted** SSL (TLS) certificates for intranet websites. Create and add additional SSL certificates  without needing to update all web browsers in the organization. Structure the SSL certificate chains to mimic public internet websites so your private intranet can reliably be used for development and testing of internet websites. 

### Method ###
Create a root CA one time and install it to all the machines on your network. After that task is complete, you can issue multiple SSL certificates that will automatically be trusted by all the web browsers on your network. This project and the accompaning gists will provide all the information you need to create and install trusted certificates.                          

### Environment ###
**openssl:** Version 3.2.2 or later. You can download openssl from [OpenSSL Foundation](https://openssl-foundation.org) if it's not already present on your machine. The included bash shell scripts are for linux, but the openssl commands contained will be the same for Windows.

### Description of Files ###  
- **create-certificate-chain.sh:** Bash shell script to create the certificate chain
- **create-enduser-certificate.sh** Bash shell script to create additional certificates
- **rootCA.ext:** X.509 Extensions required for a root certificate
- **intermediate.ext:** X.509 Extensions that allow a cert to sign other certs
- **enduser.ext:** Recommended X.509 extensions for a server certificate
- **Notes.txt:** The notes used to create this project

### Other sources of information ###
- [Adding X.509 extensions to your certificates](https://www.golinuxcloud.com/add-x509-extensions-to-certificate-openssl/)
- [OpenSSL Command Cheatsheet](https://www.freecodecamp.org/news/openssl-command-cheatsheet-b441be1e8c4a/)
- [How Certificate Chains Work](https://gist.github.com/rickapps/46d6735f6cef593807939b617f1c900a)
- [How to Create SSL Certificate Chains](https://gist.github.com/rickapps/46d6735f6cef593807939b617f1c900a)
- Self-signed Certificates your Browser will Trust