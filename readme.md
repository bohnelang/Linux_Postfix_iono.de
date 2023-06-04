# Postfix mit IONOS und Postfix zum Versenden von eMails konfigurieren

## Vorgehen:
Bei der Neueinrichtung folgte ich den Anleitungen von IONOS, welche eine Konfiguration vorgaben:
https://www.ionos.de/hilfe/e-mail/weitere-e-mail-programme/postfix-linux-einrichten/

Leider war Ubuntu und Postfix damit nicht zum Versenden von eMails zu bewegen.

## Problem:
Das Versenden war nicht möglich - entweder gab einen 550 oder einen 451 Fehler. 

- 550-Requested action not taken: mailbox unavailable 550 invalid DNS MX or A/AAAA resource record (in reply to MAIL FROM command))
- 451 Requested action aborted: local error in processing (in reply to MAIL FROM command))

IONOS nimmt eine Absender-Verifikation der Sender-Domain vor. 

## Lösung:
Schlussendlich musste ich "nur" das Absender-From auf den Mail-Accound ändern:
```
sender_canonical_maps = static:mail@ihre-webhosting-domain.de
local_header_rewrite_clients = static:all
```

So dass sich folgende erweiterte Konfig ergibt:
```
# Set external SMTP relay host here IP or hostname accepted along with a port number.
relayhost = smtp.ionos.de:587

# Enable auth
smtp_use_tls = yes
smtp_sasl_auth_enable = yes

# Set username and password
smtp_sasl_password_maps =  static:mail@ihre-webhosting-domain.de:ihr-passwort
smtp_sasl_security_options = noanonymous

# Turn on tls encryption
smtp_tls_security_level = encrypt
smtp_tls_mandatory_ciphers = high
smtp_tls_mandatory_protocols = >=TLSv1.2

header_size_limit = 4096000

# Set sender header and domain to valid
# or set sender_canonical_maps = hash:/etc/postfix/sender_canonical with <user>@<host> <official emial>

sender_canonical_maps = static:mail@ihre-webhosting-domain.de
local_header_rewrite_clients = static:all

# Force logging in an extra file
maillog_file=/var/log/postfix.log
maillog_file_permissions=0644 # (Postfix 3.9 and later)
```

## Installieren:
```
curl  https://raw.githubusercontent.com/bohnelang/Linux_Postfix_ionos.de/main/ionos_postfix.sh > ionos_postfix.sh
. ionos_postfix.sh
```

## Epilog:
Ich habe ionos.de das mal als Feedback zu der Seite mitgeteilt...
