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

# https://unix.stackexchange.com/questions/92384/how-to-clean-log-file
#
# from /etc/dnsmaq.conf
#
# For debugging purposes, log each DNS query as it passes through
# dnsmasq.
# log-queries
# log-facility=/var/log/dnsmasq.log

truncate --size 0 /var/log/dnsmaq.log