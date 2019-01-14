function Get-UnifiNetworkDetails
{
   <#
         .SYNOPSIS
         Get the details about one network via the API of the UniFi Controller

         .DESCRIPTION
         Get the details about one network via the API of the UniFi Controller

         .PARAMETER Id
         The ID (network_id) of the network you would like to get detaild information about. Multiple values are supported.

         .PARAMETER Name
         The Name (not the ID/network_id) of the network you would like to get detaild information about. Multiple values are supported.

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -id 'ba7e58be13574ef4881a79c3'

         Get the details about the network with ID ba7e58be13574ef4881a79c3 via the API of the UniFi Controller

         .EXAMPLE
         Get-UnifiNetworkDetails -UnifiNetwork 'ba7e58be13574ef4881a79c3'

         Same as above, with the legacy parameter alias used.

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -name 'JoshHome'

         Get the details about the network JoshHome via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -name 'JoshHome', 'JohnHome'

         Get the details about the networks JoshHome and JohnHome via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -id 'ba7e58be13574ef4881a79c3', '2437bdf7fdf04f1a96c0fd32'

         Get the details about the networks with IDs ba7e58be13574ef4881a79c3 and 2437bdf7fdf04f1a96c0fd32 via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -id 'ba7e58be13574ef4881a79c3' -UnifiSite 'Contoso'

         Get the details about the network with ID ba7e58be13574ef4881a79c3 on Site 'Contoso' via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -name 'JoshHome' -UnifiSite 'Contoso'

         Get the details about the network JoshHome on Site 'Contoso' via the API of the UniFi Controller

         .NOTES
         The parameter UnifiNetwork is now an Alias.
         If the UnifiNetwork parameter is used, it must(!) be the ID (network_id). This was necessary to make it a non breaking change.

         .LINK
         Get-UniFiConfig

         .LINK
         Get-UnifiNetworkList

         .LINK
         Set-UniFiDefaultRequestHeader
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ParameterSetName = 'Request by Id',Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'The ID (network_id) of the network you would like to get detaild information about.')]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiNetwork', 'UnifiNetworkId', 'NetworkId')]
      [string[]]
      $Id,
      [Parameter(ParameterSetName = 'Request by Name', Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'The Name (not the ID/network_id) of the network you would like to get detaild information about.')]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiNetworkName', 'NetworkName')]
      [string[]]
      $Name,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default'
   )

   begin
   {
      # Cleanup
      $Session = $null

      # Safe ProgressPreference and Setup SilentlyContinue for the function
      $ExistingProgressPreference = ($ProgressPreference)
      $ProgressPreference = 'SilentlyContinue'

      # Create a new Object
      $SessionData = @()
   }

   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config'
         $null = (Get-UniFiConfig)

         Write-Verbose -Message ('Certificate check - Should be {0}' -f $ApiSelfSignedCert)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = {
            $ApiSelfSignedCert
         }

         Write-Verbose -Message 'Set the API Call default Header'
         $null = (Set-UniFiDefaultRequestHeader)

         switch ($PsCmdlet.ParameterSetName)
         {
            'ByName'
            {
               foreach ($SingleName in $Name)
               {
                  # Cleanup
                  $Session = $null

                  Write-Verbose -Message 'Create the Request URI'

                  $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/networkconf/'

                  Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)

                  Write-Verbose -Message 'Send the Request'

                  $paramInvokeRestMethod = @{
                     Method        = 'Get'
                     Uri           = $ApiRequestUri
                     Headers       = $RestHeader
                     ErrorAction   = 'SilentlyContinue'
                     WarningAction = 'SilentlyContinue'
                     WebSession    = $RestSession
                  }
                  $Session = (Invoke-RestMethod @paramInvokeRestMethod)

                  Write-Verbose -Message ('Session Info: {0}' -f $Session)

                  # check result
                  if ($Session.meta.rc -ne 'ok')
                  {
                     # Error Message
                     Write-Error -Message 'Unable to Login' -ErrorAction Stop

                     # Only here to catch a global ErrorAction overwrite
                     break
                  }
                  elseif (-not ($Session.data))
                  {
                     # Error Message for a possible Not found
                     Write-Error -Message 'No Data - Possible Reason: Not found' -Category ObjectNotFound -ErrorAction Stop

                     # Only here to catch a global ErrorAction overwrite
                     break
                  }
                  $Session = $Session.data | Where-Object {
                     $_.name -eq $SingleName
                  }
                  $SessionData = $SessionData + $Session
               }
            }
            'ById'
            {
               foreach ($SingleId in $Id)
               {
                  # Cleanup
                  $Session = $null

                  Write-Verbose -Message 'Create the Request URI'

                  $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/networkconf/' + $SingleId

                  Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)

                  Write-Verbose -Message 'Send the Request'

                  $paramInvokeRestMethod = @{
                     Method        = 'Get'
                     Uri           = $ApiRequestUri
                     Headers       = $RestHeader
                     ErrorAction   = 'SilentlyContinue'
                     WarningAction = 'SilentlyContinue'
                     WebSession    = $RestSession
                  }
                  $Session = (Invoke-RestMethod @paramInvokeRestMethod)

                  Write-Verbose -Message ('Session Info: {0}' -f $Session)

                  # check result
                  if ($Session.meta.rc -ne 'ok')
                  {
                     # Error Message
                     Write-Error -Message 'Unable to Login' -ErrorAction Stop

                     # Only here to catch a global ErrorAction overwrite
                     break
                  }
                  elseif (-not ($Session.data))
                  {
                     # Error Message for a possible Not found
                     Write-Error -Message 'No Data - Possible Reason: Not found' -Category ObjectNotFound -ErrorAction Stop

                     # Only here to catch a global ErrorAction overwrite
                     break
                  }
                  $SessionData = $SessionData + $Session.data
               }
            }
         }
      }
      catch
      {
         # Try to Logout
         $null = (Invoke-UniFiApiLogout)

         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $_)

         # Error Message
         Write-Error -Message 'Unable to get the network details' -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }
      finally
      {
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
      }
   }

   end
   {
      # Dump the Result
      $SessionData

      # Cleanup
      $SessionData = $null

      # Restore ProgressPreference
      $ProgressPreference = $ExistingProgressPreference
   }
}
#get-help Get-UnifiNetworkDetails -Detailed
