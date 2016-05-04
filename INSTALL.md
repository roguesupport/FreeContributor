## Install notes

First install a DNS cacher, such as dnsmasq using you package manager. 
For example for Debian/Ubuntu GNU/Linux distribution

    sudo apt-get install dnsmasq

Backup the `/etc/dnsmaq.conf` . Edit the dnsmaq.conf
or use configuration file provided in the conf directory

Edit the `/etc/resolv.conf` and put as first entry

    nameserver 127.0.0.1

Add two more DNS resolvers.

    # External nameservers
    nameserver <ip address>
    nameserver <ip address>

Protect the `/etc/resolv.conf`

    chattr +i /etc/resolv.conf


Enable and start the dnsmasq deamon.
If you use systemd:

    systemctl enable dnsmasq && systemctl start dnsmasq


Create the directory `/etc/dnsmasq.d` and select/copy the files in the
directory `data/dnsmasq.d`