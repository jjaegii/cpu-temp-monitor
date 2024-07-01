#!/bin/sh

cat <<EOL >> /etc/msmtprc
account default
host $SMTP_HOST
port $SMTP_PORT
from $SMTP_USER
user $SMTP_USER
password $SMTP_PASS
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
EOL

while true; do
  temp=$(sensors | awk '/^Package id 0/ {print $4}' | sed 's/+//;s/°C//')
  if [ $(echo "$temp > 70" | bc) -eq 1 ]; then
    echo -e "Subject: CPU Temperature Alert\n\nCPU temperature is above 70°C: $temp°C" | msmtp -a default $EMAIL_TO
  fi
  sleep 60
done
