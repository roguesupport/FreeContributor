#!/bin/sh
#
# convert domains to dnsmasq format
#
# input: domain list

domain_list=$1

grep -v '^#' $domain_list | \
awk '{print "address=/"$1"/"}' > ./dnsmasq.d/dnsmasq-$domain_list


