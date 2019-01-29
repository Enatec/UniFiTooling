function Get-Unifi5minutesSiteStats
{
   <#
         .SYNOPSIS
         5 minutes site stats method, defaults to the past 12 hours

         .DESCRIPTION
         5 minutes site stats method, defaults to the past 12 hours

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-Unifi5minutesSiteStats

         .NOTES
         Defaults to the past 12 hours.
         Make sure that the retention policy for 5 minutes stats is set to the correct value in the controller settings

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
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [Alias('Startpoint', 'StartTime')]
      [String]
      $Start,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
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
