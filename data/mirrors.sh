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

curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/adaway.org/hosts'            --output ./mirrors/adaway
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/malwaredomainlist.com/hosts' --output ./mirrors/malwaredomainlist
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/mvps.org/hosts'              --output ./mirrors/mvps
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/someonewhocares.org/hosts'   --output ./mirrors/someonewhocares
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/yoyo.org/hosts'              --output ./mirrors/yoyo
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/tyzbit/hosts'                --output ./mirrors/tyzbit
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/extensions/gambling/hosts'        --output ./mirrors/gambling
curl 'http://sysctl.org/cameleon/hosts'                                                            --output ./mirrors/cameleon
curl 'https://raw.githubusercontent.com/gorhill/uMatrix/master/assets/umatrix/blacklist.txt'       --output ./mirrors/umatrix
curl 'http://malwaredomains.lehigh.edu/files/justdomains'                                          --output ./mirrors/malwaredomains
curl 'https://mirror.cedia.org.ec/malwaredomains/justdomains'                                      --output ./mirrors/justdomains
curl 'http://www.joewein.net/dl/bl/dom-bl.txt'                                                     --output ./mirrors/joewein
curl 'http://adblock.mahakala.is/'                                                                 --output ./mirrors/mahakala
curl 'https://raw.githubusercontent.com/quidsup/notrack/master/trackers.txt'                       --output ./mirrors/notrack
curl 'http://code.taobao.org/svn/adblock/trunk/hosts.txt'                                          --output ./mirrors/taobao
curl 'https://isc.sans.edu/feeds/suspiciousdomains_High.txt'                                       --output ./mirrors/suspiciousdomains
curl 'https://ransomwaretracker.abuse.ch/downloads/RW_DOMBL.txt'                                   --output ./mirrors/ransomwaretracker
curl 'https://raw.githubusercontent.com/zant95/hosts/master/hosts'                                 --output ./mirrors/zant95
curl 'https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt'                                  --output ./mirrors/disconnect_ad.
curl 'https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt'                        --output ./mirrors/disconnect_malvertising
curl 'https://s3.amazonaws.com/lists.disconnect.me/simple_malware.txt'                             --output ./mirrors/disconnect_malware
curl 'https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt'                            --output ./mirrors/disconnect_tracking



