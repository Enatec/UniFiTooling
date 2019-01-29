function Set-UniFiClientIpAddress
{
<#
	.SYNOPSIS
		Update client fixedip

	.DESCRIPTION
		Update client fixedip

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Client
		id of the user device to be modified

	.PARAMETER UseFixedIp
		boolean defining whether if use_fixedip is true or false

	.PARAMETER Network
		network id where the ip belongs to

	.PARAMETER FixedIp
		value of client fixed_ip field

	.EXAMPLE
		PS C:\> Set-UniFiClientGroup

	.NOTES
		TBD

	.LINK
		Get-UniFiConfig

	.LINK
		Set-UniFiDefaultRequestHeader

	.LINK
		Invoke-UniFiApiLogin

	.LINK
		Invoke-RestMethod
#>

	[CmdletBinding(ConfirmImpact = 'None',
				   SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 0)]
		[ValidateNotNullOrEmpty()]
		[Alias('Site')]
		[string]
		$UnifiSite = 'default',
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 1,
				   HelpMessage = 'id of the user device to be modified')]
		[ValidateNotNullOrEmpty()]
		[Alias('ClientID', 'UniFiClient')]
		[string]
		$Client,
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 2)]
		[Alias('UniFiUseFixedIp')]
		[switch]
		$UseFixedIp = $false,
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 3)]
		[Alias('UniFiNetwork')]
		[string]
		$Network,
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 4)]
		[Alias('UniFiFixedIp')]
		[ipaddress]
		$FixedIp
	)

	begin
	{
		Write-Verbose -Message 'begin'
	}

	process
	{
		if ($pscmdlet.ShouldProcess('client-device', 'Move to Group_ID'))
		{
			Write-Verbose -Message 'process'
		}
	}

	end
	{
		Write-Verbose -Message 'end'
	}
}
