#!/bin/sh
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
#
# Mirrors sources
#

sources1=(\
##   'https://adaway.org/hosts.txt' \
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/adaway.org/hosts' \
##   'http://www.malwaredomainlist.com/hostslist/hosts.txt' \
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/malwaredomainlist.com/hosts' \
##   'http://winhelp2002.mvps.org/hosts.txt' \
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/mvps.org/hosts' \
##   'http://someonewhocares.org/hosts/hosts' \
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/someonewhocares.org/hosts' \
##    'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext' \
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/yoyo.org/hosts' \
## Terms of Use of hpHosts
## This service is free to use, however, any and ALL automated use is 
## strictly forbidden without express permission from ourselves 
##    'http://hosts-file.net/ad_servers.txt' \
##    'http://hosts-file.net/hphosts-partial.txt' \
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/tyzbit/hosts' \
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/extensions/gambling/hosts' \
    'http://sysctl.org/cameleon/hosts' \
#error    'http://securemecca.com/Downloads/hosts.txt' \
    'https://raw.githubusercontent.com/gorhill/uMatrix/master/assets/umatrix/blacklist.txt' \
    'http://malwaredomains.lehigh.edu/files/justdomains' \
    'http://www.joewein.net/dl/bl/dom-bl.txt' \
#    'http://adblock.gjtech.net/?format=hostfile' \
#    'https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist' \
    'http://adblock.mahakala.is/' \
#    'http://mirror1.malwaredomains.com/files/justdomains' \
#    'https://raw.githubusercontent.com/CaraesNaur/hosts/master/hosts.txt' \
#SSL cerificate 'https://elbinario.net/wp-content/uploads/2015/02/BloquearPubli.txt' \
#    'https://www.dshield.org/feeds/suspiciousdomains_High.txt' \
#     'http://hostsfile.mine.nu/Hosts' \
#
# https://github.com/zant95/hBlock/blob/master/hblock
#
    'https://isc.sans.edu/feeds/suspiciousdomains_High.txt' \
    'https://ransomwaretracker.abuse.ch/downloads/RW_DOMBL.txt' \
    'https://raw.githubusercontent.com/zant95/hosts/master/hosts' \
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt' \
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt' \
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_malware.txt' \
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt' \
#
# https://github.com/brucebot/pisoft
#
    'http://code.taobao.org/svn/adblock/trunk/hosts.txt' \
    'https://raw.githubusercontent.com/quidsup/notrack/master/trackers.txt'