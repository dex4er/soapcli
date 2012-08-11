# NAME

soapcli - SOAP client for CLI with YAML and JSON input

# SYNOPSIS

    $ soapcli -v calculator.yml calculator.url

    $ soapcli -v '{add:{x:2,y:2}}' http://soaptest.parasoft.com/calculator.wsdl

    $ soapcli -v globalweather.yml globalweather.url '#GlobalWeatherSoap'

    $ soapcli '{CityName:"Warszawa",CountryName:"Poland"}' \
    http://www.webservicex.com/globalweather.asmx?WSDL \
    '#GlobalWeatherSoap' GetWeather

# DESCRIPTION

This is command-line SOAP client which accepts YAML or JSON document as
an input data.

# SEE ALSO

[http://github.com/dex4er/soapcli](http://github.com/dex4er/soapcli).

# AUTHOR

Piotr Roszatycki <dexter@cpan.org>

# LICENSE

Copyright (c) 2011-2012 Piotr Roszatycki <dexter@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

See [http://dev.perl.org/licenses/artistic.html](http://dev.perl.org/licenses/artistic.html)
