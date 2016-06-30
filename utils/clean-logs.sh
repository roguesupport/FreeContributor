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
# for dnsmasq /etc/dnsmaq.conf
#
# For debugging purposes, log each DNS query as it passes through
# dnsmasq.
# log-queries
# log-facility=/var/log/dnsmasq.log

truncate --size 0 /var/log/dnsmaq.log

#
# for unbound /etc/unbound/unbound.conf
#
# the log file, "" means log to stderr.
# Use of this option sets use-syslog to "no".
# logfile: "/var/log/unbound.log"
#

truncate --size 0 /var/log/unbound.log
