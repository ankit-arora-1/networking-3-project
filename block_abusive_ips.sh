#!/bin/bash

LOG_FILE="/var/log/nginx/access.log"
BLOCKED_IPS="/etc/nginx/conf.d/block_ips.conf"

ABUSIVE_IPS=$(awk -v min_time="$(date --date="1 minute ago" "+%d/%b/%Y:%H:%M:%S")" '$4 > min_time {print $1}' $LOG_FILE | sort | uniq -c | awk '$1 > 5 {print $2}')

for ip in $ABUSIVE_IPS; do
         if ! grep -q "$ip" $BLOCKED_IPS; then
                 echo "deny $ip;" >> $BLOCKED_IPS
                 echo "Blocked the following ip: $ip"
         fi
done

sudo systemctl reload nginx
sudo systemctl restart nginx
