#!/usr/bin/env perl

use strict;
use Storable qw(store retrieve);
use POSIX qw(strftime ceil);
my %website_hash = ();
my @prefetch_domain = ();
my $dnsmasq_log_file = '/mnt/mmcblk0p2/openwrt/var/log/dnsmasq.log';
my $hash_file = '/mnt/mmcblk0p2/openwrt/var/log/prefetch_domains.hash';
my $hash_file_2 = '/mnt/mmcblk0p2/openwrt/var/log/domains_popluarity.hash';

if (-e $hash_file_2) {
	%website_hash = %{retrieve($hash_file_2)};
}

open(my $fh, '<:encoding(UTF-8)', $dnsmasq_log_file)
  or die "Could not open file '$dnsmasq_log_file' $!";

my $re1 = qr/query\[A\]/;
my $re2 = qr/127\.0\.0\.1/;
my $re3 = qr/\b[a-z0-9.\-]+\.(?:com|org|cn|net)\b/;
my $re4 = qr/^(?:(?!msft|microsoft|mozilla|windows|msedge|imap|google|weather).)*$/;
while (my $row = <$fh>) {
	if ($row =~ $re1 && $row !~ $re2 && $row =~ $re3) {
		my $match = $&;
		if ($match =~ $re4) {
			if (exists($website_hash{$match})){
				$website_hash{$match} = $website_hash{$match} + 1;
			}
			else {
				$website_hash{$match} = 1;
			}
		}
	}
}
close $fh;

# open(my $fh, '>:encoding(UTF-8)', $dnsmasq_log_file);
# close $fh;

store \%website_hash, $hash_file_2;
my $today = strftime "%d", localtime;
my $lower_limit = ceil(exp($today/10 + 1));
# print $lower_limit;
while ((my $k,my $v) = each %website_hash) {
    if ($v >= $lower_limit) {
		push @prefetch_domain, $k;
	}
}
# print join("\n", @prefetch_domain);
store \@prefetch_domain, $hash_file;
