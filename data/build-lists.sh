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

mkdir -p dnsmasq.d unbound.d pdnsd.d hosts.d

lists=$(ls *.list)
formats=(hosts dnsmasq unbound pdnsd)

for list in ${lists[@]}; do
    for format in ${formats[@]}; do
        ./domain-dns-format.sh $list $format
    done
done
