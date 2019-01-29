---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Get-UnifiClientDetails.md
schema: 2.0.0
---

# Get-UnifiClientDetails

## SYNOPSIS
Method to fetch speed test results

## SYNTAX

```
Get-UnifiClientDetails [[-UnifiSite] <String>] [[-Start] <String>] [[-End] <String>] [<CommonParameters>]
```

## DESCRIPTION
Method to fetch speed test results

## EXAMPLES

### EXAMPLE 1
```
Get-UnifiClientDetails
```

## PARAMETERS

### -UnifiSite
ID of the client-device to be modified

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

### -Start
Startpoint in UniFi Unix timestamp in milliseconds

```yaml
Type: String
Parameter Sets: (All)
Aliases: Startpoint, StartTime

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -End
Endpoint in UniFi Unix timestamp in milliseconds

```yaml
Type: String
Parameter Sets: (All)
Aliases: EndPoint, EndTime

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
TODO: Remove Start
TODO: Remove End
TODO: Add client_mac client device MAC address

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

