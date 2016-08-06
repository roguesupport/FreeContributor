#!/usr/bin/env bash
#
# FreeContributor: Simple DNS Ad Blocker. Enjoy a safe and faster web experience
# (c) 2016 by TBDS, gcarq
# https://github.com/tbds/FreeContributor
# https://github.com/gcarq/FreeContributor (forked)
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
#  * GNU awk
#  * GNU sed
#  * GNU grep
#  * GNU coreutils
#  * cURL
#  * Dnsmasq or Unbound or Pdnsd

set -e

## Global Variables---- --------------------------------------------------------
FREECONTRIBUTOR_VERSION='0.4.6'
REDIRECTIP4="${REDIRECTIP4:=0.0.0.0}"
REDIRECTIP6="${REDIRECTIP6:=::}"

TARGET="${TARGET:=$REDIRECTIP4}"
FORMAT="${FORMAT:=dnsmasq}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TMP_DOMAINS_RAW=$(mktemp /tmp/raw-domains.XXXXX)
TMP_DOMAINS=$(mktemp /tmp/domains.XXXXX)
FREECONTRIBUTOR_LOG="${FREECONTRIBUTOR_LOG:=/var/log/freecontributor.log}"

RESOLVCONF="${RESOLVCONF:=/etc/resolv.conf}"
RESOLVCONFBAK="${RESOLVCONFBAK:=/etc/resolv.conf.bak}"

## Change here the DNS servers
## More options see /conf/resolv.conf
DNSSERVER1="${DNSSERVER1:=91.239.100.100}"   ## anycast.censurfridns.dk
DNSSERVER2="${DNSSERVER2:=89.233.43.71}"     ## ns1.censurfridns.dk

DHCPDCONF="${DHCPDCONF:=/etc/dhcpcd.conf}"
NETCONF="${NETCONF:=/etc/NetworkManager/NetworkManager.conf}"

HOSTSCONF="${HOSTSCONF:=/etc/hosts}"
HOSTSCONFBAK="${HOSTSCONFBAK:=/etc/hosts.bak}"

DNSMASQDIR="${DNSMASQDIR:=/etc/dnsmasq.d}"
DNSMASQCONF="${DNSMASQCONF:=/etc/dnsmasq.conf}"
DNSMASQCONFBAK="${DNSMASQCONFBAK:=/etc/dnsmasq.conf.bak}"

UNBOUNDDIR="${UNBOUNDDIR:=/etc/unbound}"
UNBOUNDCONF="${UNBOUNDCONF:=/etc/unbound/unbound.conf}"
UNBOUNDCONFBAK="${UNBOUNDCONFBAK:=/etc/unbound/unbound.conf.bak}"

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


    Script to extract and convert domains lists from various sources.

    FreeContributor - http://github.com/tbds/FreeContributor
    Released under the GPLv3 license
    (c) 2016 tbds, gcarq and contributors

EOF
}

usage()
{
cat << EOF

    USAGE:

      $ $0 [-f format]  [-o out] [-t target]

       -f format: specify an output format:

                              none          Extract domains only
                              hosts         Use hosts format
                              dnsmasq       dnsmasq as DNS resolver
                              unbound       unbound as DNS resolver
                              pdnsd         pdnsd as DNS resolver

       -o out: specify an output file

       -t target: specify the target

                             ${REDIRECTIP4} (default)
                             ${REDIRECTIP6}
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
    echo -e "\033[5m \n\tYou need root or su rights to access /etc directory\033[0m"
    echo -e "\033[5m \tPlease install sudo or run this as root.\033[0m\n"
    usage
    exit 1
  fi
}


install_packages()
{
## Determine which package manager is being used
## https://github.com/icy/pacapt
##
##    pacman        by ArchLinux/Parabola, ArchBang, Manjaro, Antergos, Apricity OS
##    dpkg/apt-get  by Debian, Ubuntu, ElementaryOS, Linux Mint, etc ...
##    yum/rpm/dnf   by Red Hat, CentOS, Fedora, etc ...
##    zypper        by OpenSUSE

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
    echo -e "\n\t Ensure you have the following packages installed: $PRG"

  fi
}


