---
external help file: UniFiTooling-help.xml
HelpVersion: 1.1.0
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Invoke-UnifiUnblockClient.md
schema: 2.0.0
---

# Invoke-UnifiUnblockClient

## SYNOPSIS
It unblocks a given user/client via API on the UniFi SDN Controller.

## SYNTAX

```
Invoke-UnifiUnblockClient [[-UnifiSite] <String>] [-Mac] <String> [<CommonParameters>]
```

## DESCRIPTION
It unblocks a given user/client via Ubiquiti (UBNT) UniFi RESTful API request on the UniFi SDN Controller.

## EXAMPLES

### EXAMPLE 1
```
Invoke-UnifiUnblockClient -Mac '84:3a:4b:cd:88:2D'
```

Unblock a client device via the API of the UniFi Controller

### EXAMPLE 2
```
Invoke-UnifiUnblockClient -Mac '84:3a:4b:cd:88:2D' -UnifiSite 'Contoso'
```

Unblock a client device on Site 'Contoso' via the API of the UniFi Controller

## PARAMETERS

### -UnifiSite
UniFi Site as configured.
The default is: default

```yaml
Type: String
Parameter Sets: (All)
Aliases: Site

Required: False
Position: 1
Default value: Default
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Mac
Client MAC address

```yaml
Type: String
Parameter Sets: (All)
Aliases: UniFiMac, MacAddress

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
## NOTES
Initial version of the Ubiquiti UniFi Controller automation function

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

