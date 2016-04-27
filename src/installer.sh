#!/usr/bin/env bash
# FreeContributor: Enjoy a safe and faster web experience
# (c) 2016 by TBDS
# https://github.com/tbds/FreeContributor
#
# FreeContributor is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# Simple script that pulls ad blocking host files from different providers 
# and combines them to use as a dnsmasq resolver file.
#
# Dependencies:
#  * cURL
#  * GNU coreutils
#  * dnsmasq or Unbound or Pdnsd
#  * polipo
#  * privoxy

# variables
version=0.3

# resolv
resolvconf=/etc/resolv.conf
resolvconfbak=/etc/resolv.conf.bak

# hosts
hostsconf=/etc/hosts
hostsconfbak=/etc/hosts.bak

# dnsmasq
dnsmasqdir=/etc/dnsmasq.d
dnsmasqconf=/etc/dnsmasq.conf
dnsmasqconfbak=/etc/dnsmasq.conf.bak

# unbound
unboundconf=/etc/unbound/unbound.conf
unboundconfbak=/etc/unbound/unbound.conf.bak
unbounddir=/etc/unbound

# pdnsd
pdnsdconf=/etc/pdnsd.conf
pdnsdconfbak=/etc/pdnsd.conf.bak

# polipo
polipoconf=/etc/polipo/config
polipoconfbak=/etc/polipo/config.bak
polipodir=/etc/polipo

# privoxy
privoxy=/etc/privoxy/config
privoxybak=/etc/privoxy/config.bak
privoxydir=/etc/ptivoxy

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

usage()
{
  echo -e "\nFreeContributor is a script to extract and convert extract domains lists from various sources.\n"
  echo "Options:"
  echo "      -help   :    Show this help."
  echo "      -hosts   :   Use hosts format"
  echo "      -dnsmasq:    Use dnsmasq as DNS cache"
  echo "      -unbound:    Use unbound as DNS cache"
  echo "      -pdnsd  :    Use pdnsd as DNS cache"
  echo "      -polipo :    Install polipo"
  echo "      -privoxy:    Install privoxy"
}

 
rootcheck(){
  if [[ $UID -ne 0 ]]; then
    echo "You need root or su rights to access /etc directory"
    echo "Please run this script as root"
    usage
    exit 1
  fi
}


install_packages(){
#    pacman        by Arch Linux/Parabola, ArchBang, Manjaro, Antergos, Apricity OS
#    dpkg/apt-get  by Debian, Ubuntu, ElementaryOS, Linux Mint, etc ...
#    yum/rpm/dnf   by Redhat, CentOS, Fedora, etc ...
#    zypper        by OpenSUSE
#    portage       by Gentoo (this guys don't need this script)
#
# Find out the package manager
# https://github.com/icy/pacapt
# https://github.com/quidsup/notrack/blob/master/install.sh

  if [[ -x "/usr/bin/pacman" ]]; then
    pacman -S --noconfirm dnsmasq

  elif [[ -x "/usr/bin/dnf" ]]; then
    dnf -y install dnsmasq

  elif [[ -x "/usr/bin/apt-get" ]]; then
    apt-get -y install dnsmasq

  elif [[ -x "/usr/bin/yum" ]]; then
    yum -y install dnsmasq

#  elif [[ -x "/usr/bin/zypper" ]]; then
  else
    echo "Unable to work out which package manage is being used."

  fi
}

dependencies(){
  programs=( wget curl sed ) #unzip 7z
#TODO 
## option to select dsnmasq unbound pdnsd

  for prg in "${programs[@]}"
  do
    type -P $prg &>/dev/null || install_packages 
    #echo "Error: FreeConributor requires the program $prg ..."
    #echo "FreeContributor will install $prg " }
    #
  done
}


backup-resolv(){
  if [ ! -f "$resolvconf" ] && [ ! -f "$dnsmasqconf" ]; then
    echo "Backing up your previous resolv file"
    cp $resolvconf  $resolvconfbak
  fi
}


download_sources(){
## See FilterLists for a comprehensive list of filter lists from all over the web
## https://filterlists.com/
##
## Use StevenBlack/hosts mirrors to save bandwidth from original projects
## https://github.com/StevenBlack/hosts/tree/master/data

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
    'https://raw.githubusercontent.com/quidsup/notrack/master/trackers.txt'

#requires unzip 'http://hostsfile.org/Downloads/BadHosts.unx.zip' \
#    'http://support.it-mate.co.uk/downloads/HOSTS.txt' \
#    'https://hosts.neocities.org/' \
#    'https://publicsuffix.org/list/effective_tld_names.dat' \
#    'http://cdn.files.trjlive.com/hosts/hosts-v8.txt' \
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt' \
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt' \
#    'http://tcpdiag.dl.sourceforge.net/project/adzhosts/HOSTS.txt' \
#    'http://optimate.dl.sourceforge.net/project/adzhosts/HOSTS.txt' \
)