dependencies()
{
  printf "    Checking dependencies...\n"

  DEPENDENCIES=("curl" "${FORMAT}")

  for PRG in "${DEPENDENCIES[@]}"
  do
    if [ ${PRG} != "hosts" ]; then
        echo -e "\n\t - Checking if $PRG is installed..."
        type -P $PRG &>/dev/null && echo -e "\t Status: Ok" || install_packages
    fi
  done
}


logging() 
{
  if [ ! -f "$FREECONTRIBUTOR_LOG" ]; then
    touch "$FREECONTRIBUTOR_LOG"
    chmod 644 "$FREECONTRIBUTOR_LOG"
  fi
}



resolv()
{
  if [ -f "$RESOLVCONF" ]; then
    cp $RESOLVCONF $RESOLVCONFBAK
    cp $DIR/conf/resolv.conf $RESOLVCONF

    sed -i "s/#DNSSERVER1/$DNSSERVER1/g" $RESOLVCONF
    sed -i "s/#DNSSERVER2/$DNSSERVER2/g" $RESOLVCONF

  fi

## Prevent the dhcpcd daemon from overwriting /etc/resolv.conf
  if [ -f "$DHCPDCONF" ]; then 
    if ! grep -Fxq "nohook resolv.conf" "$DHCPDCONF"; then
      echo -e "\nnohook resolv.conf" >> "$DHCPDCONF"
    fi

    #if ! grep -q "^static domain_name_servers" "$DHCPDCONF"; then
    #  echo -e "\nstatic domain_name_servers=$DNSSERVER1 $DNSSERVER2" >> "$DHCPDCONF"
    #fi
  fi
}


download_sources()
{

sources=(
##
## See FilterLists for a comprehensive list of filter lists from all over the web
## https://filterlists.com/
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
## Spam 404
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
#   'https://raw.githubusercontent.com/mat1th/Dns-add-block/master/domains'
## Adblock lists
##
## https://www.reddit.com/r/pihole/comments/4p2tp7/adding_easylist_and_other_adblocklike_sources_to/
##
#   'https://raw.githubusercontent.com/tbds/FreeContributor/master/data/corporations/adblock.list'
## Mirror
    'https://raw.githubusercontent.com/notracking/hosts-blocklists/master/hostnames.txt'
## https://github.com/crazy-max/WindowsSpyBlocker
    'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/win10/extra.txt'
    'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/win10/spy.txt'
    'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/win10/update.txt'
## Disconnect Lists
    'https://raw.githubusercontent.com/tbds/FreeContributor/master/data/mirrors/disconnect_ad'
    'https://raw.githubusercontent.com/tbds/FreeContributor/master/data/mirrors/disconnect_malvertising'
    'https://raw.githubusercontent.com/tbds/FreeContributor/master/data/mirrors/disconnect_malware'
    'https://raw.githubusercontent.com/tbds/FreeContributor/master/data/mirrors/disconnect_tracking'
## Mahakala - Mother of All Ad Blocks list
#    'https://raw.githubusercontent.com/tbds/FreeContributor/master/data/mirrors/mahakala'
## Airelle's host file mirror
#    'https://raw.githubusercontent.com/tbds/FreeContributor/master/data/mirrors/Hosts.rsk'
#    'https://raw.githubusercontent.com/tbds/FreeContributor/master/data/mirrors/Hosts.sex'
#    'https://raw.githubusercontent.com/tbds/FreeContributor/master/data/mirrors/Hosts.mis'
#    'https://raw.githubusercontent.com/tbds/FreeContributor/master/data/mirrors/Hosts.pub'
#
)

  printf "\n    FreeContributor is downloading data...\n"
  for item in ${sources[*]}
  do
    #printf "\n    :: Downloading from URL: $item $date" >> "$FREECONTRIBUTOR_LOG"
    curl -s $item >> $TMP_DOMAINS_RAW || { echo -e "\n\t Error downloading $item"; }
  done
}

