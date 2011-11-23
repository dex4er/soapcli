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


my ($opt_debug, $opt_verbose);

scalar @ARGV || ($ARGV[0]||'') eq '-h' || die "Usage: $0 [-d] [-v] data.yml [http://schema | schema.url]\n";

if ($ARGV[0] eq '-d') {
    $opt_debug = TRUE;
    shift @ARGV;
};
if ($ARGV[0] eq '-v') {
    $opt_verbose = TRUE;
    shift @ARGV;
};


my $arg_servicename = $ARGV[0];
(my $servicename = $arg_servicename) =~ s/\.(url|yml|wsdl)$//;


my $arg_wsdl = $ARGV[1];

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


my $arg_endpoint = $ARGV[2];


my $request = LoadFile("$servicename.yml");
my $operation = (keys %$request)[0];

my $wsdl = XML::Compile::WSDL11->new($wsdldata);

my $endpoint = do {
    if (defined $arg_endpoint) {
        my $url = $arg_endpoint =~ m{://} ? $arg_endpoint : read_file($arg_endpoint, chomp=>TRUE);
        chomp $url;
        $url;
    }
    else {
	$wsdl->endPoint;
    }
};


my $http = XML::Compile::Transport::SOAPHTTP->new(
    address => $endpoint,
);

my $transport = $http->compileClient(
    action => $operation,
);


my $call = $wsdl->compileClient(
    operation       => $operation,
    sloppy_floats   => TRUE,
    sloppy_integers => TRUE,
    transport       => $transport,
    $opt_debug ? (transport => sub { print $_[0]->toString(1); exit 2 }) : (),
);

my ($response, $trace) = $call->($request->{$operation});

if ($opt_verbose) {
    print "---\n";
    $trace->printRequest;
    print Dump({Data => $request}), "\n";

    print "---\n";
    $trace->printResponse;
    print Dump({Data => $response}), "\n";
}
else {
    print Dump($response);
}