sources2=(\
#    'https://raw.githubusercontent.com/reek/anti-adblock-killer/master/anti-adblock-killer-filters.txt' \
#    'http://www.sa-blacklist.stearns.org/sa-blacklist/sa-blacklist.current' \
#    'https://easylist-downloads.adblockplus.org/malwaredomains_full.txt' \
#    'https://easylist-downloads.adblockplus.org/easyprivacy.txt' \
#    'https://easylist-downloads.adblockplus.org/easylist.txt' \
#    'https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt' \
#    'http://www.fanboy.co.nz/adblock/opera/urlfilter.ini' \
#    'http://www.fanboy.co.nz/adblock/fanboy-tracking.txt' \
)

  for item in ${sources1[*]}
  do
    echo "# -- Downloading from URL: $item -- |"
    curl $item >> tmp || { echo -e "\nError downloading $item"; exit 1; }

  done

}

extract_domains(){
# clean this code with better regex
# https://blog.mister-muffin.de/2011/11/14/adblocking-with-a-hosts-file/

  echo "Extracting domains from lists"
  # remove empty lines and comments
  grep -Ev '^$' tmp | \
  grep -o '^[^#]*'  | \
  # exclude locahost entries
  grep -v "localhost" | \
  # remove 127.0.0.* and 0.0.0.0
  sed 's/127.0.0.1//' | \
  sed 's/0.0.0.0//' | \
  # remove tab and spaces in the begining
  sed -e 's/^[ \t]*//' | \
  # remove ^M
  sed 's/\r//g' | grep -Ev '^$' | \
  sort | uniq > domains-extracted
}

## hosts
### TODO 
### option 127.0.0.1 or 0.0.0.0 (default)

hosts-format(){
  if [ ! -f "$hostsconf" ]; then
    echo "Backing up your previous hosts file"
    cp $hostsconf $hostsconfbak
  fi

  awk '{print "0.0.0.0 "$1}' domains-extracted > hosts
  echo "hosts domains added: $(wc -l hosts)"
  #mv hosts /etc/hosts
}


## dnsmasq --------------------------------------------------------------------
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

dnsmasq-config(){
  if [ ! -d "$dnsmasqdir" ]; then 
    mkdir -p "$dnsmasqdir"
  fi

  if [ ! -f "$dnsmasqconf" ]; then
    echo "Backing up your previous dnsmasq file"
    cp $dnsmasqconf $dnsmasqconfbak
  fi

  awk '{print "address=/"$1"/"}' domains-extracted > dnsmasq-block.conf
  echo "dnsmasq-block.conf domains added: $(wc -l dnsmasq-block.conf)"
  mv dnsmasq-block.conf /etc/dnsmasq.d/dnsmasq-block.conf
}

## unbound -----------------------------------------------------------------

unbound-config(){
#https://github.com/jodrell/unbound-block-hosts/
#https://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound
#local-zone: "example.tld" redirect
#local-data: "example.tld A 127.0.0.1"

#use nxdomain
#local-zone: "testdomain.test" static
#http://www.unixcl.com/2012/07/print-double-quotes-in-unix-awk.html


  awk '{print "local-zone: ""\x22"$1"\x22"" static"}' domains-extracted > unbound-block.conf
  echo "unbound-block.conf domains added: $(wc -l unbound-block.conf)"
  #mv unbound-block.conf /etc/unbound/unbound-block.conf
}

## pdnsd -------------------------------------------------------------------

pdnsd-config(){
#https://news.ycombinator.com/item?id=3035825
#https://pgl.yoyo.org/adservers/serverlist.php?hostformat=pdnsd
#neg { name=example.tld; types=domain; }

  awk '{print "{ name="$1"; types=domain; }"}' domains-extracted > pdnsd-block.conf
  echo "pdnsd-block.conf domains added: $(wc -l pdnsd-block.conf)"
  #mv pdnsd-block.conf /etc/pdnsd/pdnsd-block.conf
}



finish(){
  #clean up
  rm tmp domains-extracted
  echo "Done"
  echo "FreeContributor sucessufull installed"
  echo "Enjoy surfing in the web"
}

start-deamons(){
#https://github.com/DisplayLink/evdi/issues/11#issuecomment-193877839
## TODO
## for each case: dnsmasq, unbound and pdnsd

INIT=`ls -l /proc/1/exe`
  if [[ $INIT == *"systemd"* ]]; then
    systemctl enable dnsmasq.service && systemctl restart dnsmasq.service
  elif [[ $INIT == *"upstart"* ]]; then
    service dnsmasq start
  elif [[ $INIT == *"/sbin/init"* ]]; then
    INIT=`/sbin/init --version`
    if [[ $INIT == *"systemd"* ]]; then
      systemctl enable dnsmasq.service && systemctl restart dnsmasq.service
    elif [[ $INIT == *"upstart"* ]]; then
      service dnsmasq start
    fi
  fi
}

main(){
   welcome
   rootcheck
   #menu
   dependencies
   backup-resolv
   #config
   download_sources
   extract_domains
   hosts-format
   dnsmasq-config
   unbound-config
   pdnsd-config
   finish
   #start-deamons
}

main