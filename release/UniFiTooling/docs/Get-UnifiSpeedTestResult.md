---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/jhochwald/UniFiTooling/raw/master/docs/Get-UnifiSpeedTestResult.md
schema: 2.0.0
---

# Get-UnifiSpeedTestResult

## SYNOPSIS
Get the UniFi Security Gateway (USG) Speedtest results

## SYNTAX

```
Get-UnifiSpeedTestResult [[-UnifiSite] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get the UniFi Security Gateway (USG) Speedtest results

## EXAMPLES

### EXAMPLE 1
```
Get-UnifiSpeedTestResult
```

Get the UniFi Security Gateway (USG) Speedtest results

### EXAMPLE 2
```
Get-UnifiSpeedTestResult | Select-Object -Property *
```

Get the UniFi Security Gateway (USG) Speedtest results, returns all values

### EXAMPLE 3
```
Get-UnifiSpeedTestResult -UnifiSite 'Contoso'
```

Get the UniFi Security Gateway (USG) Speedtest results

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Initial version that makes it more human readable

TODO: Select Time
TODO: Filtering

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

