<!-- language: lang-none -->
      ______              _____            _        _ _           _             
     |  ____|            / ____|          | |      (_) |         | |            
     | |__ _ __ ___  ___| |     ___  _ __ | |_ _ __ _| |__  _   _| |_ ___  _ __ 
     |  __| '__/ _ \/ _ \ |    / _ \| '_ \| __| '__| | '_ \| | | | __/ _ \| '__|
     | |  | | |  __/  __/ |___| (_) | | | | |_| |  | | |_) | |_| | || (_) | |   
     |_|  |_|  \___|\___|\_____\___/|_| |_|\__|_|  |_|_.__/ \__,_|\__\___/|_|   
                                                                                                                                                        

Enjoy a safe and faster web experience

TL:DR `cat domains-{ads,tracking,malware} > dev/null`

## Intro

This bash script intends to extract domains lists from various sources.
It is a replacement for ad blocking extensions in your browser.
It blocks ads, malware, trackers at DNS level.

## Why

 - [Major sites including New York Times and BBC hit by 'ransomware' malvertising](http://www.theguardian.com/technology/2016/mar/16/major-sites-new-york-times-bbc-ransomware-malvertising)
 - [Adblocking: advertising 'accounts for half of data used to read articles'](http://www.theguardian.com/media/2016/mar/16/ad-blocking-advertising-half-of-data-used-articles)

## What the scripts does?

 - Backup the original configuration file
 - Download and merge domains lists from various sources.
 - Create a cron job to automaticly update the hosts file, default every week (optional)

## Benefits

 - Low CPU and RAM usage.
 - Speeds up your Internet use since the local dnsmasq file is checked first, before send a DNS request.
 - Data savings since the ad content is never downloaded.
 - Not just for browsers, it blocks ads and malware across the entire operative system.
 - Stops ad tracking.
 - Blocks spyware and malware. That increases the safety of your networking experience.

## Dependencies


 - [GNU bash](http://www.gnu.org/software/bash/bash.html)
 - [GNU sed](http://www.gnu.org/software/sed)
 - [GNU grep](http://www.gnu.org/software/grep/grep.html)
 - [GNU coreutils](http://www.gnu.org/software/coreutils)
 - [curl](http://curl.haxx.se/)
 - [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)

## Install

```sh
git clone https://github.com/tbds/FreeContibutor
cd FreeContibutor/src
sudo ./installer.sh
```


#### Sources

FreeContributor downloads external files; each has its own license, detailed in the list below.


| URL                                                                              | License |
| -------                                                                          | ------- |
|[Adaway list](https://adaway.org/hosts.txt)                                       | |
|[MVPS Hosts](http://winhelp2002.mvps.org/hosts.htm)                               | CC Attribution-NonCommercial-ShareAlike 4.0 |
|[hpHosts’s ad and tracking servers‎](http://www.hosts-file.net/)                   | |
|[Peter Lowe’s Ad server list](http://pgl.yoyo.org/adservers/)                     | |
|[Dan Pollock’s hosts file](http://someonewhocares.org/hosts/)                     | |
|[CAMELEON](http://sysctl.org/cameleon/)                                           | |
|[StevenBlack/hosts](https://github.com/StevenBlack/hosts/)                        | |
|[quidsup/notrack](https://github.com/quidsup/notrack)                             | |
|[gorhill's uMatrix Blocklist](https://github.com/gorhill/uMatrix/umatrix)         | |
|[Malware Domain List ](http://www.malwaredomainlist.com/hostslist/hosts.txt)      | |
|[AdBlock Manager](http://adblock.gjtech.net/?format=unix-hosts)                   | CC Attribution 3.0 |
|[David Alexander Harvey, Henry Hertz Hobbit, Danny R Johnston and Eric Phelps](http://hostsfile.org/hosts.html) hostfile project | LGPL as GPLv2 |
|[Airelle's host file](http://rlwpx.free.fr/WPFF/hosts.htm)                        | |
|[The Hosts File Project](http://hostsfile.mine.nu)                                | LGPL |
|[Mahakala](http://adblock.mahakala.is/)                                           | |
|[Secure Mecca](http://securemecca.com/Downloads/hosts.txt)                        | |
|[spam404scamlist](http://spam404bl.com/spam404scamlist.txt)                       | |
|[Malwaredomains](http://malwaredomains.lehigh.edu/files/domains.txt)              | |
|[Adzhosts](http://optimate.dl.sourceforge.net/project/adzhosts/HOSTS.txt)         | |
|[Zeustracker](https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist)| |
|[hosts.eladkarako.com](http://hosts.eladkarako.com/hosts.txt)                     | |
|[Malekal](http: //www.malekal.com/HOSTS_filtre/HOSTS.txt)                         | |

## License

FreeContributor is licensed under the [General Public License (GPL) version 3](https://www.gnu.org/licenses/gpl.html)

The ASCII art logo at the top was made using [FIGlet](http://www.figlet.org/).