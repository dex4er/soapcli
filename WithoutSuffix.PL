#!/usr/bin/env perl
use File::Copy;
copy("script/soapcli.pl","script/soapcli") or die "Copy failed: $!";
