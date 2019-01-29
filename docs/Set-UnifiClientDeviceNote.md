---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Set-UnifiClientDeviceNote.md
schema: 2.0.0
---

# Set-UnifiClientDeviceNote

## SYNOPSIS
Add/modify/remove a client-device note

## SYNTAX

```
Set-UnifiClientDeviceNote [[-UnifiSite] <String>] [-Client] <String> [[-Note] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Add/modify/remove a client-device note

## EXAMPLES

### EXAMPLE 1
```
Set-UnifiClientDeviceNote -Client 'Value1'
```

## PARAMETERS

### -UnifiSite
A description of the UnifiSite parameter.

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
ID of the client-device to be modified

```yaml
Type: String
Parameter Sets: (All)
Aliases: UniFiClient, UniFiUser, UniFiID

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Note
Note to be applied to the client-device (optional)

```yaml
Type: String
Parameter Sets: (All)
Aliases: UniFiNote, UniFiClientNote, UniFiUserNote

Required: False
Position: 3
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
Initial version of the Ubiquiti UniFi Controller automation function

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

