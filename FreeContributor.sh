#!/usr/bin/env bash
# FreeContributor: Enjoy a safe and faster web experience
# (c) 2016 by TBDS
# https://github.com/tbds/FreeContributor
#
# FreeContributor is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Simple script that pulls ad blocking host files from different providers 
# and combines them to use as a dnsmasq resolver file.
#
# Dependencies:
#  * GNU bash
#  * GNU sed
#  * GNU grep
#  * GNU coreutils
#  * cURL or wget
#  * Dnsmasq or Unbound or Pdnsd
#
## Global Variables------------------------------------------------------------
export FREECONTRIBUTOR_VERSION='0.3'

OPT=$1

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# make temp files
tmp=$(mktemp /tmp/data.XXXXX)
domains=$(mktemp /tmp/domains.XXXXX)

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
unbounddir=/etc/unbound
unboundconf=/etc/unbound/unbound.conf
unboundconfbak=/etc/unbound/unbound.conf.bak

# pdnsd
pdnsddir=/etc/pdnsd
pdnsdconf=/etc/pdnsd.conf
pdnsdconfbak=/etc/pdnsd.conf.bak

## ----------------------------------------------------------------------------

welcome(){
cat <<'EOF'

     _____               ____            _        _ _           _             
    |  ___| __ ___  ___ / ___|___  _ __ | |_ _ __(_) |__  _   _| |_ ___  _ __ 
    | |_ | '__/ _ \/ _ \ |   / _ \| '_ \| __| '__| | '_ \| | | | __/ _ \| '__|
    |  _|| | |  __/  __/ |__| (_) | | | | |_| |  | | |_) | |_| | || (_) | |   
    |_|  |_|  \___|\___|\____\___/|_| |_|\__|_|  |_|_.__/ \__,_|\__\___/|_|   


    Enjoy a safe and faster web experience

    FreeContributor - http://github.com/tbds/FreeContributor
    Released under the GPLv3 license
    (c) 2016 tbds and contributors

EOF
}

usage(){
cat <<'EOF'
    FreeContributor is a script to extract and convert extract domains lists from various sources.

    Usage: ./FreeContibutor.sh [options]

    OPTIONS:

       help        Show this help
       hosts       Use hosts format
       dnsmasq     Use dnsmasq as DNS resolver
       unbound     Use unbound as DNS resolver
       pdnsd       Use pdnsd as DNS resolver

    EXAMPLES:

      $ sudo ./FreeContibutor.sh dnsmasq

EOF
}

 
rootcheck(){
  if [[ $UID -ne 0 ]]; then
    echo -e "\nYou need root or su rights to access /etc directory"
    echo -e "Please install sudo or run this as root.\n"
    usage
    exit 1
  fi
}


install_packages(){
# need a universal installer 
# https://xkcd.com/1654/
#
#    pacman        by ArchLinux/Parabola, ArchBang, Manjaro, Antergos, Apricity OS
#    dpkg/apt-get  by Debian, Ubuntu, ElementaryOS, Linux Mint, etc ...
#    yum/rpm/dnf   by Red Hat, CentOS, Fedora, etc ...
#    zypper        by OpenSUSE
#    portage       by Gentoo/Funtoo (these guys don't need this script)
#    xbps          by Void (these guys don't need this script)
#
#
# Determine which package manager is being used
# https://github.com/icy/pacapt
#
  echo -e "\t Status: Error"
  echo -e "\n\t FreeConributor requires the program $prg"
  echo -e "\t FreeContributor will install $prg  ...  \n"

  if [[ -x "/usr/bin/pacman" ]]; then
    pacman -S --noconfirm $prg

  elif [[ -x "/usr/bin/dnf" ]]; then
    dnf -y install $prg

  elif [[ -x "/usr/bin/apt-get" ]]; then
    apt-get -y install $prg

  elif [[ -x "/usr/bin/yum" ]]; then
    yum -y install $prg

  else
    echo -e "\n\t Unable to work out which package manage is being used."
    echo -e "\n\t Ensure you have the following packages installed: $prg"

  fi
}

dependencies(){
  programs=( curl sed $OPT )

  for prg in "${programs[@]}"
  do
    echo -e "\n\t Checking if $prg is installed ..."
    type -P $prg &>/dev/null && echo -e "\t Status: Ok" || install_packages
  done
}

backup-resolv(){
  if [ -f "$resolvconf" ]; then
    echo -e "\n\t Backing up your previous resolv file"
    cp $resolvconf  $resolvconfbak
  fi
# change resolv file to add fastest two opennic servers

}


