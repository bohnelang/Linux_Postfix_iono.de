#!/bin/bash

if ! test "$(whoami)" = "root"
then
        echo "You must be root"
        exit 1
fi

apt-get install sasl2-bin libsasl2-2 ca-certificates  libsasl2-modules mailutils


echo
echo "Config system for ionos.de: "
echo
echo "Use Internet-site at postix configuration"
echo
sleep 3
apt-get install  postfix

if test -e /etc/postfix/main.cf
then

clear

echo
echo "Config system for ionos.de"
echo
read -p "Enter the login-email address for ionos.de account: " email

if test "$(cat /etc/postfix/main.cf|grep ${email})" = ""
then

echo
read -s -p "Password: " password
echo

cp /etc/postfix/main.cf /etc/postfix/main.cf.save_$(date +"%s")

T=/tmp/p.$$
cat /etc/postfix/main.cf | grep -v relayhost | grep -v smtp_tls_security_level > $T
mv -f $T /etc/postfix/main.cf

cat >> /etc/postfix/main.cf <<_EOF_
####################################################################################
# Hilfreich
# https://www.ionos.de/hilfe/e-mail/weitere-e-mail-programme/postfix-linux-einrichten/
# https://wiki.ubuntuusers.de/Postfix/Erweiterte_Konfiguration/
#

# Set external SMTP relay host here IP or hostname accepted along with a port number.
relayhost = smtp.ionos.de:587

# Enable auth
smtp_use_tls = yes
smtp_sasl_auth_enable = yes

# Set username and password
smtp_sasl_password_maps =  static:${email}:${password}
smtp_sasl_security_options = noanonymous

# Turn on tls encryption
smtp_tls_security_level = encrypt
smtp_tls_mandatory_ciphers = high
smtp_tls_mandatory_protocols = >=TLSv1.2

header_size_limit = 4096000

# Set sender header and domain to valid
# or set sender_canonical_maps = hash:/etc/postfix/sender_canonical with <user>@<host> <official emial>

sender_canonical_maps = static:${email}
local_header_rewrite_clients = static:all

# Force logging in an extra file
maillog_file=/var/log/postfix.log
maillog_file_permissions=0644 # (Postfix 3.9 and later)


####################################################################################
_EOF_



# only root can read password in config file
chmod 600  /etc/postfix/main.cf

systemctl reload postfix

echo "This is a test." | mail -s "test message" ${email}

tail /var/log/postfix.log

else
echo "System alrady configured"
fi
fi
