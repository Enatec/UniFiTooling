﻿function Get-UniFiIsAlive
{
   <#
         .SYNOPSIS
         Use a simple API call to see if the session is alive

         .DESCRIPTION
         Use a simple API call to see if the session is alive

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .EXAMPLE
         PS C:\> Get-UniFiIsAlive

         Use a simple API call to see if the session is alive

         .EXAMPLE
         PS C:\> Get-UniFiIsAlive -UnifiSite 'Contoso'

         Use a simple API call to see if the session is alive on Site 'Contoso'

         .NOTES
         Internal Helper Function

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
   [OutputType([bool])]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
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

      # Set the default to FALSE
      $SessionStatus = $false
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

         $null = (Invoke-UniFiApiLogin -ErrorAction SilentlyContinue)

         Write-Verbose -Message 'Set the API Call default Header'

         $null = (Set-UniFiDefaultRequestHeader)

         Write-Verbose -Message 'Create the Request URI'

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/self'

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

         $SessionStatus = $true
      }
      catch
      {
         # Try to Logout
         try
         {
            $null = (Invoke-UniFiApiLogout -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
         }
         catch
         {
            # We don't care about that
            Write-Verbose -Message 'Logout failed'
         }

         # Restore ProgressPreference
         $ProgressPreference = $ExistingProgressPreference

         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null

         # That was it!
         $SessionStatus = $false
      }

      # check result
      if ($Session.meta.rc -ne 'ok')
      {
         # Restore ProgressPreference
         $ProgressPreference = $ExistingProgressPreference

         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null

         # That was it!
         $SessionStatus = $false
      } else {
         $SessionStatus = $true
      }
   }

   end
   {
      # Cleanup
      $Session = $null

      # Restore ProgressPreference
      $ProgressPreference = $ExistingProgressPreference

      # Reset the SSL Trust (make sure everything is back to default)
      [Net.ServicePointManager]::ServerCertificateValidationCallback = $null

      # Dump the Result
      Return $SessionStatus
   }
}
