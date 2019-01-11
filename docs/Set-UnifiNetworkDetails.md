﻿---
author: Joerg Hochwald
category: UNIFITOOLING
external help file: UniFiTooling-help.xml
layout: post
Module Name: UniFiTooling
online version: https://github.com/jhochwald/UniFiTooling/docs/Set-UnifiNetworkDetails.md
schema: 2.0.0
tags: OnlineHelp PowerShell
timestamp: 2019-01-11
title: Set-UnifiNetworkDetails
---

# Set-UnifiNetworkDetails

## SYNOPSIS
Modifies one network via the API of the UniFi Controller

## SYNTAX

```
Set-UnifiNetworkDetails [-UnifiNetwork] <String> [-UniFiBody] <String> [[-UnifiSite] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Modifies one network via the API of the UniFi Controller

## EXAMPLES

### EXAMPLE 1
```
Set-UnifiNetworkDetails -UnifiNetwork $value1
```

Get the details about one network via the API of the UniFi Controller

### EXAMPLE 2
```
Set-UnifiNetworkDetails -UnifiNetwork $value1 -UnifiSite 'Contoso'
```

Get the details about one network on Site 'Contoso' via the API of the UniFi Controller

## PARAMETERS

### -UnifiNetwork
The ID (network_id) of the network you would like to get detaild information about.

```yaml
Type: String
Parameter Sets: (All)
Aliases: UnifiNetworkId, NetworkId

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UniFiBody
JSON formed Body for the Request

```yaml
Type: String
Parameter Sets: (All)
Aliases: Body

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UnifiSite
UniFi Site as configured.
The default is: default

```yaml
Type: String
Parameter Sets: (All)
Aliases: Site

Required: False
Position: 4
Default value: Default
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Initial version of the Ubiquiti UniFi Controller automation function

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Set-UniFiDefaultRequestHeader]()

