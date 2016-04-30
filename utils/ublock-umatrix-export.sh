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
# Extract blocked domains from uMatrix or uBlock Origin rules
# uMatrix https://github.com/gorhill/uMatrix/
# uBlock Origin https://github.com/gorhill/uBlock
#
# input:
#  - format to export
#  - filename from uMatrix (default my-umatrix-rules.txt) or
#  uBlock (default my-ublock-dynamic-rules-date.txt)
#
#
# arguments

OPT=$1   # option
FILE=$2  # filename

usage(){
echo "Select format to export"
echo "Options:"
echo "      -[d]omains:   extract domains"
echo "      -[h]hosts :   for hosts format"
echo "      -[dn]smasq:   for dnsmasq format"
echo "      -[u]mbound:   for unbound format"
echo "      -[p]dnsd  :   for pdnsd format"
echo "Example:"
echo "./ublock-umatrix-export.sh hosts my-umatrix.rules"
}


header(){
  echo "Wich line starts the blocking domains?"
  read header;
  echo "The blocked domains starts at line $((header + 1))"
}


info(){
  local out="$1"
  echo "Domains extracted successful"
  echo "Number of domains extracted: $(wc -l $out)"
  echo "The domains are stored in filename $out"
}


domains(){
  tail -n +$((header + 1)) $FILE | \
  grep "block" | \
  sort | uniq | \
  awk '{print $2}' > domains

  info domains
}


hosts(){
  tail -n +$((header + 1)) $FILE | \
  grep "block" | \
  sort | uniq | \
  awk '{print "0.0.0.0 "$2}' > hosts

  info hosts
}


dnsmasq(){
  tail -n +$((header + 1)) $FILE | \
  grep "block" | \
  sort | uniq | \
  awk '{print "address=/"$2"/"}' > dnsmasq-umatrix.conf

  info dnsmasq-umatrix.conf
}


unbound(){
  tail -n +$((header + 1)) $FILE | \
  grep "block" | \
  sort | uniq | \
  awk '{print "local-zone: ""\x22"$2"\x22"" static"}' > unbound-umatrix.conf

  info unbound-umatrix.conf
}


pdnsd(){
  tail -n +$((header + 1)) $FILE | \
  grep "block" | \
  sort | uniq | \
  awk '{print "{ name="$2"; types=domain; }"}' > pdnsd-umatrix.conf

  info pdnsd-umatrix.conf
}


main(){
  if [ "$#" -ne 2 ]; then
    usage
  fi

  header
  case $OPT in
    d|domains) domains;;
    h|hosts) hosts;;
    dn|dnsmasq) dnsmasq ;;
    u|unbound) unbound;;
    p|pdnsd) pdnsd ;;
    *) echo "Bad argument!"; usage ;;
  esac
}


main
