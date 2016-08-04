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

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

formatsdir=${dir}/formats

mkdir -p "${formatsdir}"/dnsmasq.d \
         "${formatsdir}"/unbound.d \
         "${formatsdir}"/pdnsd.d   \
         "${formatsdir}"/hosts.d

lists=$(find ${dir}/corporations -type f -printf "%f\n")
formats=(hosts dnsmasq unbound pdnsd)

for list in ${lists[@]}; do
    for format in ${formats[@]}; do
        ./domain-to-dns.sh $list $format
    done
done
