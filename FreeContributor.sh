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
# Simple script that pulls ad blocking host files from different providers 
# and combines them to use as a DNS resolver file.
#
# Dependencies:
#  * GNU bash
#  * GNU sed
#  * GNU grep
#  * GNU coreutils
#  * GNU wget or cURL
#  * Dnsmasq or Unbound or Pdnsd
#
# BASH3 Boilerplate - http://bash3boilerplate.sh
## Global Variables---- --------------------------------------------------------
FREECONTRIBUTOR_VERSION='0.4.1'
REDIRECTIP4="${REDIRECTIP4:=0.0.0.0}"
REDIRECTIP6="${REDIRECTIP6:=::}"

DNSSERVER1="${DNSSERVER1:=}"
DNSSERVER2="${DNSSERVER2:=}"

TARGET="${TARGET:=$REDIRECTIP4}"
FORMAT="${FORMAT:=dnsmasq}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# make temp files
TMP=$(mktemp /tmp/data.XXXXX)
DOMAINS=$(mktemp /tmp/domains.XXXXX)

# resolv
RESOLVCONF="${RESOLVCONF:=/etc/resolv.conf}"
RESOLVCONFBAK="${RESOLVCONFBAK:=/etc/resolv.conf.bak}"

# hosts
HOSTSCONF="${HOSTSCONF:=/etc/hosts}"
HOSTSCONFBAK="${HOSTSCONFBAK:=/etc/hosts.bak}"

# dnsmasq
DNSMASQDIR="${DNSMASQDIR:=/etc/dnsmasq.d}"
DNSMASQCONF="${DNSMASQCONF:=/etc/dnsmasq.conf}"
DNSMASQCONFBAK="${DNSMASQCONFBAK:=/etc/dnsmasq.conf.bak}"

# unbound
UNBOUNNDDIR="${UNBOUNNDDIR:=/etc/unbound}"
UNBOUNNDCONF="${UNBOUNNDCONF:=/etc/unbound/unbound.conf}"
UNBOUNNDCONFBAK="${UNBOUNNDCONFBAK:=/etc/unbound/unbound.conf.bak}"

# pdnsd
PDNSDDIR="${PDNSDDIR:=/etc/pdnsd}"
PDNSDCONF="${PDNSDCONF:=/etc/pdnsd.conf}"
PDNSDCONFBAK="${PDNSDCONFBAK:=/etc/pdnsd.conf.bak}"

## ----------------------------------------------------------------------------

