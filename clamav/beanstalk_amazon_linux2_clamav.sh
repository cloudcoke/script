#!/bin/bash

cp /etc/clamd.d/scan.conf /etc/clamd.d/scan.conf.bak

cat <<EOF > /etc/clamd.d/scan.conf
LogFile /var/log/clamd.scan
LogTime yes

LocalSocket /run/clamd.scan/clamd.sock
LocalSocketGroup virusgroup
LocalSocketMode 660

ExcludePath ^/proc/
ExcludePath ^/sys/

User root

OnAccessIncludePath /home
OnAccessPrevention yes
OnAccessExtraScanning yes
OnAccessExcludeRootUID yes
OnAccessExcludeUname clamav
EOF

cp /etc/freshclam.conf /etc/freshclam.conf.bak

sed -i 's|#LogSyslog yes|LogSyslog yes|g' /etc/freshclam.conf
sed -i 's|#NotifyClamd /path/to/clamd.conf|NotifyClamd /etc/clamd.d/scan.conf|g' /etc/freshclam.conf

freshclam

systemctl enable --now clamd@scan clamav-clamonacc.service clamav-freshclam.service