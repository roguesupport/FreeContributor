# FreeContributor

Enjoy a safe and faster web experience (*still alpha*)

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

 - [curl](http://curl.haxx.se/)
 - [GNU bash](http://www.gnu.org/software/bash/bash.html)
 - [GNU sed](http://www.gnu.org/software/sed)
 - [GNU grep](http://www.gnu.org/software/grep/grep.html)
 - [GNU coreutils](http://www.gnu.org/software/coreutils)
 - [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)

## License

FreeContributor is licensed under [GNU GPL](http://www.gnu.org/licenses/gpl-3.0.txt)