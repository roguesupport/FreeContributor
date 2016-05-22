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
# convert domains to various dns resolvers formats
#
# input: domain list and dns resolvers formats
#        

domain_list=$1
FORMAT=$2

hosts(){
  echo "Exporting to hosts format"
  grep -v '^#' $domain_list | \
  awk '{print "0.0.0.0 "$1}' > ./hosts.d/hosts-${domain_list}
}

dnsmasq(){
  echo "Exporting to dnsmasq format"
  grep -v '^#' $domain_list | \
  awk '{print "server=/"$1"/"}' > ./dnsmasq.d/dnsmasq-${domain_list}.conf
}

unbound(){
  echo "Exporting to unbound format"
  grep -v '^#' $domain_list | \
  awk '{print "local-zone: ""\x22"$1"\x22"" static"}'> ./unbound.d/unbound-${domain_list}.conf
}

pdnsd(){
  echo "Exporting to pdnsd format"
  grep -v '^#' $domain_list | \
  awk '{print "{ name="$1"; types=domain; }"}' > ./pdnsd.d/pdnsd-${domain_list}.conf
}

main(){
  case $FORMAT in
    h|hosts) hosts;;
    d|dnsmasq) dnsmasq;;
    u|unbound) unbound;;
    p|pdnsd) pdnsd ;;
    *) exit 1;;
  esac
}

main
