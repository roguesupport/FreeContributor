#!/usr/bin/env bash
#
# FreeContributor: Enjoy a safe and faster web experience
# (c) 2016 by TBDS
# https://github.com/tbds/FreeContributor
#
# FreeContributor is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dependencies: tcpdump, php
# php parser made by jtai
# https://gist.github.com/jtai/1368338
# original article:
# http://jontai.me/blog/2011/11/monitoring-dns-queries-with-tcpdump/
#
# if systemd is installed you can use journalctl
#
#journalctl -u dnsmasq.service > dns-queries
#
#

DATE=`date +%Y-%m-%d`

rootcheck(){
  if [[ $UID -ne 0 ]]; then
    echo "You need root or su rights acess internet card"
    echo "Please run this script as root (like a boss)"
    exit 1
  fi
}

scan_dns_queries() {
    tcpdump -vvv -s 0 -l -n port 53 | \
    php parse-tcpdump-udp-port-53.php -f >> dns-queries-${DATE} &
}

rootcheck
scan_dns_queries