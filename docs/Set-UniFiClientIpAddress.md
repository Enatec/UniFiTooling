---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Set-UniFiClientIpAddress.md
schema: 2.0.0
---

# Set-UniFiClientIpAddress

## SYNOPSIS
Update client fixedip

## SYNTAX

```
Set-UniFiClientIpAddress [[-UnifiSite] <String>] [-Client] <String> [-UseFixedIp] [[-Network] <String>]
 [[-FixedIp] <IPAddress>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Update client fixedip

## EXAMPLES

### EXAMPLE 1
```
Set-UniFiClientGroup
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

### -Client
id of the user device to be modified

```yaml
Type: String
Parameter Sets: (All)
Aliases: ClientID, UniFiClient

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UseFixedIp
boolean defining whether if use_fixedip is true or false

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: UniFiUseFixedIp

Required: False
Position: 3
Default value: False
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Network
network id where the ip belongs to

```yaml
Type: String
Parameter Sets: (All)
Aliases: UniFiNetwork

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -FixedIp
value of client fixed_ip field

```yaml
Type: IPAddress
Parameter Sets: (All)
Aliases: UniFiFixedIp

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
TBD

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

