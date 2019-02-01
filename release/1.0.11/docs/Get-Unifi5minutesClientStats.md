---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Get-Unifi5minutesClientStats.md
schema: 2.0.0
---

# Get-Unifi5minutesClientStats

## SYNOPSIS
Get user/client statistics in 5 minute segments

## SYNTAX

```
Get-Unifi5minutesClientStats [[-UnifiSite] <String>] [-Mac] <String> [[-Start] <String>] [[-End] <String>]
 [[-Attributes] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Get user/client statistics in 5 minute segments for a given client
For convenience, we return the TX/RX traffic in bytes (as the UniFi does it) and Megabytes.
We return a summed traffic (based on the combined TX and RX traffic) in Megabytes.
We also return real timestamps instead of the unix timestaps that the UniFi returns

## EXAMPLES

### EXAMPLE 1
```
Get-Unifi5minutesClientStats -Mac '78:8a:20:59:e6:88'
```

Get user/client statistics in 5 minute segments for a given (78:8a:20:59:e6:88) user/client in the default site

### EXAMPLE 2
```
(Get-Unifi5minutesClientStats -Mac '78:8a:20:59:e6:88' -Start '1548971935421' -End '1548975579019')
```

Get user/client statistics in 5 minute segments for a given (78:8a:20:59:e6:88) user/client in the default site for a given time period.

### EXAMPLE 3
```
(Get-Unifi5minutesClientStats -Mac '78:8a:20:59:e6:88' -Start '1548980058135')
```

Get user/client statistics in 5 minute segments for a given (78:8a:20:59:e6:88) user/client in the default site for the last 60 minutes (was the timestamp while the sample was created)

### EXAMPLE 4
```
(Get-Unifi5minutesClientStats -Mac '78:8a:20:59:e6:88' -UnifiSite 'contoso')[-1]
```

Get user/client statistics in 5 minute segments for a given (78:8a:20:59:e6:88) user/client in the site 'contoso'

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

### -Mac
Client MAC address (required)

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

### -Start
Startpoint in UniFi Unix timestamp in milliseconds

```yaml
Type: String
Parameter Sets: (All)
Aliases: Startpoint, StartTime

Required: False
Position: 3
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
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Attributes
array containing attributes (strings) to be returned, defaults to rx_bytes and tx_bytes

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: attribs, UniFiAttributes

Required: False
Position: 5
Default value: None
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
Defaults to the past 12 hours.
Make sure that the retention policy for 5 minutes stats is set to the correct value in the controller settings
Ubiquiti announced this with the Controller version 5.8 - It will not work on older versions!
Make sure that "Clients Historical Data" (Collect clients' historical data) has been enabled in the UniFi controller in "Settings/Maintenance"

Sample Output:
rx_bytes : 18384.0
rx_mb    : 0.02
tx_bytes : 30438.559999999998
tx_mb    : 0.03
Traffic  : 0.05
time     : 2/1/2019 1:15:00 AM

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

[ConvertFrom-UnixTimeStamp]()

[ConvertTo-UnixTimeStamp]()

