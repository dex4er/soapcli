#!/usr/bin/perl

use warnings;
use strict;

use XML::LibXML;
use XML::Compile::WSDL11;
use XML::Compile::SOAP11;
use XML::Compile::Transport::SOAPHTTP;

use constant::boolean;
use File::Slurp;
use HTTP::Tiny;
use YAML::Syck qw(Dump LoadFile);
use JSON::PP;


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


my $arg_request = $ARGV[0];
my $servicename = do {
    if ($arg_request =~ /^{/) {
        '';
    }
    else {
        my $arg = $arg_request;
        $arg =~ s/\.(url|yml|wsdl)$//;
        $arg;
    };
};


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


my $request = do {
    if ($arg_request =~ /^{/) {
        JSON::PP->new->relaxed->allow_barekey->decode($arg_request);
    }
    else {
        LoadFile($arg_request);
    }
};


my $arg_operation = $ARGV[3];

my $wsdldom = XML::LibXML->load_xml(string => $wsdldata);
my $imports = $wsdldom->find('/wsdl:definitions/wsdl:types/xsd:schema/xsd:import');

my @schemas = map { $_->getAttribute('schemaLocation') } $imports->get_nodelist;

my $wsdl = XML::Compile::WSDL11->new;

$wsdl->importDefinitions(\@schemas);
$wsdl->addWSDL($wsdldom);

$wsdl->addHook({ type => 'xsd:hexBinary', replace => sub {
    my ($doc, $value, $path, $label, $replaced) = @_;
    defined $value or return;

    my $node = $doc->createElement($label);
    $node->appendText($value);
    return $node;
} });

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


my $operation = do {
    if (defined $arg_operation) {
        $arg_operation
    }
    elsif ($endpoint =~ s/^(.*)#(.*)$/$1/) {
        $2;
    }
    else {
        my $o = (keys %$request)[0];
        $request = $request->{$o};
        $o;
    }
};


my $http = XML::Compile::Transport::SOAPHTTP->new(
    address => $endpoint,
);

my $transport = $http->compileClient(
    action => $operation,
);


$wsdl->compileCalls(
    sloppy_floats   => TRUE,
    sloppy_integers => TRUE,
    transport       => $transport,
    $opt_debug ? (transport => sub { print $_[0]->toString(1); exit 2 }) : (),
);

my ($response, $trace) = $wsdl->call($operation, $request);

if ($opt_verbose) {
    print "---\n";
    $trace->printRequest;
    print Dump({ Data => { $operation => $request } }), "\n";

    print "---\n";
    $trace->printResponse;
    print Dump({ Data => $response }), "\n";
}
else {
    print Dump($response);
}
