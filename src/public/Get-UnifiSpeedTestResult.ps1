function Get-UnifiSpeedTestResult
{
   <#
         .SYNOPSIS
         Get the UniFi Security Gateway (USG) Speedtest results

         .DESCRIPTION
         Get the UniFi Security Gateway (USG) Speedtest results

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult

         Get the UniFi Security Gateway (USG) Speedtest results

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult | Select-Object -Property *

         Get the UniFi Security Gateway (USG) Speedtest results, returns all values

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -UnifiSite 'Contoso'

         Get the UniFi Security Gateway (USG) Speedtest results

         .NOTES
         Initial version that makes it more human readable

         TODO: Select Time
         TODO: Filtering

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
   [OutputType([psobject])]
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
      # TODO: Move to parameters
      $UniFiValues = $false

      # Cleanup
      $Session = $null

      # Safe ProgressPreference and Setup SilentlyContinue for the function
      $ExistingProgressPreference = ($ProgressPreference)
      $ProgressPreference = 'SilentlyContinue'

      #region CheckSession
      if (-not (Get-UniFiIsAlive))
      {
         #region LoginCheckLoop
         # TODO: Move to config
         [int]$NumberOfRetries = '3'
         [int]$RetryTimer = '5'
         # Setup the Loop itself
         $RetryLoop = $false
         [int]$RetryCounter = '0'
         # Original code/idea was by Thomas Maurer
         do
         {
            try
            {
               # Try to Logout
               try
               {
                  if (-not (Get-UniFiIsAlive))
                  {
                     Throw
                  }
               }
               catch
               {
                  # We don't care about that
                  Write-Verbose -Message 'Logout failed'
               }

               # Try a Session check (login is inherited here within the helper function)
               if (-not (Get-UniFiIsAlive -ErrorAction Stop -WarningAction SilentlyContinue))
               {
                  Write-Error -Message 'Login failed' -ErrorAction Stop -Category AuthenticationError
               }

               # End the Loop
               $RetryLoop = $true
            }
            catch
            {
               if ($RetryCounter -gt $NumberOfRetries)
               {
                  Write-Warning -Message ('Could still not login, after {0} retries.' -f $NumberOfRetries)

                  # Stay in the Loop
                  $RetryLoop = $true
               }
               else
               {
                  if ($RetryCounter -eq 0)
                  {
                     Write-Warning -Message ('Could not login! Retrying in {0} seconds.' -f $RetryTimer)
                  }
                  else
                  {
                     Write-Warning -Message ('Retry {0} of {1} failed. Retrying in {2} seconds.' -f $RetryCounter, $NumberOfRetries, $RetryTimer)
                  }

                  $null = (Start-Sleep -Seconds $RetryTimer)

                  $RetryCounter = $RetryCounter + 1
               }
            }
         }
         While ($RetryLoop -eq $false)
         #endregion LoginCheckLoop
      }
      #endregion CheckSession

      #region ReCheckSession
      if (-not ($RestSession))
      {
         # Restore ProgressPreference
         $ProgressPreference = $ExistingProgressPreference

         Write-Error -Message 'Unable to login! Check the connection to the controller, SSL certificates, and your credentials!' -ErrorAction Stop -Category AuthenticationError

         # Only here to catch a global ErrorAction overwrite
         break
      }
      #endregion ReCheckSession

      # Configure a default display set
      $defaultDisplaySet = 'time', 'download', 'upload', 'latency'

      # Create the default property display set
      $defaultDisplayPropertySet = (New-Object -TypeName System.Management.Automation.PSPropertySet -ArgumentList ('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet))
      $PSStandardMembers = [Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
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
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/stat/report/archive.speedtest'
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)

         $Script:ApiRequestBodyInput = [PSCustomObject][ordered]@{
            attrs = @(
               'xput_download',
               'xput_upload',
               'latency',
               'time'
            )
            Start = $null
            end   = $null
         }

         $paramConvertToJson = @{
            InputObject   = $ApiRequestBodyInput
            Depth         = 5
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }

         $ApiRequestBodyInput = $null

         $Script:ApiRequestBody = (ConvertTo-Json @paramConvertToJson)

         Write-Verbose -Message 'Send the Request'

         $paramInvokeRestMethod = @{
            Method        = 'Post'
            Uri           = $ApiRequestUri
            Headers       = $RestHeader
            Body          = $ApiRequestBody
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
         try
         {
            $null = (Invoke-UniFiApiLogout -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
         }
         catch
         {
            # We don't care about that
            Write-Verbose -Message 'Logout failed'
         }

         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $_)

         # Error Message
         Write-Error -Message 'Unable to get Firewall Groups' -ErrorAction Stop

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

      $Result = @()

      foreach ($item in $Session.data)
      {
         $Object = $null
         $Object = [PSCustomObject][ordered]@{
            id       = $item._id
            latency  = $item.latency
            oid      = $item.oid
            time     = if ($UniFiValues)
            {
               $item.time
            }
            else
            {
               ConvertFrom-UnixTimeStamp -TimeStamp ($item.time) -Milliseconds
            }
            download = if ($UniFiValues)
            {
               $item.xput_download
            }
            else
            {
               [math]::Round($item.xput_download,1)
            }
            upload   = if ($UniFiValues)
            {
               $item.xput_upload
            }
            else
            {
               [math]::Round($item.xput_upload,1)
            }
         }
         $Result = $Result + $object
      }

      # Give this object a unique typename
      $Result.PSObject.TypeNames.Insert(0,'Speedtest.Result')
      $Result | Add-Member MemberSet PSStandardMembers $PSStandardMembers
   }

   end
   {
      # Dump the Result
      $Result

      # Cleanup
      $Session = $null

      # Restore ProgressPreference
      $ProgressPreference = $ExistingProgressPreference
   }
}
