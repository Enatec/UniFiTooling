function Get-UnifiHourlyApStats
{
   <#
         .SYNOPSIS
         Hourly stats method for a single access point or all access points

         .DESCRIPTION
         Hourly stats method for a single access point or all access points

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-UnifiHourlyApStats

         .NOTES
         UniFi controller does not keep these stats longer than 5 hours with versions < 4.6.6
         defaults to the past 7*24 hours
         TODO: Add missing MAC Parameter

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