extract_domains()
{
  printf "\n    Extracting domains from previous lists...\n"

## Replacments are done in the following order:
##   > transform everything to lowercase
##   > strip comments starting with '#'
##   > replace substr '127.0.0.1' with ''
##   > replace substr '0.0.0.0' with ''
##   > strip ^M (windows newline character)
##   > ltrim tabs and whitespaces
##   > rtrim tabs and whitespaces
##   > remove lines which only contain an ipv4 addresses
##   > remove 'localhost' lines
##   > delete empty lines
## Remove invalid FQDNs (https://en.wikipedia.org/wiki/Fully_qualified_domain_name)
REGEX_IPV4_VALIDATION="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.)\
{3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"

  sed -ir "s/\(.*\)/\L\1/;               \
           s/#.*$//;                     \
           s/127.0.0.1//;                \
           s/0.0.0.0//;                  \
           s/\^M//;                      \
           s/^[[:space:]]*//;            \
           s/[[:space:]]*$//;            \
           s/${REGEX_IPV4_VALIDATION}//; \
           /^localhost$/d;               \
           /^[[:space:]]*$/d;            \
          " ${TMP_DOMAINS_RAW}

  ## Remove duplicate lines
  awk -i inplace '!x[$0]++' ${TMP_DOMAINS_RAW}

  grep -Po '(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)' \
  ${TMP_DOMAINS_RAW} > ${TMP_DOMAINS}

  echo -e "\n\t Domains extracted using ${FORMAT} format: $(cat ${TMP_DOMAINS} | wc -l )"
}

## none -------------------------------------------------------------------

domains()
{
  cp ${TMP_DOMAINS} "${OUTPUTFILE:=$DIR/domains.txt}"
  echo -e "\n\t File saved at: ${OUTPUTFILE}"
}

## hosts ------------------------------------------------------------------

hosts()
{
  if [ -f "${HOSTSCONF}" ]; then
    cp "${HOSTSCONF}" "${HOSTSCONFBAK}"
  fi

  if [ ${TARGET} = "NXDOMAIN" ]; then
    echo -e "\n\t hosts format does not support target NXDOMAIN."
    exit 0
  fi

  ## Generate hosts header
  ./utils/hosts.header.sh

  mv hosts.header "${OUTPUTFILE:=$HOSTSCONF}"

  while read line; do
    echo "${TARGET} ${line}" >> "${OUTPUTFILE:=$HOSTSCONF}"
  done < $TMP_DOMAINS
}


## dnsmasq -----------------------------------------------------------------

dnsmasq()
{
  mkdir -p "${DNSMASQDIR}"

  if [ -f "${DNSMASQCONF}" ]; then
    cp "${DNSMASQCONF}" "${DNSMASQCONFBAK}"
  fi

  cp "${DIR}"/conf/dnsmasq.conf "${DNSMASQCONF}"

  if [ ! -f /var/log/dnsmaq.log ]; then
    touch /var/log/dnsmaq.log
    chmod 644 /var/log/dnsmaq.log
    chown dnsmasq:root /var/log/dnsmaq.log
  fi
}


  ## Test the dnsmasq conf
  ## dnsmasq --test

  ## NetworkManager has a plugin to enable DNS caching using dnsmasq
  ## https://wiki.archlinux.org/index.php/Dnsmasq#NetworkManager
  #if [ -f "${NETCONF}" ]; then
  #  sed -i 's/dns=*/dns=dnsmasq/g' "${NETCONF}"
  #fi

  if [ ${TARGET} = "NXDOMAIN" ]; then
    awk '{print "server=/"$1"/"}' $TMP_DOMAINS > "${OUTPUTFILE:=${DNSMASQDIR}/dnsmasq-master.conf}"

  else
    awk -v var="${TARGET}" '{print "address=/"$1"/"var}' $TMP_DOMAINS > "${OUTPUTFILE:=${DNSMASQDIR}/dnsmasq-master.conf}"
  fi
}

## unbound -----------------------------------------------------------------

unbound()
{
  mkdir -p "${UNBOUNDDIR}"

  if [ -f "${UNBOUNDCONF}" ]; then
    cp "${UNBOUNDCONF}" "${UNBOUNDCONFBAK}"
  fi

  cp "${DIR}"/conf/unbound.conf "${UNBOUNDCONF}"

  curl -s https://www.internic.net/domain/named.cache -o "${UNBOUNDDIR}"/root.hints

  if [ ${TARGET} = "NXDOMAIN" ]; then

    ## local-zone: "testdomain.test" static
    awk '{print "local-zone: ""\x22"$1"\x22"" static"}' $TMP_DOMAINS > "${OUTPUTFILE:=${UNBOUNDDIR}/unbound-master.conf}"

  elif [ -f "${OUTPUTFILE:=${UNBOUNDDIR}/unbound-master.conf}" ]; then

    rm "${OUTPUTFILE:=${UNBOUNDDIR}/unbound-master.conf}"

    while read line; do
    ## local-zone: "example.tld" redirect
    ## local-data: "example.tld A 127.0.0.1"
      echo "local-zone: \"${line}\" redirect"    >> "${OUTPUTFILE:=${UNBOUNDDIR}/unbound-master.conf}"
      echo "local-data: \"${line} A ${TARGET}\"" >> "${OUTPUTFILE:=${UNBOUNDDIR}/unbound-master.conf}"
    done < $TMP_DOMAINS
  fi

  if [ ! -f ${UNBOUNDDIR}/unbound_server.key ]; then
    ## Setting up unbound-control to generate a self-signed certificate 
    ## and private key for the server, as well as the client
    unbound-control-setup
  fi

  unbound-checkconf "${UNBOUNDCONF}"
}

## pdnsd -------------------------------------------------------------------

pdnsd()
{
  mkdir -p "${PDNSDDIR}"

  if [ -f "${PDNSDCONF}" ]; then
    cp "${PDNSDCONF}" "${PDNSDCONFBAK}"
  fi

  cp "${DIR}"/conf/pdnsd.conf "${PDNSDCONF}"

  if [ ${TARGET} != "NXDOMAIN" ]; then
    echo -e "Pdnsd format does only support target NXDOMAIN."
  fi

  ## neg { name=example.tld; types=domain; }
  awk '{print "neg { name="$1"; types=domain; }"}'  $TMP_DOMAINS > "${OUTPUTFILE:=${PDNSDDIR}/pdnsd-master.conf}"
  #awk '{print "neg { name="$1"; types=A,AAAA; }"}' $TMP_DOMAINS > "${OUTPUTFILE:=${PDNSDDIR}/pdnsd-master.conf}"
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

if [ $# -eq 0 ]; then
  echo -e "\n\t Do you wish to use the default settings?"
  echo -e "\t ./FreeContributor.sh -f dnsmasq -t NXDOMAIN\n"
  select yn in "Yes" "No"; do
    case $yn in
        Yes ) ./FreeContributor.sh -f dnsmasq -t NXDOMAIN;;
        No )  ./FreeContributor.sh -h;;
    esac
  done
fi

while getopts ":t:f:o:h" opt; do
  case $opt in
    h) usage; exit 0;;
    f) FORMAT="$OPTARG";;
    o) OUTPUTFILE="$OPTARG";;
    t) TARGET="$OPTARG";;
    \?) echo -e "\n\tInvalid option: -$OPTARG" >&2; usage; exit 0;;
  esac
done
shift "$((OPTIND-1))"

processing()
{
  rootcheck
  resolv
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
    processing
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