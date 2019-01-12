function Set-UnifiNetworkDetails
{
   <#
         .SYNOPSIS
         Modifies one network via the API of the UniFi Controller
	
         .DESCRIPTION
         Modifies one network via the API of the UniFi Controller
	
         .PARAMETER UnifiNetwork
         The ID (network_id) of the network you would like to get detaild information about.

         .PARAMETER UniFiBody
         JSON formed Body for the Request
	
         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default
	
         .EXAMPLE
         PS C:\> Set-UnifiNetworkDetails -UnifiNetwork $value1

         Get the details about one network via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Set-UnifiNetworkDetails -UnifiNetwork $value1 -UnifiSite 'Contoso'

         Get the details about one network on Site 'Contoso' via the API of the UniFi Controller
	
         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Set-UniFiDefaultRequestHeader
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'The ID (network_id) of the network you would like to get detaild information about.')]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiNetworkId', 'NetworkId')]
      [string]
      $UnifiNetwork,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 2,
      HelpMessage = 'JSON formed Body for the Request')]
      [ValidateNotNullOrEmpty()]
      [Alias('Body')]
      [string]
      $UniFiBody,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
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
			
         Write-Verbose -Message 'Create the Request URI'
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/networkconf/' + $UnifiNetwork
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
			
         Write-Verbose -Message 'Send the Request'
         $paramInvokeRestMethod = @{
            Method        = 'Put'
            Uri           = $ApiRequestUri
            Body          = $UniFiBody
            Headers       = $RestHeader
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
            WebSession    = $RestSession
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)
         Write-Verbose -Message ('Session Info: {0}' -f $Session)
      }
      catch
      {
         # Try to Logout
         $null = (Invoke-UniFiApiLogout)
			
         # Remove the Body variable
         $JsonBody = $null
			
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $_)
			
         # Error Message
         Write-Error -Message 'Unable to modify given network' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
      finally
      {
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
      }
		
      # check result
      if ($Session.meta.rc -ne 'ok')
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $Session.meta.rc)
			
         # Error Message
         Write-Error -Message 'Unable to Login' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
   }
	
   end
   {
      # Dump the Result
      $Session.data
		
      # Cleanup
      $Session = $null
      
      # Restore ProgressPreference
      $ProgressPreference = $ExistingProgressPreference
   }
}
