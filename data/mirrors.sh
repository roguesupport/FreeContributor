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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/adaway.org/hosts'            --output ./mirrors/adaway
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/malwaredomainlist.com/hosts' --output ./mirrors/malwaredomainlist
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/mvps.org/hosts'              --output ./mirrors/mvps
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/someonewhocares.org/hosts'   --output ./mirrors/someonewhocares
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/yoyo.org/hosts'              --output ./mirrors/yoyo
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/tyzbit/hosts'                --output ./mirrors/tyzbit
curl 'https://raw.githubusercontent.com/StevenBlack/hosts/master/extensions/gambling/hosts'        --output ./mirrors/gambling
curl 'https://raw.githubusercontent.com/quidsup/notrack/master/trackers.txt'                       --output ./mirrors/notrack
curl 'https://raw.githubusercontent.com/gorhill/uMatrix/master/assets/umatrix/blacklist.txt'       --output ./mirrors/umatrix
curl 'https://raw.githubusercontent.com/zant95/hosts/master/hosts'                                 --output ./mirrors/zant95
curl 'http://sysctl.org/cameleon/hosts'                                                            --output ./mirrors/cameleon
curl 'http://malwaredomains.lehigh.edu/files/justdomains'                                          --output ./mirrors/malwaredomains
curl 'https://mirror.cedia.org.ec/malwaredomains/justdomains'                                      --output ./mirrors/justdomains
curl 'http://www.joewein.net/dl/bl/dom-bl.txt'                                                     --output ./mirrors/joewein
curl 'http://adblock.mahakala.is/'                                                                 --output ./mirrors/mahakala
curl 'http://code.taobao.org/svn/adblock/trunk/hosts.txt'                                          --output ./mirrors/taobao
curl 'https://isc.sans.edu/feeds/suspiciousdomains_High.txt'                                       --output ./mirrors/suspiciousdomains_high
curl ''https://www.dshield.org/feeds/suspiciousdomains_Low.txt''                                   --output ./mirrors/suspiciousdomains_low
curl 'https://ransomwaretracker.abuse.ch/downloads/RW_DOMBL.txt'                                   --output ./mirrors/RW_DOMBL
curl 'https://ransomwaretracker.abuse.ch/downloads/CW_C2_DOMBL.txt'                                --output ./mirrors/CW_C2_DOMBL
curl 'https://ransomwaretracker.abuse.ch/downloads/CW_PS_DOMBL.txt'                                --output ./mirrors/CW_PS_DOMBL
curl 'https://ransomwaretracker.abuse.ch/downloads/TC_C2_DOMBL.txt'                                --output ./mirrors/TC_C2_DOMBL
curl 'https://ransomwaretracker.abuse.ch/downloads/TC_PS_DOMBL.txt'                                --output ./mirrors/TC_PS_DOMBL
curl 'https://ransomwaretracker.abuse.ch/downloads/LY_C2_DOMBL.txt'                                --output ./mirrors/LY_C2_DOMBL
curl 'https://ransomwaretracker.abuse.ch/downloads/LY_PS_DOMBL.txt'                                --output ./mirrors/LY_PS_DOMBL
curl 'https://ransomwaretracker.abuse.ch/downloads/TL_C2_DOMBL.txt'                                --output ./mirrors/TL_C2_DOMBL
curl 'https://ransomwaretracker.abuse.ch/downloads/TL_PS_DOMBL.txt'                                --output ./mirrors/TL_PS_DOMBL
curl 'https://feodotracker.abuse.ch/blocklist/?download=domainblocklist'                           --output ./mirrors/feodotracker
curl 'https://palevotracker.abuse.ch/blocklists.php?download=domainblocklist'                      --output ./mirrors/palevotracker
curl 'https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist'                         --output ./mirrors/zeustracker

# blacklist_from *@001web.net
#curl 'http://www.sa-blacklist.stearns.org/sa-blacklist/sa-blacklist.current' | 

http://www.sa-blacklist.stearns.org/sa-blacklist/sa-blacklist.200904171239.domains
curl 'https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt'                                  --output ./mirrors/disconnect_ad \
&& tail -n +3 ./mirrors/disconnect_ad > ./mirrors/disconnect_ad
curl 'https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt'                        --output ./mirrors/disconnect_malvertising \
&& tail -n +3 ./mirrors/disconnect_malvertising > ./mirrors/disconnect_malvertising
curl 'https://s3.amazonaws.com/lists.disconnect.me/simple_malware.txt'                             --output ./mirrors/disconnect_malware \
&& tail -n +3 ./mirrors/disconnect_malware > ./mirrors/disconnect_malware
curl 'https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt'                            --output ./mirrors/disconnect_tracking \
&& tail -n +3 ./mirrors/disconnect_tracking > ./mirrors/disconnect_tracking

