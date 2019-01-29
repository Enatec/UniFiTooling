function Get-UnifiIdsIpsEvents
{
<#
	.SYNOPSIS
		Method to fetch speed test results

	.DESCRIPTION
		Method to fetch speed test results

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Start
		Startpoint in UniFi Unix timestamp in milliseconds

	.PARAMETER End
		Endpoint in UniFi Unix timestamp in milliseconds

	.EXAMPLE
		PS C:\> Get-UnifiIdsIpsEvents

	.NOTES
		TODO: Add missing optinal limit Parameter (defaults to 10000)

	.LINK
		Get-UniFiConfig

	.LINK
		Set-UniFiDefaultRequestHeader

	.LINK
		Invoke-UniFiApiLogin

	.LINK
		Invoke-RestMethod
#>

	[CmdletBinding(ConfirmImpact = 'None')]
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
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 1)]
		[Alias('Startpoint', 'StartTime')]
		[String]
		$Start,
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 2)]
		[Alias('EndPoint', 'EndTime')]
		[string]
		$End
	)

	begin
	{
		Write-Verbose -Message 'begin'
	}

	process
	{
		Write-Verbose -Message 'process'
	}

	end
	{
		Write-Verbose -Message 'end'
	}
}
