## Install notes

First install a DNS resolver, such as dnsmasq using you package manager. 
For example for Debian/Ubuntu GNU/Linux distribution

    sudo apt-get install dnsmasq

Backup the `/etc/dnsmaq.conf` . Edit the dnsmaq.conf
or use configuration file provided in the conf directory

### Choose the DNS servers

You have two options:

1) resolv.conf

Edit the `/etc/resolv.conf` and put as first entry

    nameserver 127.0.0.1

Add two more DNS resolvers.

    # External nameservers
    nameserver <ip address>
    nameserver <ip address>

Protect the `/etc/resolv.conf`

    chattr +i /etc/resolv.conf

2) dnsmasq.resolv.conf

Edit `/etc/dnsmaq.conf` and add the following line

    resolv-file=/etc/dnsmasq.resolv.conf

and add in `/etc/dnsmasq.resolv.conf` the external DNS servers

    # External nameservers
    nameserver <ip address>
    nameserver <ip address>


Enable and start the dnsmasq deamon.
If you use systemd:

    systemctl enable dnsmasq && systemctl start dnsmasq


Create the directory `/etc/dnsmasq.d` and select/copy the files in the
directory `data/dnsmasq.d`

After you have correctly configure your dnsmasq as your DNS cache server,
you can test it with command

    › nslookup <website.tld>


To examine the query process, uncommnent `log-queries` in `/etc/dnsmasq.conf` and watch syslog with command:

    sudo tail -f /var/log/syslog

Or manually start dnsmasq with the following options:

    sudo dnsmasq -q -d