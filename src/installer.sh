#!/usr/bin/env bash
# FreeContributor: Enjoy a safe and faster web experience
# (c) 2016 by TBDS
# https://github.com/tbds/FreeContributor
#
# Simple script that pulls ad blocking host files from different providers 
# and combines them to use as a dnsmasq resolver file.
#
# A, --address=/<domain>/ [domain/] <ipaddr>
#              Specify an IP address to  return  for  any  host  in  the  given
#              domains.   Queries in the domains are never forwarded and always
#              replied to with the specified IP address which may  be  IPv4  or
#              IPv6.  To  give  both  IPv4 and IPv6 addresses for a domain, use
#              repeated -A flags.  Note that /etc/hosts and DHCP  leases  over-
#              ride this for individual names. A common use of this is to redi-
#              rect the entire doubleclick.net domain to  some  friendly  local
#              web  server  to avoid banner ads. The domain specification works
#              in the same was as for --server, with  the  additional  facility
#              that  /#/  matches  any  domain.  Thus --address=/#/1.2.3.4 will
#              always return 1.2.3.4 for any query not answered from /etc/hosts
#              or  DHCP  and  not sent to an upstream nameserver by a more spe-
#              cific --server directive."
#
# FreeContributor is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Dependencies:
#  * curl
#  * dnsmasq
#  * GNU coreutils

# Declair variables
resolv=/etc/resolv.conf
dnsmasqdir=/etc/dnsmasq.d
dnsmasqconf=/etc/dnsmasq.conf
dnsmasqconfbak=/etc/dnsmasq.conf.bak

welcome(){
echo "
     _____               ____            _        _ _           _             
    |  ___| __ ___  ___ / ___|___  _ __ | |_ _ __(_) |__  _   _| |_ ___  _ __ 
    | |_ | '__/ _ \/ _ \ |   / _ \| '_ \| __| '__| | '_ \| | | | __/ _ \| '__|
    |  _|| | |  __/  __/ |__| (_) | | | | |_| |  | | |_) | |_| | || (_) | |   
    |_|  |_|  \___|\___|\____\___/|_| |_|\__|_|  |_|_.__/ \__,_|\__\___/|_|   


    Enjoy a safe and faster web experience

    FreeContributor - http://github.com/tbds/FreeContributor
    Released under the GPLv3 license
    (c) 2016 tbds and contributors

"
}

rootcheck(){
  if [[ $UID -ne 0 ]]; then
    echo "Please run this script as root"
    exit 1
  fi
}

dependencies(){
programs=( wget curl sed unzip 7z dnsmasq )
for prg in "${programs[@]}"
do
	type -P $prg &>/dev/null || { echo "Error: FreeConributor requires the program $prg... Aborting."; echo; exit 192; }
done
}

backup(){
if [ ! -f "$dnsmasqconf" ] ; then
  echo "Backing up your previous dnsmasq file"
  sudo cp $dnsmasqconf $dnsmasqconfbak
fi
}

download_sources(){
## See FilterLists for a comprehensive list of filter lists from all over the web
## https://filterlists.com/

sources=(\
    'https://adaway.org/hosts.txt'\
    'http://winhelp2002.mvps.org/hosts.txt'\
    'http://hosts-file.net/.\ad_servers.txt'\
    'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext'\
    'http://someonewhocares.org/hosts/hosts'\
    'http://sysctl.org/cameleon/hosts' \
    'http://securemecca.com/Downloads/hosts.txt' \
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/StevenBlack/hosts' \
#    'https://hosts.neocities.org/' \
    'http://www.malwaredomainlist.com/hostslist/hosts.txt' \
    'http://malwaredomains.lehigh.edu/files/justdomains' \
    'http://adblock.gjtech.net/?format=hostfile' \
    'https://raw.githubusercontent.com/quidsup/notrack/master/trackers.txt'
#    'https://publicsuffix.org/list/effective_tld_names.dat' \
#    'http://jansal.googlecode.com/svn/trunk/adblock/hosts' \
#    'http://malwaredomains.lehigh.edu/files/justdomains' \
#    'http://cdn.files.trjlive.com/hosts/hosts-v8.txt' \
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt' \
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt' \
#    'https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist' \
#    'http://tcpdiag.dl.sourceforge.net/project/adzhosts/HOSTS.txt' \
#    'http://optimate.dl.sourceforge.net/project/adzhosts/HOSTS.txt' \
#    'http://mirror1.malwaredomains.com/files/justdomains' \
#    'https://raw.githubusercontent.com/reek/anti-adblock-killer/master/anti-adblock-killer-filters.txt' \
#    'http://spam404bl.com/spam404scamlist.txt' \
#    'http://malwaredomains.lehigh.edu/files/domains.txt' \
#    'http://www.joewein.net/dl/bl/dom-bl.txt' \
#    'http://www.sa-blacklist.stearns.org/sa-blacklist/sa-blacklist.current' \
#    'https://easylist-downloads.adblockplus.org/malwaredomains_full.txt' \
#    'https://easylist-downloads.adblockplus.org/easyprivacy.txt' \
#    'https://easylist-downloads.adblockplus.org/easylist.txt' \
#    'https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt' \
#    'http://www.fanboy.co.nz/adblock/opera/urlfilter.ini' \
#    'http://www.fanboy.co.nz/adblock/fanboy-tracking.txt' \
    )

for item in ${sources[*]}
do
    echo "---------------------"
    echo "Downloading $item ..."
    curl $item >> tmp || { echo -e "\nError downloading $item"; exit 1; }
    echo "---------------------"
done

}

extract_domains(){
# clean this code with better regex
# https://blog.mister-muffin.de/2011/11/14/adblocking-with-a-hosts-file/

	echo "Extract domains from lists"
	# remove empty lines and comments
	grep -Ev '^$' tmp | \
	grep -o '^[^#]*'  | \
	# exclude locahost entries
	grep -v "localhost" | \
	# remove 127.0.0.1 and 0.0.0.0
	sed 's/127.0.0.1//' | \
        sed 's/0.0.0.0//' | \
	# remove tab and spaces in the begining
	sed -e 's/^[ \t]*//' | \
	# remove ^M
        sed 's/\r//g' | grep -Ev '^$' > domains-extracted
	
	echo domains extracted; wc -l domains-extracted
}

dnsmasq-conf(){
	cat  domains-extracted | sort | uniq | \
	awk '{print "address=/"$1"/"}' > dnsmasq-domains.conf
	echo domains dnsmasq-domains.conf; wc -l dnsmasq-domains.conf
}

finish(){
    echo "Done"
}



#welcome
#rootcheck
#dependencies
#backup
download_sources
extract_domains
dnsmasq-conf
finish