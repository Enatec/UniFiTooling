function Invoke-UniFiCidrWorkaroundV6
{
   <#
         .SYNOPSIS
         IPv6 CIDR Workaround for UBNT USG Firewall Rules
	
         .DESCRIPTION
         IPv6 CIDR Workaround for UBNT USG Firewall Rules (Single IPv6 has to be without /128)
	
         .PARAMETER CidrList
         Existing CIDR List Object
	
         .EXAMPLE
         PS C:\> Invoke-UniFiCidrWorkaroundV6 -CidrList $value1

         IPv6 CIDR Workaround for UBNT USG Firewall Rules

         .EXAMPLE
         PS C:\> $value1 | Invoke-UniFiCidrWorkaroundV6

         IPv6 CIDR Workaround for UBNT USG Firewall Rules via Pipeline
	
         .NOTES
         This is an internal helper function only

         .LINK
         Invoke-UniFiCidrWorkaround
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Existing CIDR List Object')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiCidrList')]
      [psobject]
      $CidrList
   )
	
   begin
   {
      # Cleanup
      $AddItem = @()
   }
	
   process
   {
      # Loop over the new list
      foreach ($NewInputItem in $CidrList)
      {
         # CIDR Workaround for UBNT USG Firewall Rules (Single IPv6 has to be without /128)
         if ($NewInputItem -match '/128')
         {
            $NewInputItem = $NewInputItem.Replace('/128', '')
         }
         # Add to the List
         $AddItem = $AddItem + $NewInputItem
      }
   }
	
   end
   {
      # Dump
      $AddItem

      # Cleanup
      $AddItem = $null
   }
}
