# self-signed-ssl-chain
Creates SSL root certificate, intermediate cert, and individual site certificate that your browser will trust.

## Scenario ##
You have several internal/development sites you want your web browsers to trust, but you don't want to modify all your browsers every time you add or change intranet sites.

## Solution ##
Create a single root certificate and add it all the browsers on your network. All future self-signed-certs you create will be trusted by this single root certificate. You no longer need to install additional certs to your web browser every time you create a new cert.