#curl -A 'Mozilla/5.0 (X11; Linux x86_64; rv:30.0) Gecko/20100101 Firefox/30.0' -e http://forum.xda-developers.com/ http://adblock.mahakala.is/ \
#| grep -v "#" | awk '{print $2}' | sort >> ./mirrors/adblock.mahakala

# requires p7zip
#curl 'http://rlwpx.free.fr/WPFF/htrc.7z'                             --output ./mirrors/htrc.7z 
curl 'http://rlwpx.free.fr/WPFF/hpub.7z'                              --output ./mirrors/hpub.7z
curl 'http://rlwpx.free.fr/WPFF/hrsk.7z'                              --output ./mirrors/hrsk.7z
curl 'http://rlwpx.free.fr/WPFF/hsex.7z'                              --output ./mirrors/hsex.7z
curl 'http://rlwpx.free.fr/WPFF/hmis.7z'                              --output ./mirrors/hmis.7z
curl 'http://hostsfile.org/Downloads/BadHosts.unx.zip'                --output ./mirrors/BadHosts.zip && \
unzip ./mirrors/BadHosts.zip -d ./mirrors/ && rm ./mirrors/BadHosts.zip


for file in ${DIR}/mirrors/*.7z
do
    7z x "${file}" -o${dir}/mirrors/ && rm "${file}"
done


https://raw.githubusercontent.com/notracking/hosts-blocklists/master/hostnames.txt




#    'http://adblock.gjtech.net/?format=unix-hosts'
#    'http://hostsfile.mine.nu/Hosts'
##
## https://github.com/crazy-max/WindowsSpyBlocker
##
#    'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/blob/master/hosts/windows10_extra.txt'
#    'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/blob/master/hosts/windows10_spy.txt'
#    'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/blob/master/hosts/windows10_update.txt'
##
## Terms of Use of hpHosts
## This service is free to use, however, any and ALL automated use is 
## strictly forbidden without express permission from ourselves 
##    'http://hosts-file.net/ad_servers.txt'
##    'http://hosts-file.net/hphosts-partial.txt'


## error 'http://securemecca.com/Downloads/hosts.txt' 
#    'http://www.joewein.net/dl/bl/dom-bl.txt' 
#    'http://mirror1.malwaredomains.com/files/justdomains'
#    'https://raw.githubusercontent.com/CaraesNaur/hosts/master/hosts.txt'
#SSL cerificate 'https://elbinario.net/wp-content/uploads/2015/02/BloquearPubli.txt'
#
#    'http://code.taobao.org/svn/adblock/trunk/hosts.txt'
#    'http://hostsfile.org/Downloads/BadHosts.unx.zip'
#    'http://support.it-mate.co.uk/downloads/HOSTS.txt'
#    'https://hosts.neocities.org/'
#    'https://publicsuffix.org/list/effective_tld_names.dat'
#    'http://cdn.files.trjlive.com/hosts/hosts-v8.txt'
#    'http://tcpdiag.dl.sourceforge.net/project/adzhosts/HOSTS.txt'
#    'http://optimate.dl.sourceforge.net/project/adzhosts/HOSTS.txt'
#    'https://openphish.com/feed.txt'
#    'https://easylist-downloads.adblockplus.org/rolist+easylist.txt'
#    'http://www.shallalist.de/Downloads/shallalist.tar.gz'
#    'http://support.it-mate.co.uk/downloads/HOSTS.txt'
#    'https://raw.githubusercontent.com/reek/anti-adblock-killer/master/anti-adblock-killer-filters.txt'
#    'http://www.sa-blacklist.stearns.org/sa-blacklist/sa-blacklist.current'
#    'https://easylist-downloads.adblockplus.org/malwaredomains_full.txt'
#    'https://easylist-downloads.adblockplus.org/easyprivacy.txt'
#    'https://easylist-downloads.adblockplus.org/easylist.txt'
#    'https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt'
#    'http://www.fanboy.co.nz/adblock/opera/urlfilter.ini'
#    'http://www.fanboy.co.nz/adblock/fanboy-tracking.txt'