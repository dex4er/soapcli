#!/usr/bin/env perl

use warnings;
use strict;

use XML::Compile::SOAP::Daemon::NetServer;
use XML::Compile::WSDL11;
use XML::Compile::SOAP11;

use XML::Compile::Util 'pack_type';
use XML::Compile::SOAP::Util 'SOAP11ENV';

use Log::Report syntax => 'SHORT';

use Exception::Base
    'Exception::My::SOAP::Operation' => { isa => 'Exception::Died' };

use English;

dispatcher PERL => 'default', mode => 'VERBOSE';

my $wsdl_filename = 'calculator.wsdl';

my $wsdl = XML::Compile::WSDL11->new($wsdl_filename);

my $daemon = My::XML::Compile::SOAP::Daemon::NetServer->new;


$daemon->operationsFromWSDL(
    $wsdl,
    callbacks => {
        add => sub {
            my ($soap, $data) = @_;
            return +{
                Result => $data->{parameters}->{x} + $data->{parameters}->{y},
            };
        },
        subtract => sub {
            my ($soap, $data) = @_;
            return +{
                Result => $data->{parameters}->{x} - $data->{parameters}->{y},
            };
        },
        multiply => sub {
            my ($soap, $data) = @_;
            return +{
                Result => $data->{parameters}->{x} * $data->{parameters}->{y},
            };
        },
        divide => sub {
            my ($soap, $data) = @_;

            my $result = eval {
                $data->{parameters}->{numerator} / $data->{parameters}->{denominator};
            };
            if ($EVAL_ERROR) {
                my $e = Exception::My::SOAP::Operation->catch;
                mistake $e;
                return +{
                    Fault => {
                        faultcode => pack_type(SOAP11ENV, 'Client'),
                        faultstring => $e->eval_error,
                        faultactor => $soap->role,
                    }
                };
            };

            return +{
                Result => $result,
            };
        },
    },
);

$daemon->setWsdlResponse($wsdl_filename);

$daemon->run(
    port => $ARGV[0] || 8980,
    name => $0,
);


package My::XML::Compile::SOAP::Daemon::NetServer;
use base 'XML::Compile::SOAP::Daemon::NetServer';
use Log::Report syntax => 'SHORT';

sub default_values {
    +{ log_file => 'Log::Report', log_level => 2, client_maxreq => 1, client_reqbonus => 0, client_timeout => 30 }
}

sub process {
    my $self = shift;
    notice "Request\n---\n" . $_[1]->as_string . "---";
    my @response = $self->SUPER::process(@_);
    notice "Response\n---\n" . $response[2]->toString . "---";
    return @response;
}
