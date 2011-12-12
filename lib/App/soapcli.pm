package App::soapcli;

=head1 NAME

App::soapcli - SOAP client for CLI with YAML and JSON input

=head1 SYNOPSIS

This is a package with sopacli(1) utility.

Example:

  $ soapcli -v calculator.yml calculator.url

  $ soapcli -v '{add:{x:2,y:2}}' http://soaptest.parasoft.com/calculator.wsdl

  $ soapcli -v globalweather.yml globalweather.url '#GlobalWeatherSoap'

  $ soapcli '{CityName:"Warszawa",CountryName:"Poland"}' \
  http://www.webservicex.com/globalweather.asmx?WSDL \
  '#GlobalWeatherSoap' GetWeather

=cut


use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';


1;


=head1 SEE ALSO

L<http://github.com/dex4er/soapcli>, soapcli(1).

=head1 AUTHOR

Piotr Roszatycki <dexter@cpan.org>

=head1 LICENSE

Copyright (c) 2011 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See L<http://dev.perl.org/licenses/artistic.html>
