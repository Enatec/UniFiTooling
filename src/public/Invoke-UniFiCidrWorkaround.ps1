function Invoke-UniFiCidrWorkaround
{
   <#
         .SYNOPSIS
         IPv4 CIDR Workaround for UBNT USG Firewall Rules
	
         .DESCRIPTION
         IPv4 CIDR Workaround for UBNT USG Firewall Rules (Single IPv4 has to be without /32)
	
         .PARAMETER CidrList
         Existing CIDR List Object
	
         .EXAMPLE
         PS C:\> Invoke-UniFiCidrWorkaround -CidrList $value1

         IPv4 CIDR Workaround for UBNT USG Firewall Rules

         .EXAMPLE
         PS C:\> $value1 | Invoke-UniFiCidrWorkaround

         IPv4 CIDR Workaround for UBNT USG Firewall Rules via Pipeline
	
         .NOTES
         This is an internal helper function only

         .LINK
         Invoke-UniFiCidrWorkaroundV6
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
         # CIDR Workaround for UBNT USG Firewall Rules (Single IP has to be without /32)
         if ($NewInputItem -match '/32')
         {
            $NewInputItem = $NewInputItem.Replace('/32', '')
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