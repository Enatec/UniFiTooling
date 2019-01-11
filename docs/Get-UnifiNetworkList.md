﻿---
author: Joerg Hochwald
category: UNIFITOOLING
external help file: UniFiTooling-help.xml
layout: post
Module Name: UniFiTooling
online version: https://github.com/jhochwald/UniFiTooling/UniFiTooling/docs/Get-UnifiNetworkList.md
schema: 2.0.0
tags: OnlineHelp PowerShell
timestamp: 2019-01-11
title: Get-UnifiNetworkList
---

# Get-UnifiNetworkList

## SYNOPSIS
Get a List Networks via the API of the UniFi Controller

## SYNTAX

```
Get-UnifiNetworkList [[-UnifiSite] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get a List Networks via the API of the Ubiquiti UniFi Controller

## EXAMPLES

### EXAMPLE 1
```
Get-UnifiNetworkList
```

Get a List Networks via the API of the UniFi Controller

### EXAMPLE 2
```
Get-UnifiNetworkList -UnifiSite 'Contoso'
```

Get a List Networks on Site 'Contoso' via the API of the UniFi Controller

## PARAMETERS

### -UnifiSite
UniFi Site as configured.
The default is: default

```yaml
Type: String
Parameter Sets: (All)
Aliases: Site

Required: False
Position: 2
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

