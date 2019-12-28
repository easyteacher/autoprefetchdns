#!/usr/bin/env perl
use strict;
use Storable;
use Socket;
use Sys::Syslog;
use Time::HiRes qw(usleep);

my $dnsmasq_log_file = '/mnt/mmcblk0p2/openwrt/var/log/dnsmasq.log';
my $hash_file = '/mnt/mmcblk0p2/openwrt/var/log/prefetch_domains.hash';
my $prefetch_domain;
if (-e $hash_file) {
	$prefetch_domain = retrieve($hash_file);
}
else {
	die;
}
my $count = 0;
foreach (@$prefetch_domain)
{
	# system("nslookup $_ 127.0.0.1#53 >/dev/null");
	gethostbyname($_) or warn "Can't resolve $_: $!\n";
	$count++;
	usleep(100);
}
openlog("Prefetcher", 'pid', "LOG_USER");
syslog("LOG_INFO", "$count domains have been prefetched.");
closelog();
open(my $fh, '>:encoding(UTF-8)', $dnsmasq_log_file);
close $fh;