function Set-UnifiClientDeviceNote
{
<#
	.SYNOPSIS
		Add/modify/remove a client-device note

	.DESCRIPTION
		Add/modify/remove a client-device note

	.PARAMETER UnifiSite
		A description of the UnifiSite parameter.

	.PARAMETER Client
		ID of the client-device to be modified

	.PARAMETER Note
		Note to be applied to the client-device (optional)

	.EXAMPLE
		PS C:\> Set-UnifiClientDeviceNote -Client 'Value1'

	.NOTES
		Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Invoke-UniFiApiLogin

         .LINK
         Invoke-RestMethod
#>

	[CmdletBinding(ConfirmImpact = 'Low',
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
				   HelpMessage = 'ID of the client-device to be modified')]
		[ValidateNotNullOrEmpty()]
		[Alias('UniFiClient', 'UniFiUser', 'UniFiID')]
		[string]
		$Client,
		[Parameter(ValueFromPipeline,
				   ValueFromPipelineByPropertyName,
				   Position = 2)]
		[Alias('UniFiNote', 'UniFiClientNote', 'UniFiUserNote')]
		[string]
		$Note = $null
	)

	begin
	{

	}

	process
	{
		if ($pscmdlet.ShouldProcess("client-device", "Add/modify/remove"))
		{
			#TODO: Place script here
		}
	}

	end
	{

	}
}
