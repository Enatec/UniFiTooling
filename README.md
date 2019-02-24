# UniFiTooling

PowerShell Module to configure, manage, and automate Ubiquiti (*UBNT*) UniFi [SDN Controller](https://unifi-sdn.ui.com/) API processes.

This module supports all main functions to configure, manage and automate the Ubiquiti (*UBNT*) UniFi Wi-Fi equipment, the UniFi Security Gateway (*USG*), and the UniFi Switches (*USW*). Additionally the UniFi [SDN Controller](https://unifi-sdn.ui.com/) functions are supported, for example the administration of Users/Clients and guests management.

The whole thing was started some time ago as an internal tooling to deploy, manage and update UniFi Security Gateway (*USG*) Firewall rules and to automate our (internal) administrative processes.

After using it for a while, we decided to would like to have everything in a generic PowerShell Module. Shortly after starting the process, we decided to make it available as open source!

The transfer of the old functions, however, is a bit more difficult than expected! Everything was built in individual and isolated tools, where everything was hard coded. In addition, the UniFi [SDN Controller](https://unifi-sdn.ui.com/) API is not really documented.

## Supported Equipment

* Ubiquiti (*UBNT*) UniFi Wi-Fi equipment
  * Tested with the Ubiquiti (*UBNT*) UniFi HD series and UniFi AC series only
* Ubiquiti (*UBNT*) UniFi Security Gateway (*USW*)
  * Tested with the Ubiquiti (*UBNT*) UniFi Security Gateway USG-PRO‐4 and UniFi Security Gateway USG-3P only
* Ubiquiti (*UBNT*) UniFi Switches (*USW*)
  * Tested with the Ubiquiti (*UBNT*) UniFi Switch 24 AT-250W and UniFi Switch 8 POE-150W only
* Ubiquiti (*UBNT*) UniFi [SDN Controller](https://unifi-sdn.ui.com/) in general
  * Tested with the Ubiquiti (*UBNT*) UniFi [SDN Controller](https://unifi-sdn.ui.com/) running on a Ubiquiti (*UBNT*) Cloud Key (Gen1) and UniFi [SDN Controller](https://unifi-sdn.ui.com/) running on Windows Server 2016.

Other Ubiquiti (*UBNT*), non UniFi SDN, equipment is not supported, because this module uses the UniFi [SDN Controller](https://unifi-sdn.ui.com/) API only.

---

### Use Cases

You will find some demo use cases within the [UseCases](https://github.com/Enatec/UniFiTooling/tree/master/release/UniFiTooling/UseCases) directory.

### Version

This document is based on UniFiTooling Module version 1.1.0 - Unreleased

### Status

Still a beta version - Work still in progress.

*Please remember this before using it in production. You have been warned :)*

### Requirements

* PowerShell 5.1, or later.
* Desktop and Core are both supported.
* Tested on:
  * *Windows 10, with PowerShell Desktop Version 5.1*
  * *Windows Server 2016, with PowerShell Desktop Version 5.1*
  * *Windows 10, with PowerShell Core Version 6.1.2*
  * *macOS 10.14.3, with PowerShell Core Version 6.1.2*
  * *CentOS Linux release 7.6, with PowerShell Core Version 6.1.2*
* Ubiquiti [UBNT SDN Controller](https://unifi-sdn.ui.com/), Version 5.10.10
  * *This is the only tested version*
  * *Other (older, or newer) Ubiquiti [UBNT SDN Controller](https://unifi-sdn.ui.com/) Versions might work*

#### Dependencies

UniFiTooling has no dependencies and it was designed to work on any operation system that runs PowerShell Desktop 5.1, or newer, or PowerShell Core Version 6.1, or newer.

### Installation

There are several ways to get, install, and use this module.

#### With PowerShellGet

Install the module with PowerShellGet directly from the Powershell Gallery, this is the recommended method!

[![Powershell Gallery](https://img.shields.io/powershellgallery/vpre/UniFiTooling.svg)](https://www.powershellgallery.com/packages/UniFiTooling/) [![Powershell Gallery](https://img.shields.io/powershellgallery/dt/UniFiTooling.svg)](https://www.powershellgallery.com/packages/UniFiTooling/)

##### Just for you

```powershell
# Install the module for the Current User
# with PowerShellGet directly from the Powershell Gallery, Preferred method
# Run in a regular or administrative PowerShell prompt (Elevated).
PS C:\> Install-Module -Name 'UniFiTooling' -Scope CurrentUser
```

##### Systemwide

```powershell
# Install the module for the All Users
# with PowerShellGet directly from the Powershell Gallery, Preferred method.
# Run this in an administrative PowerShell prompt (Elevated).
PS C:\> Install-Module -Name 'UniFiTooling' -Scope AllUsers
```

#### Manual Installation (unsupported)

```powershell
PS C:\> iex (New-Object Net.WebClient).DownloadString("https://github.com/Enatec/UniFiTooling/raw/master/Install.ps1")
```

#### Download from GitHub

You will find tha latest version in the [release page](https://github.com/Enatec/UniFiTooling/releases) of the [GitHub repository](https://github.com/Enatec/UniFiTooling/)

[![GitHub release](https://img.shields.io/github/release/enatec/UniFiTooling.svg)](https://github.com/Enatec/UniFiTooling/releases/) [![GitHub release](https://img.shields.io/github/downloads/enatec/UniFiTooling/total.svg)](https://github.com/Enatec/UniFiTooling/releases/) [![Download Size](https://badge-size.herokuapp.com/enatec/UniFiTooling/master/release/UniFiTooling-current.zip)](https://github.com/Enatec/UniFiTooling/blob/master/release/UniFiTooling-current.zip)

#### Clone the repository

Or clone this [GitHub repository](https://github.com/Enatec/UniFiTooling/) to your local machine, extract, go to the `.\releases\UniFiTooling` directory and import the module to your session to test, but not install this module.

### Get started

After installation of the Module, open a PowerShell Session (regular or elevated).

#### Config

```powershell
PS C:\> New-UniFiConfig -UniFiUsername 'user' -UniFiPassword 'password' -UniFiProtocol 'https' -UniFiSelfSignedCert $true -UniFiHostname 'unifi.contoso.com' -UniFiPort '8443' -Path '.\UniFiConfig.json'
```

Replace the values with your needs. Please also see the detailed description below.

#### Connect

Before using any command, you need to login to the controller.

```powershell
PS C:\> Invoke-UniFiApiLogin
```

In version 1.0.8, this will change: You no longer need to login/authenticate. All commands will do a check and login/authenticate when needed.

##### Troubleshooting

This will show you the real error-message:

```powershell
PS C:\> Invoke-UniFiApiLogin -verbose
```

#### Execute any command

Execute any command now...

```powershell
PS C:\> Get-UnifiNetworkList
```

#### Logoff

You should logoff after you are done! The session will timeout, but this will clean up everything for you.

```powershell
PS C:\> Invoke-UniFiApiLogout
```

### Feedback

Any Feedback is appreciated! Please open a [GitHub issue](https://github.com/Enatec/UniFiTooling/issues/new/choose) as *Bug report* if you find something not working.

[![GitHub issues](https://img.shields.io/github/issues/enatec/UniFiTooling.svg)](https://github.com/Enatec/UniFiTooling/issues/) [![GitHub issues-closed](https://img.shields.io/github/issues-closed/enatec/UniFiTooling.svg)](https://github.com/Enatec/UniFiTooling/issues?q=is%3Aissue+is%3Aclosed)

### Contribute

Anything missing? Please open a [GitHub issue](https://github.com/Enatec/UniFiTooling/issues/new/choose) as *Feature request*.
Suggest an idea for this Module will help to improve this module.

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) [![GitHub pull-requests](https://img.shields.io/github/issues-pr/enatec/UniFiTooling.svg)](https://github.com/Enatec/UniFiTooling/pull/) [![GitHub pull-requests closed](https://img.shields.io/github/issues-pr-closed/enatec/UniFiTooling.svg)](https://github.com/Enatec/UniFiTooling/pulls?q=is%3Apr+is%3Aclosed)

Please read our [Contribution Guide](https://github.com/Enatec/UniFiTooling/blob/master/CONTRIBUTING.md) and [Code of Conduct](https://github.com/Enatec/UniFiTooling/blob/master/CODE_OF_CONDUCT.md).

### Note

Still an early stage. This is not a finished product but it's generally working

### Config

Keep this file in a secure place, especially in a shared environment. It contains the credentials (Yes, username and password) of your UniFi Admin User in plain text (human readable).

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
This is a Bool, but only `true` or `false` for now. I use this directly in PowerShell.

Please note: I can be dangerous to trust a certificate without checking it! I think it is OK to do within an Intranet, but I would avoid doing it over the public Internet! Especially with the `Invoke-UniFiApiLogin` command, because this will send the Credentials (Yes, username and password) of your UniFi Admin User in clear text in a JSON based body. If this is intercepted you might be in danger!

#### Hostname

The Ubiquiti UniFi Controller you want to use. You can use a Fully-Qualified Host Name (FQHN) or an IP address. Please note that your certificate must match the name and/or IP address as SAN name. Otherwise you might need to set the `SelfSignedCert` to `true`.

#### Port

The port number that you have configured on your Ubiquiti UniFi Controller.

### Roadmap

We have an public [Roadmap](https://github.com/Enatec/UniFiTooling/wiki/ROADMAP) published.

### Authors

Joerg Hochwald - [http://hochwald.net](http://jhochwald.com)

### Contributors

N.N. (could be you)

### Copyright

Copyright (c) 2019, [enabling Technology](http://www.enatec.io)
All rights reserved.

### License

BSD 3-Clause "New" or "Revised" License.
Here is the the [online](https://github.com/Enatec/UniFiTooling/wiki/License) version of the License.

---

[![GitHub license](https://img.shields.io/github/license/enatec/UniFiTooling.svg)](https://github.com/Enatec/UniFiTooling/blob/master/LICENSE) [![made-with-Markdown](https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg)](http://commonmark.org) [![Open Source Love png1](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)
