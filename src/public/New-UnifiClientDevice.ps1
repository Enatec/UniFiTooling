﻿function New-UnifiClientDevice
{
   <#
         .SYNOPSIS
         Create a new user/client-device via the API of the UniFi Controller

         .DESCRIPTION
         Create a new user/client-device via the API of the Ubiquiti UniFi Controller

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .PARAMETER Mac
         Client MAC address

         .PARAMETER Group
         Value for the user group the new user/client-device should belong to which can be obtained from the output of XXX

         .PARAMETER Name
         Name to be given to the new user/client-device (optional)

         .PARAMETER Note
         Note to be applied to the new user/client-device (optional)

         .EXAMPLE
         PS C:\> New-UnifiClientDevice -Mac '84:3a:4b:cd:88:2D' -Group 'Value2'

         Create a new user/client-device

         .EXAMPLE
         PS C:\> New-UnifiClientDevice -Mac '84:3a:4b:cd:88:2D' -Group 'Value2' -UnifiSite 'Contoso'

         Create a new user/client-device on Site 'Contoso'

         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Invoke-UniFiApiLogin

         .LINK
         Invoke-RestMethod
   #>

   [CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default',
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Client MAC address')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiMac', 'MacAddress')]
      [string]
      $Mac,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 2,
      HelpMessage = 'Value for the user group the new user/client-device should belong to')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiGroup', 'ClientGroup', 'UserGroup')]
      [string]
      $Group,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [Alias('UniFiName', 'ClientName', 'UserName')]
      [string]
      $Name = $null,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 4)]
      [Alias('UnifiNote', 'UserNote', 'ClientNote')]
      [string]
      $Note = $null
   )

   begin
   {
      Write-Verbose -Message 'Start New-UnifiClientDevice'

      # Cleanup
      $Session = $null

      #region SafeProgressPreference
      # Safe ProgressPreference and Setup SilentlyContinue for the function
      $ExistingProgressPreference = ($ProgressPreference)
      $ProgressPreference = 'SilentlyContinue'
      #endregion SafeProgressPreference

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
                     throw
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
         while ($RetryLoop -eq $false)
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

      #region MacHandler
      [string]$Mac = (ConvertTo-UniFiValidMacAddress -Mac $Mac)
      #endregion MacHandler

      #region ApiRequestBodyInput
      $Script:ApiRequestBodyInput = [PSCustomObject][ordered]@{
         mac          = $Mac
         usergroup_id = $Group
      }

      if ($Name)
      {
         $ApiRequestBodyInput.name = $Name
      }

      if ($Note)
      {
         $ApiRequestBodyInput.note = $Note
         $ApiRequestBodyInput.noted = $true
      }
      #endregion ApiRequestBodyInput

      # Call meta function
		$paramGetCallerPreference = @{
			Cmdlet	     = $PSCmdlet
			SessionState = $ExecutionContext.SessionState
			ErrorAction  = 'SilentlyContinue'
			WarningAction = 'SilentlyContinue'
		}
		$null = (Get-CallerPreference @paramGetCallerPreference)
   }

   process
   {
      if ($PSCmdlet.ShouldProcess('user/client-device', 'Create'))
      {
         try
         {
            #region ReadConfig
            Write-Verbose -Message 'Read the Config'

            $null = (Get-UniFiConfig)
            #endregion ReadConfig

            #region CertificateHandler
            Write-Verbose -Message ('Certificate check - Should be {0}' -f $ApiSelfSignedCert)

            [Net.ServicePointManager]::ServerCertificateValidationCallback = {
               $ApiSelfSignedCert
            }
            #endregion CertificateHandler

            #region SetRequestHeader
            Write-Verbose -Message 'Set the API Call default Header'

            $null = (Set-UniFiDefaultRequestHeader)
            #endregion SetRequestHeader

            #region SetRequestURI
            Write-Verbose -Message 'Create the Request URI'

            $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/group/user'

            Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
            #endregion SetRequestURI

            #region ApiRequestBody
            $paramConvertToJson = @{
               InputObject   = $ApiRequestBodyInput
               Depth         = 5
               ErrorAction   = 'Stop'
               WarningAction = 'SilentlyContinue'
            }

            $ApiRequestBodyInput = $null

            $Script:ApiRequestBody = (ConvertTo-Json @paramConvertToJson)
            #endregion ApiRequestBody

            #region Request
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

            Write-Verbose -Message "Session Meta: $(($Session.meta.rc | Out-String).Trim())"

            Write-Verbose -Message "Session Data: $("`n" + ($Session.data | Out-String).Trim())"
            #endregion Request
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

            #region ErrorHandler
            # get error record
            [Management.Automation.ErrorRecord]$e = $_

            # retrieve information about runtime error
            $info = [PSCustomObject]@{
               Exception = $e.Exception.Message
               Reason    = $e.CategoryInfo.Reason
               Target    = $e.CategoryInfo.TargetName
               Script    = $e.InvocationInfo.ScriptName
               Line      = $e.InvocationInfo.ScriptLineNumber
               Column    = $e.InvocationInfo.OffsetInLine
            }

            Write-Verbose -Message $info

            Write-Error -Message ($info.Exception) -ErrorAction Stop

            # Only here to catch a global ErrorAction overwrite
            break
            #endregion ErrorHandler
         }
         finally
         {
            #region ResetSslTrust
            # Reset the SSL Trust (make sure everything is back to default)
            [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
            #endregion ResetSslTrust

            #region RestoreProgressPreference
            $ProgressPreference = $ExistingProgressPreference
            #endregion RestoreProgressPreference
         }

         # check result
         if ($Session.meta.rc -ne 'ok')
         {
            # Verbose stuff
            $Script:line = $_.InvocationInfo.ScriptLineNumber

            Write-Verbose -Message ('Error was in Line {0}' -f $line)

            if ($Session.data)
            {
               Write-Verbose -Message "Session Data: $("`n" + ($Session.data | Out-String).Trim())"
            }

            # Error Message
            Write-Error -Message 'Unable to get the network list' -ErrorAction Stop

            # Only here to catch a global ErrorAction overwrite
            break
         }
      }
   }

   end
   {
      # Dump the Result
      Write-Output -InputObject $true

      # Cleanup
      $Session = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start New-UnifiClientDevice'
   }
}
