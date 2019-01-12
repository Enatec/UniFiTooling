function Invoke-UniFiApiLogout
{
   <#
         .SYNOPSIS
         Logout from the API of the UniFi Controller
	
         .DESCRIPTION
         Logout from the API of the Ubiquiti UniFi Controller
	
         .EXAMPLE
         
         PS C:\> Invoke-UniFiApiLogout

         Logout from the API of the Ubiquiti UniFi Controller
	
         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Invoke-UniFiApiLogin
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param ()
	
   begin
   {
      # Cleanup
      $Session = $null
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
         $ApiRequestUri = $ApiUri + 'logout'
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)

         Write-Verbose -Message 'Send the Request to Login'
         $paramInvokeRestMethod = @{
            Method        = 'Post'
            Uri           = $ApiRequestUri
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
            WebSession    = $RestSession
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)
         Write-Verbose -Message ('Session Info: {0}' -f $Session)
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
         Write-Error -Message 'Unable to Logout' -ErrorAction Stop
			
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
      $RestSession = $null
   }
}
