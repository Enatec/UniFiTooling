function Invoke-UniFiApiLogin
{
   <#
         .SYNOPSIS
         Login to API of the UniFi Controller
	
         .DESCRIPTION
         Login to API of the Ubiquiti UniFi Controller
	
         .EXAMPLE
         PS C:\> Invoke-UniFiApiLogin

         Login to API of the Ubiquiti UniFi Controller
	
         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Get-UniFiCredentials

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Invoke-UniFiApiLogout
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param ()
	
   begin
   {
      # Cleanup
      $RestSession = $null
      $Session = $null
      
      # Safe ProgressPreference and Setup SilentlyContinue for the function
      $ExistingProgressPreference = ($ProgressPreference)
      $ProgressPreference = 'SilentlyContinue'
   }
	
   process
   {
      # Login
      try
      {
         # 
         Write-Verbose -Message 'Read the Config'
         $null = (Get-UniFiConfig)

         Write-Verbose -Message ('Certificate check - Should be {0}' -f $ApiSelfSignedCert)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = {
            $ApiSelfSignedCert
         }
			
         Write-Verbose -Message 'Set the API Call default Header'
         $null = (Set-UniFiDefaultRequestHeader)

         Write-Verbose -Message 'Read the Credentials'
         $null = (Get-UniFiCredentials)
			
         Write-Verbose -Message 'Create the Body'
         $null = (Set-UniFiApiLoginBody)

         Write-Verbose -Message 'Cleanup the credentials variables'
         $ApiUsername = $null
         $ApiPassword = $null
			
         # Cleanup
         $Session = $null
			
         Write-Verbose -Message 'Create the Request URI'
         $ApiRequestUri = $ApiUri + 'login'
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)

         Write-Verbose -Message 'Send the Request to Login'
         $paramInvokeRestMethod = @{
            Method          = 'Post'
            Uri             = $ApiRequestUri
            Headers         = $RestHeader
            Body            = $JsonBody
            ErrorAction     = 'SilentlyContinue'
            WarningAction   = 'SilentlyContinue'
            SessionVariable = 'RestSession'
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)
         Write-Verbose -Message ('Session Info: {0}' -f $Session)

         $Global:RestSession = $RestSession

         # Remove the Body variable
         $JsonBody = $null
      }
      catch
      {
         # Remove the Body variable
         $JsonBody = $null
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $_)
			
         # Error Message
         Write-Error -Message 'Unable to Login' -ErrorAction Stop
			
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
      # Cleanup
      $Session = $null
      
      # Restore ProgressPreference
      $ProgressPreference = $ExistingProgressPreference
   }
}
