### Overview ###
Create SSL certificates for private domains that are automatically trusted by all the web browsers on your intranet. This is perfect for private web servers or development websites. Establish a certificate chain that works identically to SSL certificates you purchase from a certificate authority such as Google or GoDaddy. Create a root CA one time and install it to all the machines on your network. After that task is complete, you can issue multiple SSL certificates that will automatically be trusted by all the web browsers on your network. This project and the accompaning gists will provide all the information you need to create and install trusted websites.

### Environment ###
**openssl:** Version 3.2.2 or later. You can download openssl from [OpenSSL Foundation](https://openssl-foundation.org) if it's not already present on your machine. The included shell scripts are for linux, but the openssl commands contained can be easily copied to Windows.

### Description of Files ###
- self-signed-cert.sh:
- Notes.txt:


