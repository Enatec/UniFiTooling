function Set-UnifiClientDeviceName
{
   <#
         .SYNOPSIS
         Add/modify/remove a client device name

         .DESCRIPTION
         Add/modify/remove a client device name

         .PARAMETER Site
         UniFi Site as configured. The default is: default

         .PARAMETER Client
         ID of the client device to be modified

         .PARAMETER Name
         Name to be applied to the client device

         .EXAMPLE
         PS C:\> Set-UnifiClientDeviceName -Client 'Value1'

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
      [Alias('UniFiName', 'UniFiClientName', 'UniFiUserName')]
      [string]
      $Name
   )

   begin
   {
		Write-Verbose -Message 'begin'
   }

   process
   {
      if ($pscmdlet.ShouldProcess('client-device', 'Add/modify/remove'))
      {
         Write-Verbose -Message 'process'
      }
   }

   end
   {
		Write-Verbose -Message 'end'
   }
}