download_sources(){
## See FilterLists for a comprehensive list of filter lists from all over the web
## https://filterlists.com/
##
## Use StevenBlack/hosts mirrors to save bandwidth from original projects
## https://github.com/StevenBlack/hosts/tree/master/data
##
## why download the files twice?
##

#put the links in a file instead (more portable)

sources=(\
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
## error 'http://securemecca.com/Downloads/hosts.txt' \
    'https://raw.githubusercontent.com/gorhill/uMatrix/master/assets/umatrix/blacklist.txt' \
    'http://malwaredomains.lehigh.edu/files/justdomains' \
    'http://www.joewein.net/dl/bl/dom-bl.txt' \
#    'http://adblock.gjtech.net/?format=hostfile' \
#    'https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist' \
#    'http://adblock.mahakala.is/' \
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
#    'http://code.taobao.org/svn/adblock/trunk/hosts.txt' \
    'https://raw.githubusercontent.com/quidsup/notrack/master/trackers.txt'

#requires unzip 'http://hostsfile.org/Downloads/BadHosts.unx.zip' \
#    'http://support.it-mate.co.uk/downloads/HOSTS.txt' \
#    'https://hosts.neocities.org/' \
#    'https://publicsuffix.org/list/effective_tld_names.dat' \
#    'http://cdn.files.trjlive.com/hosts/hosts-v8.txt' \
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

  echo -e "\n\t FreeContributor is downloading data ..."
  for item in ${sources[*]}
  do
    echo -e "\n\t :: Downloading from URL: $item"
    curl -s $item >> $tmp || { echo -e "\n\t Error downloading $item"; exit 1; }
    #wget -q  $item -O $tmp || { echo -e "\n\t Error downloading $item"; exit 1; }
  done
}

extract_domains(){
# clean this code with better regex
# https://blog.mister-muffin.de/2011/11/14/adblocking-with-a-hosts-file/
# sed 's/\([^#]*\)#.*/\1/;s/[ \t]*$//;s/^[ \t]*//;s/[ \t]\+/ /g'
#

  echo -e "\n\t Extracting domains from lists ..."
  # remove empty lines and comments
  grep -Ev '^$' $tmp | \
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
  sort | uniq > $domains
}

## hosts ------------------------------------------------------------------

hosts-format(){
  if [ -f "${hostsconf}" ]; then
    echo -e "\n\t Backing up your previous hosts file"
    cp "${hostsconf}" "${hostsconfbak}"
  fi

  #Generate hosts header
  ./utils/hosts.header.sh 

  mv hosts.header $hostsconf

  awk '{print "0.0.0.0 "$1}' $domains >> $hostsconf #ipv4
  #awk '{print ":: "$1}' $domains >> $hostsconf      #ipv6
}


## dnsmasq -----------------------------------------------------------------

dnsmasq-config(){
  if [ ! -d "${dnsmasqdir}" ]; then
    mkdir -p "${dnsmasqdir}"
  fi

  if [ -f "${dnsmasqconf}" ]; then
    echo -e "\n\t Backing up your previous dnsmasq file"
    cp "${dnsmasqconf}" "${dnsmasqconfbak}"
  fi

  awk '{print "server=/"$1"/"}' $domains > dnsmasq-block.conf
  echo -e "\n\t Domains blocked: $(wc -l dnsmasq-block.conf)"
  mv dnsmasq-block.conf "${dnsmasqdir}"/dnsmasq-block.conf

  cp "${dir}"/data/formats/dnsmasq.d/*.conf "${dnsmasqdir}"
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


  awk '{print "local-zone: ""\x22"$1"\x22"" static"}' $domains > unbound-block.conf
  echo "unbound-block.conf domains added: $(wc -l unbound-block.conf)"
  mv unbound-block.conf "${unbounddir}"/unbound-block.conf
}

## pdnsd -------------------------------------------------------------------

pdnsd-config(){
#https://news.ycombinator.com/item?id=3035825
#https://pgl.yoyo.org/adservers/serverlist.php?hostformat=pdnsd
#neg { name=example.tld; types=domain; }

  awk '{print "{ name="$1"; types=domain; }"}' $domains-extracted > pdnsd-block.conf
  echo "pdnsd-block.conf domains added: $(wc -l pdnsd-block.conf)"
  mv pdnsd-block.conf "${pdnsddir}"/pdnsd-block.conf
}


start-daemons(){
#https://github.com/DisplayLink/evdi/issues/11#issuecomment-193877839
## TODO
## for each case: dnsmasq, unbound and pdnsd
#
# this will one day work
#
INIT=`ls -l /proc/1/exe`
  if [[ $INIT == *"systemd"* ]]; then
    systemctl enable "${OPT}" && systemctl restart "${OPT}"
  elif [[ $INIT == *"upstart"* ]]; then
    service "${OPT}" start
  elif [[ $INIT == *"/sbin/init"* ]]; then
    INIT=`/sbin/init --version`
    if [[ $INIT == *"systemd"* ]]; then
      systemctl enable "${OPT}" && systemctl restart "${OPT}"
    elif [[ $INIT == *"upstart"* ]]; then
      service "${OPT}" start
    fi
  fi
}

finish(){
cat <<'EOF'

    FreeContributor successfully installed
    Enjoy surfing in the web

EOF
}


## Main --------------------------------------------------------------------

processing(){
  backup-resolv
  download_sources
  extract_domains
}

main(){
   welcome
   rootcheck
   
   case $OPT in
     --help|help) usage ; exit 1;;
     --hosts|hosts) processing ; hosts-format ;;
     --dnsmasq|dnsmasq) dependencies ; processing ; dnsmasq-config ; start-daemons  ;;
     --unbound|unbound) dependencies ; processing ; unbound-config ; start-daemons ;;
     --pdnsd|pdnsd) dependencies ; processing ; pdnsd-config ; start-daemons ;;
     *) usage ; exit 1;;
   esac

   finish
}

main