#!/usr/bin/env perl

use warnings;
use strict;

use XML::Compile::WSDL11;
use XML::Compile::SOAP11;
use XML::Compile::Transport::SOAPHTTP;

use constant::boolean;
use File::Slurp;
use HTTP::Tiny;
use YAML::Tiny qw(LoadFile Dump);


my $opt_d = FALSE;

scalar @ARGV || die "Usage: $0 [-d] data.yml [http://schema | schema.url]\n";

if ($ARGV[0] eq '-d') {
    $opt_d = TRUE;
    shift @ARGV;
};

my $servicename = $ARGV[0];
$servicename =~ s/\.(url|yml|wsdl)$//;

my $wsdlsrc = do {
    if (defined $ARGV[1]) {
        $ARGV[1];
    }
    elsif (-f "$servicename.wsdl") {
        "$servicename.wsdl";
    }
    else {
        "$servicename.url";
    }
};

my $wsdldata = do {
    if ($wsdlsrc =~ /\.wsdl$/) {
        read_file($wsdlsrc) if $wsdlsrc =~ /\.wsdl$/;
    }
    else {
        my $url = $wsdlsrc =~ m{://} ? $wsdlsrc : read_file($wsdlsrc, chomp=>TRUE);
        chomp $url;
        HTTP::Tiny->new->get($url)->{content};
    }
};


my $request = LoadFile("$servicename.yml");
my $operation = (keys %$request)[0];

my $wsdl = XML::Compile::WSDL11->new($wsdldata);

my $call = $wsdl->compileClient(
    operation       => $operation,
    sloppy_floats   => TRUE,
    sloppy_integers => TRUE,
    $opt_d ? (transport => sub { print $_[0]->toString; exit 2 }) : (),
);

my ($response, $trace) = $call->($request->{$operation});

print "---\n";
$trace->printRequest;
print Dump({Data => $request}), "\n";

print "---\n";
$trace->printResponse;
print Dump({Data => $response}), "\n";
