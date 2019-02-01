function Set-UniFiClientGroup
{
<#
	.SYNOPSIS
		Assign client device to another group

	.DESCRIPTION
		Assign client device to another group

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Client
		id of the user device to be modified

	.PARAMETER Group
		id of the user group to assign user to

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
				   SupportsShouldProcess)]
	param
	(
		[Parameter(ValueFromPipeline,
				   ValueFromPipelineByPropertyName,
				   Position = 0)]
		[ValidateNotNullOrEmpty()]
		[Alias('Site')]
		[string]
		$UnifiSite = 'default',
		[Parameter(Mandatory,
				   ValueFromPipeline,
				   ValueFromPipelineByPropertyName,
				   Position = 1,
				   HelpMessage = 'id of the user device to be modified')]
		[ValidateNotNullOrEmpty()]
		[Alias('ClientID', 'UniFiClient')]
		[string]
		$Client,
		[Parameter(Mandatory,
				   ValueFromPipeline,
				   ValueFromPipelineByPropertyName,
				   Position = 2,
				   HelpMessage = 'id of the user group to assign user to')]
		[ValidateNotNullOrEmpty()]
		[Alias('GroupId', 'UniFiGroup')]
		[string]
		$Group
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