welcome()
{
cat << EOF

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

usage()
{
cat << EOF


    FreeContributor is a script to extract and convert domains lists from various sources.
    
    USAGE: 

      $ $0 [-f format]  [-o out] [-t target]

       -f format: specify an output format:

          none        Extract domains only
          hosts       Use hosts format
          dnsmasq     dnsmasq as DNS resolver
          unbound     unbound as DNS resolver
          pdnsd       pdnsd as DNS resolver

       -o out: specify an output file

       -t target: specify the target
    
          default:     $TARGET
                       $REDIRECTIP6
                       NXDOMAIN
                       custom (e.g. 192.168.1.20)

       -help: show this help


    EXAMPLES:

      $ $0 -f hosts -t 0.0.0.0

      $ $0 -f dnsmasq -t NXDOMAIN

EOF
}

 
rootcheck()
{
  if [[ $UID -ne 0 ]]; then
    echo -e "\nYou need root or su rights to access /etc directory"
    echo -e "Please install sudo or run this as root.\n"
    usage
    exit 1
  fi
}


install_packages()
{
# need a universal installer -> snap packages - snapcraft.io
# https://xkcd.com/1654/
#    
#    pacman        by ArchLinux/Parabola, ArchBang, Manjaro, Antergos, Apricity OS
#    dpkg/apt-get  by Debian, Ubuntu, ElementaryOS, Linux Mint, etc ...
#    yum/rpm/dnf   by Red Hat, CentOS, Fedora, etc ...
#    zypper        by OpenSUSE
#    portage       by Gentoo/Funtoo (these guys don't need this script)
#    xbps          by Void (these guys don't need this script)
#
# Determine which package manager is being used
# https://github.com/icy/pacapt
#
  echo -e "\t Status: Error"
  echo -e "\n\t FreeContributor requires the program $PRG"
  echo -e "\t FreeContributor will install $PRG  ...  \n"

  if [[ -x "/usr/bin/pacman" ]]; then
    pacman -S --noconfirm $PRG

  elif [[ -x "/usr/bin/dnf" ]]; then
    dnf -y install $PRG

  elif [[ -x "/usr/bin/apt-get" ]]; then
    apt-get -y install $PRG

  elif [[ -x "/usr/bin/yum" ]]; then
    yum -y install $PRG

  else
    echo -e "\n\t Unable to work out which package manage is being used."
    echo -e "\n\t Ensure you have the following packages installed: $prg"

  fi
}

dependencies()
{
  programs=( curl $FORMAT )

  for PRG in "${programs[@]}"
  do
    echo -e "\n\t Checking if $prg is installed ..."
    type -P $PRG &>/dev/null && echo -e "\t Status: Ok" || install_packages
  done
}

resolv()
{
  if [ -f "$RESOLVCONF" ]; then
    #echo -e "\n\t Backing up your previous resolv file"
    cp $RESOLVCONF  $RESOLVCONFBAK
  fi

  #if [ ${FORMAT} != "none" ] || [ ${FORMAT} != "hosts" ]; then
  #cp ./conf/resolv.conf $resolvconf
  #chattr +i $resolvconf
  #fi
}


download_sources()
{
  if command -v curl >/dev/null 2>&1; then
    download(){
      curl -s "$1"
  }
  elif command -v wget >/dev/null 2>&1; then
  #doesn't work yet
    download () {
      wget -q "$1"
  }
  fi

##
## See FilterLists for a comprehensive list of filter lists from all over the web
## https://filterlists.com/
##

sources=(
##
## Use StevenBlack/hosts mirrors to save bandwidth from original servers
## https://github.com/StevenBlack/hosts/tree/master/data
##  'https://adaway.org/hosts.txt'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/adaway.org/hosts'
##  'http://www.malwaredomainlist.com/hostslist/hosts.txt'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/malwaredomainlist.com/hosts'
##  'http://winhelp2002.mvps.org/hosts.txt'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/mvps.org/hosts'
##  'http://someonewhocares.org/hosts/hosts'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/someonewhocares.org/hosts'
##  'http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/yoyo.org/hosts'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/extensions/gambling/hosts'
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/data/tyzbit/hosts'
    'https://raw.githubusercontent.com/gorhill/uMatrix/master/assets/umatrix/blacklist.txt'
    'https://raw.githubusercontent.com/quidsup/notrack/master/trackers.txt'
    'https://raw.githubusercontent.com/Dawsey21/Lists/master/main-blacklist.txt'
    'http://sysctl.org/cameleon/hosts'
    'http://malwaredomains.lehigh.edu/files/justdomains'
    'https://isc.sans.edu/feeds/suspiciousdomains_High.txt'
    'https://raw.githubusercontent.com/zant95/hosts/master/hosts'
    'https://www.dshield.org/feeds/suspiciousdomains_Low.txt'
    'https://feodotracker.abuse.ch/blocklist/?download=domainblocklist'
    'https://palevotracker.abuse.ch/blocklists.php?download=domainblocklist'
    'https://ransomwaretracker.abuse.ch/downloads/RW_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/CW_C2_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/CW_PS_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/TC_C2_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/TC_PS_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/LY_C2_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/LY_PS_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/TL_C2_DOMBL.txt'
    'https://ransomwaretracker.abuse.ch/downloads/TL_PS_DOMBL.txt'
    'https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist'
    'http://adblock.gjtech.net/?format=unix-hosts'
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
#    'http://adblock.mahakala.is/' 
#    'http://mirror1.malwaredomains.com/files/justdomains'
#    'https://raw.githubusercontent.com/CaraesNaur/hosts/master/hosts.txt'
#SSL cerificate 'https://elbinario.net/wp-content/uploads/2015/02/BloquearPubli.txt'
#
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt'
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_malware.txt'
#    'https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt'
#
# https://github.com/brucebot/pisoft
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
)

  echo -e "\n\t FreeContributor is downloading data ..."
  for item in ${sources[*]}
  do
    echo -e "\n\t :: Downloading from URL: $item"
    download $item >> $TMP || { echo -e "\n\t Error downloading $item"; exit 1; }
  done
}

extract_domains()
{
# clean this code with better regex
# https://blog.mister-muffin.de/2011/11/14/adblocking-with-a-hosts-file/
# sed 's/\([^#]*\)#.*/\1/;s/[ \t]*$//;s/^[ \t]*//;s/[ \t]\+/ /g'
#

  echo -e "\n\t Extracting domains from previous lists ..."
  # remove empty lines and comments
  grep -Ev '^$' $TMP | \
  grep -o '^[^#]*'  | \
  # exclude locahost entries
  grep -v "localhost" | \
  # remove 127.0.0.1 and 0.0.0.0
  sed 's/127.0.0.1//;s/0.0.0.0//' | \
  # remove tab and spaces in the begining
  sed -e 's/^[ \t]*//' | \
  # remove ^M
  sed 's/\r//g' | grep -Ev '^$' | \
  sort | uniq > $DOMAINS

  echo -e "\n\t Domains extracted using ${FORMAT} format: $(cat ${DOMAINS} | wc -l )"

}

## none -------------------------------------------------------------------

domains()
{
  cp ${DOMAINS} > "${OUTPUTFILE:=$DIR/domains.txt}"
}

## hosts ------------------------------------------------------------------

hosts()
{
  if [ -f "${HOSTSCONF}" ]; then
    echo -e "\n\t Backing up your previous hosts file"
    cp "${HOSTSCONF}" "${HOSTSCONFBAK}"
  fi

  #Generate hosts header
  ./utils/hosts.header.sh 

  mv hosts.header "${OUTPUTFILE:=$HOSTSCONF}"

  while read line; do
    echo "${TARGET} ${line}" >> "${OUTPUTFILE:=$HOSTSCONF}"
  done < $DOMAINS

}


## dnsmasq -----------------------------------------------------------------

dnsmasq()
{
  mkdir -p "${DNSMASQDIR}"

  if [ -f "${DNSMASQCONF}" ]; then
    cp "${DNSMASQCONF}" "${DNSMASQCONFBAK}"
  fi

  if [ ${TARGET} = "NXDOMAIN" ]; then
    awk '{print "server=/"$1"/"}' $DOMAINS > "${OUTPUTFILE:=${DNSMASQDIR}/dnsmasq-master.conf}"

  else
    awk -v var="${TARGET}" '{print "address=/"$1"/"var}' $DOMAINS > "${OUTPUTFILE:=${DNSMASQDIR}/dnsmasq-master.conf}"
  fi


  #cp "${DIR}"/data/formats/dnsmasq.d/*.conf "${DNSMASQDIR}"
}

## unbound -----------------------------------------------------------------

unbound()
{
  if [ ${TARGET} = "NXDOMAIN" ]; then

#local-zone: "testdomain.test" static
#http://www.unixcl.com/2012/07/print-double-quotes-in-unix-awk.html

    awk '{print "local-zone: ""\x22"$1"\x22"" static"}' $DOMAINS > "${OUTPUTFILE:=${UNBOUNNDDIR}/unbound-master.conf}"

  else

#https://github.com/jodrell/unbound-block-hosts/
#https://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound
#local-zone: "example.tld" redirect
#local-data: "example.tld A 127.0.0.1"

    while read line; do
      echo "local-zone: \"${line}\" redirect" >> "${OUTPUTFILE:=${UNBOUNNDDIR}/unbound-master.conf}"
      echo "local-data: \"${line}\" ${TARGET}" >> "${OUTPUTFILE:=${UNBOUNNDDIR}/unbound-master.conf}"
    done < $DOMAINS
  fi
}

## pdnsd -------------------------------------------------------------------

pdnsd()
{
#https://news.ycombinator.com/item?id=3035825
#https://pgl.yoyo.org/adservers/serverlist.php?hostformat=pdnsd
#neg { name=example.tld; types=domain; }

  awk '{print "neg { name="$1"; types=domain; }"}' $DOMAINS > "${OUTPUTFILE:=${UNBOUNNDDIR}/pdnsd-master.conf}"
}


daemons()
{
INIT=`ls -l /proc/1/exe`
  if [[ $INIT == *"systemd"* ]]; then
    systemctl enable "${FORMAT}" && systemctl restart "${FORMAT}"
  elif [[ $INIT == *"upstart"* ]]; then
    service "${FORMAT}" start
  elif [[ $INIT == *"/sbin/init"* ]]; then
    INIT=`/sbin/init --version`
    if [[ $INIT == *"systemd"* ]]; then
      systemctl enable "${FORMAT}" && systemctl restart "${FORMAT}"
    elif [[ $INIT == *"upstart"* ]]; then
      service "${FORMAT}" start
    fi
  fi
}

finish()
{
cat <<'EOF'

    FreeContributor successfully installed
    Enjoy surfing in the web

    More info at https://tbds.github.io/FreeContributor/

EOF
}


## Main --------------------------------------------------------------------

welcome

#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#

if [ $NUMARGS -eq 0 ]; then
  usage
  exit 1
fi


while getopts ":t:f:o:h" opt; do
  case $opt in
    h)
      usage
      exit 1
    ;;
    f)
      FORMAT="$OPTARG"
    ;;
    o)
      OUTPUTFILE="$OPTARG"
    ;;
    t)
      TARGET="$OPTARG"
    ;;
    \?)
      echo -e "\n\tInvalid option: -$OPTARG" >&2
      usage
      exit 1
    ;;
  esac
done

shift "$((OPTIND-1))"


processing()
{
  #resolv
  dependencies
  download_sources
  extract_domains
}

case "$FORMAT" in
  "none")
    download_sources
    extract_domains
    domains
  ;;
  "hosts")
    download_sources
    extract_domains
    hosts
  ;;
  "dnsmasq")
    processing
    dnsmasq
    daemons
  ;;
  "unbound")
    processing
    unbound
    daemons
  ;;
  "pdnsd")
    processing
    pdnsd
    daemons
  ;;
   *)
    echo -e "\n\tInvalid option"
    usage
    exit 1
  ;;
esac

finish