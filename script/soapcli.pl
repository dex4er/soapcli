#!/usr/bin/perl

=head1 NAME

soapcli - SOAP client for CLI with YAML and JSON input

=head1 SYNOPSIS

  $ soapcli -v calculator.yml calculator.url

  $ soapcli -v '{add:{x:2,y:2}}' http://soaptest.parasoft.com/calculator.wsdl

  $ soapcli -v globalweather.yml globalweather.url '#GlobalWeatherSoap'

  $ soapcli '{CityName:"Warszawa",CountryName:"Poland"}' \
  http://www.webservicex.com/globalweather.asmx?WSDL \
  '#GlobalWeatherSoap' GetWeather

=head1 DESCRIPTION

This is command-line SOAP client which accepts YAML or JSON document as
an input data.

=cut


use 5.006;

use strict;
use warnings;

our $VERSION = '0.01';

use App::soapcli;

return App::soapcli->new_with_argv->run;


=head1 SEE ALSO

L<http://github.com/dex4er/soapcli>.

=head1 AUTHOR

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2011-2012 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See L<http://dev.perl.org/licenses/artistic.html>

=cut

__END__
