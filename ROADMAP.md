# Roadmap

This is our release planning document. Everything is subject to change anytime.

## 1.1.0 - Maintenance (started)

No new features are being worked on for 1.1.0

Mainly a release that will contain a few more generic Pester tests.
We have a lot of tests that we use internal, but there is to much stuff hard coded (e.g. Credentials, Host names...).

We want to update a few things within the documentation and refactor a bit of the legacy code.

## 1.2.0 - New Features (plan)

### Think about it

`Get-UniFiSiteByName` - Use the Site name instead of the ID

### Work in progress

`Get-UnifiAllConnectedClients` - Get all connected Clients
`Get-UnifiAllGuests` - Get all connected Guests
`Get-UnifiAuthorizations`
`Get-UnifiClientDetails`
`Get-UnifiClientLogins`
`Get-UnifiLoginSessions`
`Set-UnifiClientDeviceName` - Add/change/remove a client device name
`Set-UnifiClientDeviceNote` - Add/change/remove a client-device note
`Set-UniFiClientGroup` - Assign client device to another group
`Set-UniFiClientIpAddress` - Update client fixed ip

## Other planned features

The following features are planned but not part of a release planning yet!

### More Use Cases

We would like to add more generic use cases.

### IDS/IPS support

`Get-UnifiIdsIpsEvents`

## Your request

Open a [issue on GitHub](https://github.com/Enatec/UniFiTooling/issues/new/choose) and select [Feature request](https://github.com/Enatec/UniFiTooling/issues/new?assignees=&labels=&template=feature_request.md&title=)!

Describe your request and we might put it on the Roadmap.
