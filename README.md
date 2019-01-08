# UniFiTooling

This is an early beta version for an PowerShell Module for the Ubiquiti UniFi Controller API.

I use this module for many automated updates for my UniFi Security Gateway Firewall Rules and do a few other things automated.

### Use Cases

Please see the [UseCases](UseCases) directory.

### Version

This document is based on UniFiTooling version 1.0.5

### PowerShell Gallery

When the Module is stable, I will publish it on the PowerShell Gallery.

### Feedback

Any Feedback is appreciated! Please open a [GitHub issue](https://github.com/jhochwald/PowerShell-collection/issues/new/choose) as *Bug report* if you find something not working.

### Contribute

Anything missing? Please open a [GitHub issue](https://github.com/jhochwald/PowerShell-collection/issues/new/choose) as *Feature request*. Suggest an idea for this Module will help to improve this module.

### Description

PowerShell Module for Ubiquiti UniFi Security Gateway automation via the API of the Ubiquiti UniFi Controller

### Note

Early beta version, use at your own risk!

### Config

Keep this file in a secure place, especially in a shared environment. It contains the credentials (Yes, username and password) of your UniFi Admin User in plain text (human readable).



**The config file (config.json) needs to be in the acctual directory. At least for now, only `./config.json` is supported.**



Here is a sample configuration:

```json
{
   "Login": {
      "Username": "adminuser",
      "Password": "AdminPassword"
   },
   "protocol": "https",
   "SelfSignedCert": true,
   "Hostname": "unifi.contoso.com",
   "Port": 443
}
```

#### Username

The login of a UniFi User with admin rights

#### Password

The password for the user given above. It is clear text for now. I know... But the Ubiquiti UniFi Controller seems to understand plain text only.

I plan to use a hashed and/or encryted version for a future version. But during the runtime, it is still as human readable clear text in memory and the `Invoke-UniFiApiLogin` furthermore, sends it as human readable clear text information within a JSON formatted body.

#### protocol

Valid is `http` and `https`. Please note: `http` is untested and it might not even work!

#### SelfSignedCert

If you use a self signed certificate and/or a certificate from an untrusted CA, you might want to use `true` here.
This is a Bool, but only `true` or `false` for now.

*Please note and read real carefully:*
I can be dangerous to trust a certificate without checking it! I think it is OK to do within an Intranet, but I would avoid doing it over the public Internet!

Especially with the `Invoke-UniFiApiLogin` command, because this will send the Credentials (Yes, username and password) of your UniFi Admin User in clear text in a JSON based body. If this is intercepted you might be in real danger!

To mitigate: After each action, the workaround to except signed certificate and/or a certificate from an untrusted CA is removed.

#### Hostname

The Ubiquiti UniFi Controller you want to use. You can use a Fully-Qualified Host Name (FQHN) or an IP address. Please note that your certificate must match the name and/or IP address as SAN name. Otherwise you might need to set the `SelfSignedCert` to `true`.

#### Port

The port number that you have configured on your Ubiquiti UniFi Controller.

### Examples

I started to publich some demo use cases, so I decided to remove the samples here.

### Authors

Joerg Hochwald - [http://hochwald.net](http://hochwald.net)

### Contributors

N.N. (could be you)

### Copyright

Copyright (c) 2019, [enabling Technology](http://www.enatec.io)
All rights reserved.

### License

BSD 3-Clause "New" or "Revised" License. - [Online](https://github.com/jhochwald/PowerShell-collection/blob/master/LICENSE)

### Keywords

UniFi, API, Automation, Ubiquiti,USG, RESTful, ubiquiti-unifi-controller, unifi-controller
