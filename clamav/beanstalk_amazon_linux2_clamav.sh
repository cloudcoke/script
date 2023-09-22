#!/bin/bash

sudo cp /etc/clamd.d/scan.conf /etc/clamd.d/scan.conf.bak

sudo bash -c 'cat <<EOF > /etc/clamd.d/scan.conf
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
EOF'

sudo cp /etc/freshclam.conf /etc/freshclam.conf.bak

sudo sed -i 's|#LogSyslog yes|LogSyslog yes|g' /etc/freshclam.conf
sudo sed -i 's|#NotifyClamd /path/to/clamd.conf|NotifyClamd /etc/clamd.d/scan.conf|g' /etc/freshclam.conf

sudo freshclam

sudo systemctl enable --now clamd@scan clamav-clamonacc.service clamav-freshclam.service