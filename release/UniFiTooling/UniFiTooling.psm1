#region ModulePreLoaded
<#
      This is an early beta version! I can't recommend using it in production.
#>

function Get-CallerPreference
{
   <#
         .Synopsis
         Fetches "Preference" variable values from the caller's scope.

         .DESCRIPTION
         Script module functions do not automatically inherit their caller's variables, but they can be obtained through the $PSCmdlet variable in Advanced Functions.
         This function is a helper function for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.

         .PARAMETER Cmdlet
         The $PSCmdlet object from a script module Advanced Function.

         .PARAMETER SessionState
         The $ExecutionContext.SessionState object from a script module Advanced Function.
         This is how the Get-CallerPreference function sets variables in its callers' scope, even if that caller is in a different script module.

         .PARAMETER Name
         Optional array of parameter names to retrieve from the caller's scope.
         Default is to retrieve all Preference variables as defined in the about_Preference_Variables help file (as of PowerShell 4.0)
         This parameter may also specify names of variables that are not in the about_Preference_Variables help file, and the function will retrieve and set those as well.

         .EXAMPLE
         Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

         Imports the default PowerShell preference variables from the caller into the local scope.

         .EXAMPLE
         Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'ErrorActionPreference','SomeOtherVariable'

         Imports only the ErrorActionPreference and SomeOtherVariable variables into the local scope.

         .EXAMPLE
         'ErrorActionPreference','SomeOtherVariable' | Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

         Same as Example 2, but sends variable names to the Name parameter via pipeline input.

         .INPUTS
         String

         .OUTPUTS
         None.  This function does not produce pipeline output.

         .LINK
         about_Preference_Variables

         .LINK
         about_CommonParameters

         .LINK
         https://gallery.technet.microsoft.com/scriptcenter/Inherit-Preference-82343b9d

         .LINK
         http://powershell.org/wp/2014/01/13/getting-your-script-module-functions-to-inherit-preference-variables-from-the-caller/

         .NOTE
         Original Script by David Wyatt
   #>

   [CmdletBinding(DefaultParameterSetName = 'AllVariables')]
   param (
      [Parameter(Mandatory,HelpMessage = 'The PSCmdlet object from a script module Advanced Function.')]
      [ValidateScript({
               $_.GetType().FullName -eq 'System.Management.Automation.PSScriptCmdlet'
      })]
      $Cmdlet,
      [Parameter(Mandatory,HelpMessage = ' The ExecutionContext.SessionState object from a script module Advanced Function.')]
      [Management.Automation.SessionState]
      $SessionState,
      [Parameter(ParameterSetName = 'Filtered', ValueFromPipeline)]
      [string[]]
      $Name
   )

   begin
   {
      $filterHash = @{}
   }

   process
   {
      if ($null -ne $Name)
      {
         foreach ($string in $Name)
         {
            $filterHash[$string] = $true
         }
      }
   }

   end
   {
      # List of preference variables taken from the about_Preference_Variables help file in PowerShell version 4.0
      $vars = @{
         'ErrorView'                   = $null
         'FormatEnumerationLimit'      = $null
         'LogCommandHealthEvent'       = $null
         'LogCommandLifecycleEvent'    = $null
         'LogEngineHealthEvent'        = $null
         'LogEngineLifecycleEvent'     = $null
         'LogProviderHealthEvent'      = $null
         'LogProviderLifecycleEvent'   = $null
         'MaximumAliasCount'           = $null
         'MaximumDriveCount'           = $null
         'MaximumErrorCount'           = $null
         'MaximumFunctionCount'        = $null
         'MaximumHistoryCount'         = $null
         'MaximumVariableCount'        = $null
         'OFS'                         = $null
         'OutputEncoding'              = $null
         'ProgressPreference'          = $null
         'PSDefaultParameterValues'    = $null
         'PSEmailServer'               = $null
         'PSModuleAutoLoadingPreference' = $null
         'PSSessionApplicationName'    = $null
         'PSSessionConfigurationName'  = $null
         'PSSessionOption'             = $null
         'ErrorActionPreference'       = 'ErrorAction'
         'DebugPreference'             = 'Debug'
         'ConfirmPreference'           = 'Confirm'
         'WhatIfPreference'            = 'WhatIf'
         'VerbosePreference'           = 'Verbose'
         'WarningPreference'           = 'WarningAction'
      }


      foreach ($entry in $vars.GetEnumerator())
      {
         if (([string]::IsNullOrEmpty($entry.Value) -or -not $Cmdlet.MyInvocation.BoundParameters.ContainsKey($entry.Value)) -and ($PSCmdlet.ParameterSetName -eq 'AllVariables' -or $filterHash.ContainsKey($entry.Name)))
         {
            $variable = $Cmdlet.SessionState.PSVariable.Get($entry.Key)

            if ($null -ne $variable)
            {
               if ($SessionState -eq $ExecutionContext.SessionState)
               {
                  $paramSetVariable = @{
                     Scope   = 1
                     Name    = $variable.Name
                     Value   = $variable.Value
                     Force   = $true
                     Confirm = $false
                     WhatIf  = $false
                  }
                  $null = (Set-Variable @paramSetVariable)
               }
               else
               {
                  $SessionState.PSVariable.Set($variable.Name, $variable.Value)
               }
            }
         }
      }

      if ($PSCmdlet.ParameterSetName -eq 'Filtered')
      {
         foreach ($varName in $filterHash.Keys)
         {
            if (-not $vars.ContainsKey($varName))
            {
               $variable = $Cmdlet.SessionState.PSVariable.Get($varName)

               if ($null -ne $variable)
               {
                  if ($SessionState -eq $ExecutionContext.SessionState)
                  {
                     $paramSetVariable = @{
                        Scope   = 1
                        Name    = $variable.Name
                        Value   = $variable.Value
                        Force   = $true
                        Confirm = $false
                        WhatIf  = $false
                     }
                     $null = (Set-Variable @paramSetVariable)
                  }
                  else
                  {
                     $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                  }
               }
            }
         }
      }
   }
}
#endregion ModulePreLoaded

#region ModulePrivateFunctions
function ConvertFrom-UnixTimeStamp
{
   <#
         .SYNOPSIS
         Converts a Timestamp (Epochdate) into Datetime

         .DESCRIPTION
         Converts a Timestamp (Epochdate) into Datetime

         .PARAMETER TimeStamp
         Timestamp (Epochdate)

         .PARAMETER Milliseconds
         Is the given Timestamp (Epochdate) in Miliseconds instead of Seconds?

         .EXAMPLE
         PS C:\> ConvertFrom-UnixTimeStamp -TimeStamp 1547839380

         Converts a Timestamp (Epochdate) into Datetime

         .EXAMPLE
         PS C:\> ConvertFrom-UnixTimeStamp -TimeStamp 1547839380712 -Milliseconds

         Converts a Timestamp (Epochdate) into Datetime, given value is in Milliseconds

         .NOTES
         Added the 'UniFi' (Alias for the switch 'Milliseconds') because the API returns miliseconds instead of seconds
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([datetime])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            Position = 0,
      HelpMessage = 'Timestamp (Epochdate)')]
      [ValidateNotNullOrEmpty()]
      [Alias('Epochdate')]
      [long]
      $TimeStamp,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [Alias('UniFi')]
      [switch]
      $Milliseconds = $false
   )

   begin
   {
      Write-Verbose -Message 'Start ConvertFrom-UnixTimeStamp'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Set some defaults (Never change this!!!)
      $UnixStartTime = '1/1/1970'

      # Cleanup
      $Result = $null
   }

   process
   {
      try
      {
         if ($Milliseconds)
         {
            $Result = ((Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue).AddMilliseconds($TimeStamp))
         }
         else
         {
            try
            {
               $Result = ((Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue).AddSeconds($TimeStamp))
            }
            catch
            {
               # Try a Fallback!
               $Result = ((Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue).AddMilliseconds($TimeStamp))
            }
         }
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line	  = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         Write-Verbose -Message $info

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
   }

   end
   {
      # Dump to the Console
      $Result

      Write-Verbose -Message 'Done ConvertFrom-UnixTimeStamp'
   }
}

function ConvertTo-UniFiValidMacAddress
{
   <#
         .SYNOPSIS
         Check and transform the given Mac addess for UniFi API usage

         .DESCRIPTION
         Check and transform, if needed, the given Mac addess for UniFi API usage

         .PARAMETER Mac
         Client MAC address

         .EXAMPLE
         PS C:\> ConvertTo-UniFiValidMacAddress -Mac '84-3a-4b-cd-88-2D'

         .NOTES
         Helper to check and make sure we have the right format
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(Mandatory,HelpMessage = 'Client MAC address',
               ValueFromPipeline,
               ValueFromPipelineByPropertyName,
               Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiMac', 'MacAddress')]
      [string]
      $Mac
   )

   begin
   {
      Write-Verbose -Message 'Start ConvertTo-UniFiValidMacAddress'

      # Call meta function
      $paramGetCallerPreference = @{
         Cmdlet        = $PSCmdlet
         SessionState  = $ExecutionContext.SessionState
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $null = (Get-CallerPreference @paramGetCallerPreference)
   }

   process
   {
      # Define the REGEX Filter
      $regex = '((\d|([a-f]|[A-F])){2}){6}'

      # Transform, if needed
      [string]$Mac = $Mac.Trim().Replace(':', '').Replace('.', '').Replace('-', '')

      # Mac everything lower case
      $Mac = $Mac.ToLower()

      # Do a check
      if (($Mac.Length -eq 12) -and ($Mac -match $regex))
      {
         [string]$Mac = ($Mac -replace '..(?!$)', '$&:')
      }
      else
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber

         Write-Verbose -Message ('Error was in Line {0}' -f $line)

         # Error Message
         Write-Error -Message ('Sorry, but {0} is a format that the UniFi Controller will nor understand' -f $Mac) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }
   }

   end
   {
      # Dump to the Console $Mac
      $Mac

      Write-Verbose -Message 'Start ConvertTo-UniFiValidMacAddress'
   }
}

function ConvertTo-UnixTimeStamp
{
   <#
         .SYNOPSIS
         Converts a Datetime into a Unix Timestamp (Epochdate)

         .DESCRIPTION
         Converts a Datetime into a Unix Timestamp (Epochdate)

         .PARAMETER Date
         The Date String that shoul be converted, default is now (if none is given)

         .PARAMETER Milliseconds
         Should the Timestamp (Epochdate) in Miliseconds instead of Seconds?

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp

         Converts the actual time into a Unix Timestamp (Epochdate)

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp -Milliseconds

         Converts the actual time into a Unix Timestamp (Epochdate), in milliseconds

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp -Date ((Get-Date).AddDays(-1))

         Covert the same time yesterday into a Unix Timestamp (Epochdate)

         .EXAMPLE
         PS C:\> ConvertTo-UnixTimeStamp -Date ((Get-Date).AddDays(-1)) -Milliseconds

         Covert the same time yesterday into a Unix Timestamp (Epochdate), in milliseconds

         .NOTES
         Added the 'UniFi' (Alias for the switch 'Milliseconds') because the API returns miliseconds instead of seconds
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([long])]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('TimeStamp', 'DateTimeStamp')]
      [datetime]
      $Date = (Get-Date),
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [Alias('UniFi')]
      [switch]
      $Milliseconds = $false
   )

   begin
   {
      Write-Verbose -Message 'Start ConvertTo-UnixTimeStamp'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Set some defaults (Never change this!!!)
      $UnixStartTime = '1/1/1970'

      # Cleanup
      $Result = $null
   }

   process
   {
      try
      {
         if ($Milliseconds)
         {
            $Result = ([long]((New-TimeSpan -Start (Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue) -End (Get-Date -Date $Date -ErrorAction Stop -WarningAction SilentlyContinue) -ErrorAction Stop -WarningAction SilentlyContinue).TotalMilliseconds))
         }
         else
         {
            $Result = ([long]((New-TimeSpan -Start (Get-Date -Date $UnixStartTime -ErrorAction Stop -WarningAction SilentlyContinue) -End (Get-Date -Date $Date -ErrorAction Stop -WarningAction SilentlyContinue) -ErrorAction Stop -WarningAction SilentlyContinue).TotalSeconds))
         }
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line	  = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         Write-Verbose -Message $info

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
   }

   end
   {
      # Dump to the Console
      $Result

      Write-Verbose -Message 'Done ConvertTo-UnixTimeStamp'
   }
}

function Get-UniFiConfig
{
   <#
         .SYNOPSIS
         Read the UniFi config file

         .DESCRIPTION
         Get the default values from the  UniFi config file

         .PARAMETER Path
         Path to the config file

         .EXAMPLE
         PS C:\> Get-UniFiConfig

         Read the UniFi config file

         .NOTES
         We do not import/read the username and password

         .LINK
         Get-UniFiCredentials
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiConfig')]
      [string]
      $Path = '.\UniFiConfig.json'
   )

   begin
   {
      Write-Verbose -Message 'Start Get-UniFiConfig'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $RawJson = $null
      $UnifiConfig = $null
   }

   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config File'

         $RawJson = (Get-Content -Path $Path -Force -ErrorAction Stop -WarningAction SilentlyContinue)

         Write-Verbose -Message 'Convert the JSON config File to a PSObject'

         $UnifiConfig = ($RawJson | ConvertFrom-Json -ErrorAction Stop -WarningAction SilentlyContinue)
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line	  = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         Write-Verbose -Message $info

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }

      # Cleanup
      $RawJson = $null

      # Set the config for later use
      $Global:ApiProto = $UnifiConfig.protocol

      Write-Verbose -Message ('ApiProto is {0}' -f $ApiProto)

      $Global:ApiHost = $UnifiConfig.Hostname

      Write-Verbose -Message ('ApiHost is {0}' -f $ApiHost)

      $Global:ApiPort = $UnifiConfig.Port

      Write-Verbose -Message ('ApiPort is {0}' -f $ApiPort)

      $Global:ApiSelfSignedCert = $UnifiConfig.SelfSignedCert

      Write-Verbose -Message ('ApiSelfSignedCert is {0}' -f $ApiSelfSignedCert)

      # Build the Base URI String
      $Global:ApiUri = $ApiProto + '://' + $ApiHost + ':' + $ApiPort + '/api/'

      Write-Verbose -Message ('ApiUri is {0}' -f $ApiUri)
   }

   end
   {
      # Cleanup
      $RawJson = $null
      $UnifiConfig = $null

      Write-Verbose -Message 'Done Get-UniFiConfig'
   }
}

function Get-UniFiCredentials
{
   <#
         .SYNOPSIS
         Read the API Credentials from the UniFi config file

         .DESCRIPTION
         Read the API Credentials from the UniFi config file

         .EXAMPLE
         PS C:\> Get-UniFiCredentials

         Read the API Credentials from the UniFi config file

         .NOTES
         Only import/read the username and password

         .LINK
         Get-UniFiConfig
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiConfig')]
      [string]
      $Path = '.\UniFiConfig.json'
   )

   begin
   {
      Write-Verbose -Message 'Start Get-UniFiCredentials'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $RawJson = $null
      $UnifiConfig = $null
   }

   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config File'
         $RawJson = (Get-Content -Path $Path -Force -ErrorAction Stop -WarningAction SilentlyContinue)

         Write-Verbose -Message 'Convert the JSON config File to a PSObject'
         $UnifiConfig = ($RawJson | ConvertFrom-Json -ErrorAction Stop -WarningAction SilentlyContinue)
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line	  = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         Write-Verbose -Message $info

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }

      # Cleanup
      $RawJson = $null

      Write-Verbose -Message 'Try to setup the API Credentials'

      if ((-not $UnifiConfig.Login.Username) -or (-not $UnifiConfig.Login.Password))
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)

         # Bad news!
         Write-Error -Message 'Unable to setup the API Credentials, please check your config file!' -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }

      $ApiUsername = $null
      $ApiPassword = $null
      $Global:ApiUsername = $UnifiConfig.Login.Username
      $Global:ApiPassword = $UnifiConfig.Login.Password

      Write-Verbose -Message 'API Credentials set'
   }

   end
   {
      # Cleanup
      $RawJson = $null
      $UnifiConfig = $null

      Write-Verbose -Message 'Start Get-UniFiCredentials'
   }
}

function Get-UnifiFirewallGroupBody
{
   <#
         .SYNOPSIS
         Build a Body for Set-UnifiFirewallGroup call

         .DESCRIPTION
         Build a JSON based Body for Set-UnifiFirewallGroup call

         .PARAMETER UnfiFirewallGroup
         Existing Unfi Firewall Group

         .PARAMETER UnifiCidrInput
         IPv4 or IPv6 input List

         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroupBody -UnfiFirewallGroup $value1 -UnifiCidrInput $value2

         Build a Body for Set-UnifiFirewallGroup call

         .NOTES
         This is an internal helper function only

         . LINK
         Set-UnifiFirewallGroup
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'Existing Unfi Firewall Group')]
      [ValidateNotNullOrEmpty()]
      [Alias('FirewallGroup')]
      [psobject]
      $UnfiFirewallGroup,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'IPv4 or IPv6 input List')]
      [ValidateNotNullOrEmpty()]
      [Alias('CidrInput')]
      [psobject]
      $UnifiCidrInput
   )

   begin
   {
      Write-Verbose -Message 'Start Get-UnifiFirewallGroupBody'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      Write-Verbose -Message 'Cleanup exitsing Group'
      Write-Verbose -Message "Old Values: $UnfiFirewallGroup.group_members"

      $UnfiFirewallGroup.group_members = $null
   }

   process
   {
      try
      {
         Write-Verbose -Message 'Create a new Object'

         $NewUnifiCidrItem = @()

         foreach ($UnifiCidrItem in $UnifiCidrInput)
         {
            $NewUnifiCidrItem = $NewUnifiCidrItem + $UnifiCidrItem
         }

         # Add the new values
         $paramAddMember = @{
            MemberType = 'NoteProperty'
            Name       = 'group_members'
            Value      = $NewUnifiCidrItem
            Force      = $true
         }
         $UnfiFirewallGroup | Add-Member @paramAddMember

         # Cleanup
         $NewUnifiCidrItem = $null

         # Create a new Request Body
         $paramConvertToJson = @{
            InputObject   = $UnfiFirewallGroup
            Depth         = 5
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $UnfiFirewallGroupJson = (ConvertTo-Json @paramConvertToJson)
      }
      catch
      {
         $null = (Invoke-InternalScriptVariables)

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
      }
   }

   end
   {
      # Dump
      $UnfiFirewallGroupJson

      Write-Verbose -Message 'Done Get-UnifiFirewallGroupBody'
   }
}

function Get-UniFiIsAlive
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
      Write-Verbose -Message 'Start Get-UniFiIsAlive'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $Session = $null

      #region SafeProgressPreference
      # Safe ProgressPreference and Setup SilentlyContinue for the function
      $ExistingProgressPreference = ($ProgressPreference)
      $ProgressPreference = 'SilentlyContinue'
      #endregion SafeProgressPreference

      # Set the default to FALSE
      $SessionStatus = $false
   }

   process
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

         #region UniFiApiLogin
         $null = (Invoke-UniFiApiLogin -ErrorAction SilentlyContinue)
         #endregion UniFiApiLogin

         #region SetRequestHeader
         Write-Verbose -Message 'Set the API Call default Header'

         $null = (Set-UniFiDefaultRequestHeader)
         #endregion SetRequestHeader

         #region SetRequestURI
         Write-Verbose -Message 'Create the Request URI'

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/self'

         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
         #endregion SetRequestURI

         #region Request
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

      #region ResetSslTrust
      # Reset the SSL Trust (make sure everything is back to default)
      [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
      #endregion ResetSslTrust

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      # Dump the Result
      $SessionStatus

      Write-Verbose -Message 'Start Get-UniFiIsAlive'
   }
}

function Invoke-UniFiCidrWorkaround
{
   <#
         .SYNOPSIS
         IPv4 and IPv6 CIDR Workaround for UBNT USG Firewall Rules

         .DESCRIPTION
         IPv4 and IPv6 CIDR Workaround for UBNT USG Firewall Rules (Single IPv4 has to be without /32 OR single IPv6 has to be without /128)

         .PARAMETER CidrList
         Existing CIDR List Object

         .PARAMETER 6
         Process IPv6 CIDR (Single IPv6 has to be without /128)

         .EXAMPLE
         PS C:\> Invoke-UniFiCidrWorkaround -CidrList $value1

         IPv4 CIDR Workaround for UBNT USG Firewall Rules

         .EXAMPLE
         PS C:\> Invoke-UniFiCidrWorkaround -6 -CidrList $value1

         IPv6 CIDR Workaround for UBNT USG Firewall Rules

         .EXAMPLE
         PS C:\> $value1 | Invoke-UniFiCidrWorkaround

         IPv4 or IPv6 CIDR Workaround for UBNT USG Firewall Rules via Pipeline

         .EXAMPLE
         PS C:\> $value1 | Invoke-UniFiCidrWorkaround -6

         IPv6 CIDR Workaround for UBNT USG Firewall Rules via Pipeline

         .NOTES
         This is an internal helper function only (Will be moved to the private functions soon)

         .LINK
         https://github.com/jhochwald/UniFiTooling/issues/5
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory = $true,
               ValueFromPipeline = $true,
               ValueFromPipelineByPropertyName = $true,
               Position = 0,
               HelpMessage = 'Existing CIDR List Object')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiCidrList')]
      [psobject]
      $CidrList,
      [Parameter(ValueFromPipeline = $true,
               ValueFromPipelineByPropertyName = $true,
               Position = 1)]
      [Alias('IPv6', 'V6')]
      [switch]
      $6 = $false
   )

   begin
   {
      Write-Verbose -Message 'Start Invoke-UniFiCidrWorkaround'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $AddItem = @()
   }

   process
   {
      # Loop over the new list
      foreach ($NewInputItem in $CidrList)
      {
         if ($6)
         {
            # CIDR Workaround for UBNT USG Firewall Rules (Single IPv6 has to be without /128)
            if ($NewInputItem -match '/128')
            {
               $NewInputItem = $NewInputItem.Replace('/128', '')
            }
         }
         else
         {
            # CIDR Workaround for UBNT USG Firewall Rules (Single IP has to be without /32)
            if ($NewInputItem -match '/32')
            {
               $NewInputItem = $NewInputItem.Replace('/32', '')
            }
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

      Write-Verbose -Message 'Done Invoke-UniFiCidrWorkaround'
   }
}

function Set-UniFiApiLoginBody
      {
         <#
               .SYNOPSIS
               Create the request body for the UniFi Login

               .DESCRIPTION
               Creates the JSON based request body for the UniFi Login

               .EXAMPLE
               Set-UniFiApiLoginBody

               Creates the JSON based request body for the UniFi Login

               .NOTES
               This is an internal helper function only
         #>
         [CmdletBinding(ConfirmImpact = 'None')]
         param ()

         begin
         {
            Write-Verbose -Message 'Start Set-UniFiApiLoginBody'

            # Call meta function
            $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

            # Cleanup
            $RestBody = $null
            $JsonBody = $null

            Write-Verbose -Message 'Check for API Credentials'
            if ((-not $ApiUsername) -or (-not $ApiPassword))
            {
               Write-Error -Message 'Please set the UniFi API Credentials' -ErrorAction Stop

               # Only here to catch a global ErrorAction overwrite
               break
            }
         }

         process
         {
            Write-Verbose -Message 'Create the Body Object'

            $RestBody = [PSCustomObject][ordered]@{
               username = $ApiUsername
               password = $ApiPassword
            }

            # Convert the Body Object to JSON
            try
            {
               $paramConvertToJson = @{
                  InputObject   = $RestBody
                  Depth         = 5
                  ErrorAction   = 'Stop'
                  WarningAction = 'SilentlyContinue'
               }
               $Script:JsonBody = (ConvertTo-Json @paramConvertToJson)
            }
            catch
            {
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
            }
         }

         end
         {
            Write-Verbose -Message 'Created the Body Object'

            # Cleanup
            $RestBody = $null

            Write-Verbose -Message 'Done Set-UniFiApiLoginBody'
         }
      }

function Set-UniFiDefaultRequestHeader
{
   <#
         .SYNOPSIS
         Set the default Header for all UniFi Requests

         .DESCRIPTION
         Set the default Header for all UniFi Requests

         .EXAMPLE
         PS C:\> Set-UniFiDefaultRequestHeader

         Set the default Header for all UniFi Requests

         .NOTES
         This is an internal helper function only
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param ()

   begin
   {
      Write-Verbose -Message 'Start Set-UniFiDefaultRequestHeader'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $RestHeader = $null
   }

   process
   {
      Write-Verbose -Message 'Create the Default Request Header'

      $Global:RestHeader = @{
         'charset'    = 'utf-8'
         'Content-Type' = 'application/json'
      }

      Write-Verbose -Message ('Default Request Header is {0}' -f $RestHeader)
   }

   end {
      Write-Verbose -Message 'Done Set-UniFiDefaultRequestHeader'
   }
}
#endregion ModulePrivateFunctions

#region ModulePublicFunctions
function Get-Unifi5minutesApStats
{
   <#
         .SYNOPSIS
         5 minutes stats method for a single access point or all access points

         .DESCRIPTION
         5 minutes stats method for a single access point or all access points

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-Unifi5minutesApStats

         .NOTES
         Defaults to the past 12 hours.
         Make sure that the retention policy for 5 minutes stats is set to the correct value in the controller settings
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

function Get-Unifi5minutesClientStats
{
   <#
         .SYNOPSIS
         5 minutes stats method for a single user/client device

         .DESCRIPTION
         5 minutes stats method for a single user/client device

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-Unifi5minutesApStats

         .NOTES
         Defaults to the past 12 hours.
         Make sure that the retention policy for 5 minutes stats is set to the correct value in the controller settings
         TODO: Add missing MAC Parameter
         TODO: Add missing attribs Parameter

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

function Get-Unifi5minutesGatewayStats
{
   <#
         .SYNOPSIS
         5 minutes stats method for a single user/client device

         .DESCRIPTION
         5 minutes stats method for a single user/client device

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-Unifi5minutesGatewayStats

         .NOTES
         Defaults to the past 12 hours.
         Make sure that the retention policy for 5 minutes stats is set to the correct value in the controller settings
         TODO: Add missing MAC Parameter
         TODO: Add missing attribs Parameter

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

function Get-Unifi5minutesSiteStats
{
   <#
         .SYNOPSIS
         5 minutes site stats method, defaults to the past 12 hours

         .DESCRIPTION
         5 minutes site stats method, defaults to the past 12 hours

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-Unifi5minutesSiteStats

         .NOTES
         Defaults to the past 12 hours.
         Make sure that the retention policy for 5 minutes stats is set to the correct value in the controller settings

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

function Get-UnifiAllConnectedClients
{
<#
	.SYNOPSIS
		Method to fetch speed test results

	.DESCRIPTION
		Method to fetch speed test results

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Start
		Startpoint in UniFi Unix timestamp in milliseconds

	.PARAMETER End
		Endpoint in UniFi Unix timestamp in milliseconds

	.EXAMPLE
		PS C:\> Get-UnifiAllConnectedClients

	.NOTES
TODO: Remove Start
TODO: Remove End

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

function Get-UnifiAllGuests
{
<#
	.SYNOPSIS
		Method to fetch speed test results

	.DESCRIPTION
		Method to fetch speed test results

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Start
		Startpoint in UniFi Unix timestamp in milliseconds

	.PARAMETER End
		Endpoint in UniFi Unix timestamp in milliseconds

	.EXAMPLE
		PS C:\> Get-UnifiAllGuests

	.NOTES
TODO: Remove Start
TODO: Remove End

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

function Get-UnifiAuthorizations
{
<#
	.SYNOPSIS
		Method to fetch speed test results

	.DESCRIPTION
		Method to fetch speed test results

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Start
		Startpoint in UniFi Unix timestamp in milliseconds

	.PARAMETER End
		Endpoint in UniFi Unix timestamp in milliseconds

	.EXAMPLE
		PS C:\> Get-UnifiAuthorizations

	.NOTES

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

function Get-UnifiClientDetails
{
<#
	.SYNOPSIS
		Method to fetch speed test results

	.DESCRIPTION
		Method to fetch speed test results

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Start
		Startpoint in UniFi Unix timestamp in milliseconds

	.PARAMETER End
		Endpoint in UniFi Unix timestamp in milliseconds

	.EXAMPLE
		PS C:\> Get-UnifiClientDetails

	.NOTES
TODO: Remove Start
TODO: Remove End
TODO: Add client_mac client device MAC address

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

function Get-UnifiClientLogins
{
<#
	.SYNOPSIS
		Method to fetch speed test results

	.DESCRIPTION
		Method to fetch speed test results

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Start
		Startpoint in UniFi Unix timestamp in milliseconds

	.PARAMETER End
		Endpoint in UniFi Unix timestamp in milliseconds

	.EXAMPLE
		PS C:\> Get-UnifiClientLogins

	.NOTES
		TODO: mac = client MAC address
      TODO: limit = maximum number of sessions to get (default value is 5)
      TODO: Remove Start
      TODO: Remove End

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

function Get-UnifiDailyApStats
{
   <#
         .SYNOPSIS
         Daily stats method for a single access point or all access points

         .DESCRIPTION
         Daily stats method for a single access point or all access points

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-UnifiDailyApStats

         .NOTES
         defaults to the past 7*24 hours
         UniFi controller does not keep these stats longer than 5 hours with versions < 4.6.6
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

function Get-UnifiDailyClientStats
{
   <#
         .SYNOPSIS
         Daily stats method for a single access point or all access points

         .DESCRIPTION
         Daily stats method for a single access point or all access points

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-UnifiDailyClientStats

         .NOTES
         defaults to the past 7*24 hours
         UniFi controller does not keep these stats longer than 5 hours with versions < 4.6.6
         TODO: Add missing MAC Parameter
         TODO: Add missing attribs Parameter

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

function Get-UnifiDailyGatewayStats
{
   <#
         .SYNOPSIS
         Daily stats method for a single access point or all access points

         .DESCRIPTION
         Daily stats method for a single access point or all access points

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-UnifiDailyGatewayStats

         .NOTES
         defaults to the past 7*24 hours
         UniFi controller does not keep these stats longer than 5 hours with versions < 4.6.6
         TODO: Add missing MAC Parameter
         TODO: Add missing attribs Parameter

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

function Get-UnifiDailySiteStats
{
   <#
         .SYNOPSIS
         Daily site stats method

         .DESCRIPTION
         Daily site stats method

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-UnifiDailySiteStats

         .NOTES
         defaults to the past 52*7*24 hours

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

function Get-UnifiFirewallGroupDetails
{
   <#
         .SYNOPSIS
         Get the details about one Firewall Group via the API of the UniFi Controller

         .DESCRIPTION
         Get the details about one Firewall Group via the API of the UniFi Controller

         .PARAMETER Id
         The ID (_id) of the Firewall Group you would like to get detaild information about. Multiple values are supported.

         .PARAMETER Name
         The Name (not the _id) of the Firewall Group you would like to get detaild information about. Multiple values are supported.

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroupDetails -id 'ba7e58be13574ef4881a79c3'

         Get the details about the Firewall Group with ID ba7e58be13574ef4881a79c3 via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroupDetails -name 'MyExtDNS'

         Get the details about the Firewall Group MyExtDNS via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroupDetails -name 'MyExtDNS', 'MailHost'

         Get the details about the Firewall Groups MyExtDNS and MailHost via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroupDetails -id 'ba7e58be13574ef4881a79c3', '2437bdf7fdf04f1a96c0fd32'

         Get the details about the Firewall Groups with IDs ba7e58be13574ef4881a79c3 and 2437bdf7fdf04f1a96c0fd32 via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroupDetails -id 'ba7e58be13574ef4881a79c3' -UnifiSite 'Contoso'

         Get the details about the Firewall Groups with ID ba7e58be13574ef4881a79c3 on Site 'Contoso' via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroupDetails -name 'MailHost' -UnifiSite 'Contoso'

         Get the details about the Firewall Groups MailHost on Site 'Contoso' via the API of the UniFi Controller

         .NOTES
         Initial Release with 1.0.7

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Invoke-UniFiApiLogin

         .LINK
         Invoke-RestMethod

         .LINK
         https://github.com/jhochwald/UniFiTooling/issues/10
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ParameterSetName = 'Request by Id',Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'The ID (_id) of the Firewall Group you would like to get detaild information about.')]
      [ValidateNotNullOrEmpty()]
      [Alias('FirewallGroupId')]
      [string[]]
      $Id,
      [Parameter(ParameterSetName = 'Request by Name', Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'The Name (not the _id) of the Firewall Group you would like to get detaild information about.')]
      [ValidateNotNullOrEmpty()]
      [Alias('FirewallGroupName')]
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
      Write-Verbose -Message 'Start Get-UnifiFirewallGroupDetails'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

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
                  if (-not (Get-UniFiIsAlive)) { Throw }
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

      # Create a new Object
      $SessionData = @()
   }

   process
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

         switch ($PsCmdlet.ParameterSetName)
         {
            'ByName'
            {
               foreach ($SingleName in $Name)
               {
                  # Cleanup
                  $Session = $null

                  Write-Verbose -Message 'Create the Request URI'

                  $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/firewallgroup/'

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

                  Write-Verbose -Message "Session Meta: $(($Session.meta.rc | Out-String).Trim())"
                  Write-Verbose -Message "Session Data: $("`n" + ($Session.data | Out-String).Trim())"

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

                  $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/firewallgroup/' + $SingleId

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

         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line	  = $e.InvocationInfo.ScriptLineNumber
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
   }

   end
   {
      # Dump the Result
      $SessionData

      # Cleanup
      $SessionData = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Done Get-UnifiFirewallGroupDetails'
   }
}

function Get-UnifiFirewallGroups
{
   <#
         .SYNOPSIS
         Get a List Firewall Groups via the API of the UniFi Controller

         .DESCRIPTION
         Get a List Firewall Groups via the API of the Ubiquiti UniFi Controller

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroups

         Get a List Firewall Groups via the API of the Ubiquiti UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroups -UnifiSite 'Contoso'

         Get a List Firewall Groups on Site 'Contoso' via the API of the Ubiquiti UniFi Controller

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
      Write-Verbose -Message 'Start Get-UnifiFirewallGroups'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

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
                  if (-not (Get-UniFiIsAlive)) { Throw }
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
   }

   process
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
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/list/firewallgroup'
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
         #endregion SetRequestURI

         #region Request
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
            Line	  = $e.InvocationInfo.ScriptLineNumber
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

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Done Get-UnifiFirewallGroups'
   }
}

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

function Get-UnifiHourlyClientStats
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
         PS C:\> Get-UnifiHourlyClientStats

         .NOTES
         UniFi controller does not keep these stats longer than 5 hours with versions < 4.6.6
         defaults to the past 7*24 hours
         TODO: Add missing MAC Parameter
         TODO: Add missing attribs Parameter

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

function Get-UnifiHourlyGatewayStats
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
         PS C:\> Get-UnifiHourlyGatewayStats

         .NOTES
         UniFi controller does not keep these stats longer than 5 hours with versions < 4.6.6
         defaults to the past 7*24 hours
         TODO: Add missing MAC Parameter
         TODO: Add missing attribs Parameter

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

function Get-UnifiHourlySiteStats
{
   <#
         .SYNOPSIS
         Hourly site stats method

         .DESCRIPTION
         Hourly site stats method

         .PARAMETER UnifiSite
         ID of the client-device to be modified

         .PARAMETER Start
         Startpoint in UniFi Unix timestamp in milliseconds

         .PARAMETER End
         Endpoint in UniFi Unix timestamp in milliseconds

         .EXAMPLE
         PS C:\> Get-UnifiHourlySiteStats

         .NOTES
         returns an array of hourly stats objects for the current site
         defaults to the past 7*24 hours

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

function Get-UnifiIdsIpsEvents
{
<#
	.SYNOPSIS
		Method to fetch speed test results

	.DESCRIPTION
		Method to fetch speed test results

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Start
		Startpoint in UniFi Unix timestamp in milliseconds

	.PARAMETER End
		Endpoint in UniFi Unix timestamp in milliseconds

	.EXAMPLE
		PS C:\> Get-UnifiIdsIpsEvents

	.NOTES
		TODO: Add missing optinal limit Parameter (defaults to 10000)

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
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 0)]
		[ValidateNotNullOrEmpty()]
		[Alias('Site')]
		[string]
		$UnifiSite = 'default',
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 1)]
		[Alias('Startpoint', 'StartTime')]
		[String]
		$Start,
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
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

function Get-UnifiLoginSessions
{
<#
	.SYNOPSIS
		Method to fetch speed test results

	.DESCRIPTION
		Method to fetch speed test results

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Start
		Startpoint in UniFi Unix timestamp in milliseconds

	.PARAMETER End
		Endpoint in UniFi Unix timestamp in milliseconds

	.EXAMPLE
		PS C:\> Get-UnifiLoginSessions

	.NOTES
		TODO: mac = client MAC address to return sessions for (can only be used when start and end are also provided)
      TODO: type = client type to return sessions for, can be 'all', 'guest' or 'user'; default value is 'all'

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
         Get-UnifiNetworkList

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
      Write-Verbose -Message 'Start Get-UnifiNetworkDetails'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

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
                  if (-not (Get-UniFiIsAlive)) { Throw }
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

      # Create a new Object
      $SessionData = @()
   }

   process
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

         switch ($PsCmdlet.ParameterSetName)
         {
            'Request by Name'
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

                  Write-Verbose -Message "Session Meta: $(($Session.meta.rc | Out-String).Trim())"
                  Write-Verbose -Message "Session Data: $("`n" + ($Session.data | Out-String).Trim())"

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
            'Request by Id'
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
            Line	  = $e.InvocationInfo.ScriptLineNumber
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
   }

   end
   {
      # Dump the Result
      $SessionData

      # Cleanup
      $SessionData = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Get-UnifiNetworkDetails'
   }
}

function Get-UnifiNetworkList
{
   <#
         .SYNOPSIS
         Get a List Networks via the API of the UniFi Controller

         .DESCRIPTION
         Get a List Networks via the API of the Ubiquiti UniFi Controller

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .EXAMPLE
         PS C:\> Get-UnifiNetworkList

         Get a List Networks via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiNetworkList -UnifiSite 'Contoso'

         Get a List Networks on Site 'Contoso' via the API of the UniFi Controller

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
      Write-Verbose -Message 'Start Get-UnifiNetworkList'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

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
                  if (-not (Get-UniFiIsAlive)) { Throw }
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
   }

   process
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/networkconf/'

         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
         #endregion SetRequestURI

         #region Request
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
            Line	  = $e.InvocationInfo.ScriptLineNumber
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
         Write-Verbose -Message ('Error was {0}' -f $Session.meta.rc)

         # Error Message
         Write-Error -Message 'Unable to get the network list' -ErrorAction Stop

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

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Get-UnifiNetworkList'
   }
}

function Get-UnifiSpeedTestResult
{
   <#
         .SYNOPSIS
         Get the UniFi Security Gateway (USG) Speed Test results

         .DESCRIPTION
         Get the UniFi Security Gateway (USG) Speed Test results

         .PARAMETER Timeframe
         Timeframe in hours, default is 24

         .PARAMETER StartDate
         Start date (valid Date String)
         Default is now

         .PARAMETER EndDate
         End date (valid Date String), default is now minus 24 hours

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .PARAMETER all
         Get all existing Speed Test Results

         .PARAMETER UniFiValues
         Show results without modifications, like the UniFi Controller creates them

         .PARAMETER last
         Only test latest Speed Test Result will be displayed

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -last

         Only test latest Speed Test Result will be displayed

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -all

         Get all the UniFi Security Gateway (USG) Speed Test results

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -all | Sort-Object -Property time

         Get all the UniFi Security Gateway (USG) Speed Test results, sorted by date

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult | Select-Object -Property *

         Get the UniFi Security Gateway (USG) Speed Test results from the last 24 hours (default), returns all values

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -UnifiSite 'Contoso'

         Get the UniFi Security Gateway (USG) Speed Test results from the last 24 hours (default)

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -Timeframe 48

         Get the UniFi Security Gateway (USG) Speed Test results of the last 48 hours

         .EXAMPLE
         PS C:\> Get-UnifiSpeedTestResult -StartDate '1/16/2019 12:00 AM' -EndDate '1/16/2019 11:59:59 PM'

         Get the UniFi Security Gateway (USG) Speed Test results for a given time/date
         In the example, all results from 1/16/2019 (all day) will be returned

         .NOTES
         Initial version that makes it more human readable.
         The filetring needs a few more tests

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Invoke-UniFiApiLogin

         .LINK
         Invoke-RestMethod

         .LINK
         ConvertFrom-UnixTimeStamp

         .LINK
         ConvertTo-UnixTimeStamp
   #>
   [CmdletBinding(DefaultParameterSetName = 'DateSet',ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [Alias('Start')]
      [datetime]
      $StartDate,
      [Parameter(ParameterSetName = 'TimeFrameSet',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [Alias('hours')]
      [int]
      $Timeframe,
      [Parameter(ParameterSetName = 'DateSet',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [datetime]
      $EndDate = (Get-Date),
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [switch]
      $all = $false,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 4)]
      [switch]
      $UniFiValues = $false,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 4)]
      [switch]
      $last = $false
   )

   begin
   {
      Write-Verbose -Message 'Start Get-UnifiSpeedTestResult'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

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

      #region ConfigureDefaultDisplaySet
      $defaultDisplaySet = 'time', 'download', 'upload', 'latency'

      # Create the default property display set
      $defaultDisplayPropertySet = (New-Object -TypeName System.Management.Automation.PSPropertySet -ArgumentList ('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet))
      $PSStandardMembers = [Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
      #endregion ConfigureDefaultDisplaySet

      #region Filtering
      switch ($PsCmdlet.ParameterSetName)
      {
         'TimeFrameSet'
         {
            Write-Verbose -Message 'TimeFrameSet'
            if (-not ($StartDate))
            {
               if ($Timeframe)
               {
                  $StartDate = ((Get-Date).AddHours(-$Timeframe))
               }
               else
               {
                  $StartDate = ((Get-Date).AddDays(-1))
               }
            }

            if (-not ($EndDate))
            {
               $EndDate = (Get-Date)
            }
         }
         'DateSet'
         {
            Write-Verbose -Message 'DateSet'
            if (-not ($StartDate))
            {
               $StartDate = ((Get-Date).AddDays(-1))
            }

            if (-not ($EndDate))
            {
               $EndDate = (Get-Date)
            }
         }
      }

      [string]$FilterStartDate = (ConvertTo-UnixTimestamp -Date $StartDate -Milliseconds)
      [string]$FilterEndDate = (ConvertTo-UnixTimestamp -Date $EndDate -Milliseconds)

      if (($all) -or ($last))
      {
         $FilterStartDate = $null
         $FilterEndDate = $null
      }
      #endregion Filtering
   }

   process
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/stat/report/archive.speedtest'

         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
         #endregion SetRequestURI

         #region ApiRequestBodyInput
         $Script:ApiRequestBodyInput = [PSCustomObject][ordered]@{
            attrs = @(
               'xput_download',
               'xput_upload',
               'latency',
               'time'
            )
            start = $FilterStartDate
            end   = $FilterEndDate
         }
         #endregion ApiRequestBodyInput

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
            Line	  = $e.InvocationInfo.ScriptLineNumber
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
         $Result = ($Result + $Object)
      }

      # Give this object a unique typename
      $null = ($Result.PSObject.TypeNames.Insert(0,'Speedtest.Result'))
      $null = ($Result | Add-Member MemberSet PSStandardMembers $PSStandardMembers)

      #region IfLast
      if ($last)
      {
         $Result = ($Result | Sort-Object -Property time | Select-Object -Last 1)
      }
      #endregion IfLast

   }

   end
   {
      # Dump the Result
      $Result

      # Cleanup
      $Session = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Get-UnifiSpeedTestResult'
   }
}

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
      Write-Verbose -Message 'Start Invoke-UniFiApiLogin'

      ## Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $RestSession = $null
      $Session = $null

      #region SafeProgressPreference
      # Safe ProgressPreference and Setup SilentlyContinue for the function
      $ExistingProgressPreference = ($ProgressPreference)
      $ProgressPreference = 'SilentlyContinue'
      #endregion SafeProgressPreference
   }

   process
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

         #region ReadCredentials
         Write-Verbose -Message 'Read the Credentials'
         $null = (Get-UniFiCredentials)
         #endregion

         #region
         Write-Verbose -Message 'Create the Body'
         $null = (Set-UniFiApiLoginBody)
         #endregion

         #region Cleanup
         # Cleanup
         $Session = $null

         Write-Verbose -Message 'Cleanup the credentials variables'

         $ApiUsername = $null
         $ApiPassword = $null
         #endregion Cleanup

         #region SetRequestURI
         Write-Verbose -Message 'Create the Request URI'

         $ApiRequestUri = $ApiUri + 'login'

         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
         #endregion SetRequestURI

         #region Request
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

         Write-Verbose -Message "Session Meta: $(($Session.meta.rc | Out-String).Trim())"

         if ($Session.data)
         {
            Write-Verbose -Message "Session Data: $("`n" + ($Session.data | Out-String).Trim())"
         }

         $Global:RestSession = $RestSession

         # Remove the Body variable
         $JsonBody = $null
         #endregion Request
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line	  = $e.InvocationInfo.ScriptLineNumber
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
         # Remove the Body variable
         $JsonBody = $null

         #region ResetSslTrust
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
         #endregion ResetSslTrust
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

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Done Invoke-UniFiApiLogin'
   }
}

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
      Write-Verbose -Message 'Start Invoke-UniFiApiLogout'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $Session = $null

      #region SafeProgressPreference
      # Safe ProgressPreference and Setup SilentlyContinue for the function
      $ExistingProgressPreference = ($ProgressPreference)
      $ProgressPreference = 'SilentlyContinue'
      #endregion SafeProgressPreference
   }

   process
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

         $ApiRequestUri = $ApiUri + 'logout'

         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
         #endregion SetRequestURI

         #region Request
         Write-Verbose -Message 'Send the Request to Login'

         $paramInvokeRestMethod = @{
            Method        = 'Post'
            Uri           = $ApiRequestUri
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
            WebSession    = $RestSession
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)

         Write-Verbose -Message "Session Meta: $(($Session.meta.rc | Out-String).Trim())"

         if ($Session.data)
         {
            Write-Verbose -Message "Session Data: $("`n" + ($Session.data | Out-String).Trim())"
         }
         #region Request
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line	  = $e.InvocationInfo.ScriptLineNumber
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
         # Remove the Body variable
         $JsonBody = $null

         #region ResetSslTrust
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
         #endregion ResetSslTrust
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

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Invoke-UniFiApiLogout'
   }
}

function Invoke-UnifiAuthorizeGuest
{
   <#
         .SYNOPSIS
         Authorize a client device via the API of the UniFi Controller

         .DESCRIPTION
         Authorize a client device via the API of the Ubiquiti UniFi Controller

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .PARAMETER Mac
         Client MAC address

         .PARAMETER Minutes
         Minutes (from now) until authorization expires, the default is 60 (1 hour)

         .PARAMETER Up
         Upload speed limit in Kilobit per second (kbit/s)

         .PARAMETER Down
         Download speed limit in Kilobit per second (kbit/s)

         .PARAMETER Limit
         Data transfer limit in megabytes (MB), upload and download will be combined.
         The default is unlimited

         .PARAMETER AccessPoint
         MAC address of the Access Point to which client is connected, should result in a much faster authorization

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest -Mac '84:3a:4b:cd:88:2D'

         Authorize a client device via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest -Mac '84:3a:4b:cd:88:2D' -AccessPoint '788a2059c699'

         Authorize a client device via the API of the UniFi Controller, it used the AccessPoint with the Mac address 78:8a:20:59:c6:99 directly for a faster authorization

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest -Mac '843a4bcd882D' -Minutes 180

         Authorize a client device for 180 minutes via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest -Mac '843a4bcd882D' -Up 1024 -Down 2048

         Authorize a client device with a restriction of 1024 kbit/s upload rate and 2048 kbit/s download rate via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest -Mac '843a4bcd882D' -Limit 102400

         Authorize a client device with a limitation of  via 102400 megabytes of traffic (combined) the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiAuthorizeGuest '84-3a-4b-cd-88-2D' -UnifiSite 'Contoso'

         Authorize a client device on site 'Contoso' via the API of the UniFi Controller (The function will normalize the MAC Address for us)

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
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [Alias('UniFiMinutes')]
      [int]
      $Minutes = 60,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [Alias('UniFiUp')]
      [int]
      $Up = $null,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 4)]
      [int]
      $Down = $null,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 5)]
      [Alias('MBytes', 'UniFiLimit', 'UniFiMBytes')]
      [int]
      $Limit = $null,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 6)]
      [Alias('UniFiAccessPoint', 'ApMac', 'UniFiApMac', 'ap_mac')]
      [string]
      $AccessPoint = $null
   )

   begin
   {
      Write-Verbose -Message 'Start Invoke-UnifiAuthorizeGuest'

      # Cleanup
      $Session = $null

      #region MacHandler
      [string]$Mac = (ConvertTo-UniFiValidMacAddress -Mac $Mac)
      #endregion MacHandler

      #region AccessPointMacHandler
      <#
            Make sure we have the right format
      #>
      if ($AccessPoint)
      {
         $regex = '((\d|([a-f]|[A-F])){2}){6}'
         [string]$AccessPoint = $AccessPoint.Trim().Replace(':', '').Replace('.', '').Replace('-', '')
         if (($AccessPoint.Length -eq 12) -and ($AccessPoint -match $regex))
         {
            [string]$AccessPoint = ($AccessPoint -replace '..(?!$)', '$&:')
         }
         else
         {
            # Verbose stuff
            $Script:line = $_.InvocationInfo.ScriptLineNumber

            Write-Verbose -Message ('Error was in Line {0}' -f $line)

            # Error Message
            Write-Error -Message ('Sorry, but {0} is a format that the UniFi Controller will nor understand' -f $AccessPoint) -ErrorAction Stop

            # Only here to catch a global ErrorAction overwrite
            break
         }
      }
      #endregion AccessPointMacHandler

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

      #region ApiRequestBodyInput
      $Script:ApiRequestBodyInput = [PSCustomObject][ordered]@{
         cmd     = 'authorize-guest'
         mac     = $Mac
         minutes = $Minutes
      }

      if ($Up)
      {
         Write-Verbose -Message ('Add upload speed limit: {0}' -f $Up)
         $ApiRequestBodyInput | Add-Member -MemberType NoteProperty -Name up -Value $Up -Force
      }

      if ($Down)
      {
         Write-Verbose -Message ('Add download speed limit: {0}' -f $Down)
         $ApiRequestBodyInput | Add-Member -MemberType NoteProperty -Name down -Value $Down -Force
      }

      if ($Limit)
      {
         Write-Verbose -Message ('Add data transfer limit: {0}' -f $Limit)
         $ApiRequestBodyInput | Add-Member -MemberType NoteProperty -Name bytes -Value $Limit -Force
      }

      if ($AccessPoint)
      {
         Write-Verbose -Message ('Use AP MAC address: {0}' -f $AccessPoint)
         $ApiRequestBodyInput | Add-Member -MemberType NoteProperty -Name ap_mac -Value $AccessPoint -Force
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/cmd/stamgr'

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

         if ($Session.data)
         {
            Write-Verbose -Message "Session Data: $("`n" + ($Session.data | Out-String).Trim())"
            $Result = $true
         }
         else
         {
            $Result = $false
         }
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
         Write-Verbose -Message ('Error was {0}' -f $Session.meta.rc)

         # Error Message
         Write-Error -Message 'Unable to get the network list' -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
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

      Write-Verbose -Message 'Start Invoke-UnifiAuthorizeGuest'
   }
}

function Invoke-UnifiBlockClient
{
   <#
         .SYNOPSIS
         Block a client device via the API of the UniFi Controller

         .DESCRIPTION
         Block a client device via the API of the Ubiquiti UniFi Controller

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .PARAMETER Mac
         Client MAC address

         .EXAMPLE
         PS C:\> Invoke-UnifiBlockClient -Mac '84:3a:4b:cd:88:2D'

         Block a client device via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiBlockClient -Mac '84:3a:4b:cd:88:2D' -UnifiSite 'Contoso'

         Block a client device on Site 'Contoso' via the API of the UniFi Controller

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
      $UnifiSite = 'default',
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Client MAC address')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiMac', 'MacAddress')]
      [string]
      $Mac
   )

   begin
   {
      Write-Verbose -Message 'Start Invoke-UnifiBlockClient'

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
         cmd = 'block-sta'
         mac = $Mac
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/cmd/stamgr'

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

   end
   {
      # Dump the Result
      Write-Output -InputObject $true

      # Cleanup
      $Session = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Invoke-UnifiBlockClient'
   }
}

function Invoke-UnifiForgetClient
{
   <#
         .SYNOPSIS
         Forget one or more client devices via the API of the UniFi Controller

         .DESCRIPTION
         Forget one or more client devices via the API of the Ubiquiti UniFi Controller

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .PARAMETER Mac
         Client MAC address

         .EXAMPLE
         PS C:\> Invoke-UnifiForgetClient -Mac '84:3a:4b:cd:88:2D'

         Forget one or more client devices via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiForgetClient -Mac '84:3a:4b:cd:88:2D' -UnifiSite 'Contoso'

         Forget one or more client devices on Site 'Contoso' via the API of the UniFi Controller

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
      $UnifiSite = 'default',
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Client MAC address')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiMac', 'MacAddress')]
      [string[]]
      $Mac
   )

   begin
   {
      Write-Verbose -Message 'Start Invoke-UnifiForgetClient'

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
         cmd  = 'forget-sta'
         macs = @($Mac)
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/cmd/stamgr'

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

   end
   {
      # Dump the Result
      Write-Output -InputObject $true

      # Cleanup
      $Session = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Invoke-UnifiForgetClient'
   }
}

function Invoke-UnifiReconnectClient
{
   <#
         .SYNOPSIS
         Reconnect a client device via the API of the UniFi Controller

         .DESCRIPTION
         Reconnect a client device via the API of the Ubiquiti UniFi Controller

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .PARAMETER Mac
         Client MAC address

         .EXAMPLE
         PS C:\> Invoke-UnifiReconnectClient -Mac '84:3a:4b:cd:88:2D'

         Reconnect a client device via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiReconnectClient -Mac '84:3a:4b:cd:88:2D' -UnifiSite 'Contoso'

         Reconnect a client device on Site 'Contoso' via the API of the UniFi Controller

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
      $UnifiSite = 'default',
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Client MAC address')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiMac', 'MacAddress')]
      [string]
      $Mac
   )

   begin
   {
      Write-Verbose -Message 'Start Invoke-UnifiReconnectClient'

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
         cmd = 'kick-sta'
         mac = $Mac
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/cmd/stamgr'

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

   end
   {
      # Dump the Result
      Write-Output -InputObject $true

      # Cleanup
      $Session = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Invoke-UnifiReconnectClient'
   }
}

function Invoke-UnifiUnauthorizeGuest
{
   <#
         .SYNOPSIS
         Unauthorize a client device via the API of the UniFi Controller

         .DESCRIPTION
         Unauthorize a client device via the API of the Ubiquiti UniFi Controller

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .PARAMETER Mac
         Client MAC address

         .EXAMPLE
         PS C:\> Invoke-UnifiUnauthorizeGuest -Mac '84:3a:4b:cd:88:2D'

         Unauthorize a client device via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiUnauthorizeGuest -Mac '84:3a:4b:cd:88:2D' -UnifiSite 'Contoso'

         Unauthorize a client device on Site 'Contoso' via the API of the UniFi Controller

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
      $UnifiSite = 'default',
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Client MAC address')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiMac', 'MacAddress')]
      [string]
      $Mac
   )

   begin
   {
      Write-Verbose -Message 'Start Invoke-UnifiUnauthorizeGuest'

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
         cmd = 'unauthorize-guest'
         mac = $Mac
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/cmd/stamgr'

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
            $Result = $true
         }
         else
         {
            $Result = $false
         }

         # Error Message
         Write-Error -Message 'Unable to get the network list' -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }
   }

   end
   {
      # Dump the Result
      Write-Output -InputObject $Result

      # Cleanup
      $Session = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Invoke-UnifiUnauthorizeGuest'
   }
}

function Invoke-UnifiUnblockClient
{
   <#
         .SYNOPSIS
         Unblock a client device via the API of the UniFi Controller

         .DESCRIPTION
         Unblock a client device via the API of the Ubiquiti UniFi Controller

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .PARAMETER Mac
         Client MAC address

         .EXAMPLE
         PS C:\> Invoke-UnifiUnblockClient -Mac '84:3a:4b:cd:88:2D'

         Unblock a client device via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Invoke-UnifiUnblockClient -Mac '84:3a:4b:cd:88:2D' -UnifiSite 'Contoso'

         Unblock a client device on Site 'Contoso' via the API of the UniFi Controller

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
      $UnifiSite = 'default',
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Client MAC address')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiMac', 'MacAddress')]
      [string]
      $Mac
   )

   begin
   {
      Write-Verbose -Message 'Start Invoke-UnifiUnblockClient'

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
         cmd = 'unblock-sta'
         mac = $Mac
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/cmd/stamgr'

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

   end
   {
      # Dump the Result
      Write-Output -InputObject $true

      # Cleanup
      $Session = $null

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Start Invoke-UnifiUnblockClient'
   }
}

function New-UnifiClientDevice
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

function New-UniFiConfig
{
   <#
         .SYNOPSIS
         Creates the UniFi config JSON file

         .DESCRIPTION
         Creates the UniFi config JSON file. If no input is given it creates one with all the defaults.

         .PARAMETER UniFiUsername
         The login of a UniFi User with admin rights

         .PARAMETER UniFiPassword
         The password for the user given above. It is clear text for now. I know... But the Ubiquiti UniFi Controller seems to understand plain text only.

         .PARAMETER UniFiProtocol
         Valid is http and https. default is https
         Please note: http is untested and it might not even work!

         .PARAMETER UniFiSelfSignedCert
         If you use a self signed certificate and/or a certificate from an untrusted CA, you might want to use true here.
         Default is FALSE

         .PARAMETER UniFiHostname
         The Ubiquiti UniFi Controller you want to use. You can use a Fully-Qualified Host Name (FQHN) or an IP address.

         .PARAMETER UniFiPort
         The port number that you have configured on your Ubiquiti UniFi Controller.
         The default is 8443

         .PARAMETER Path
         Where to safe the JSON config. Default is the directory where you call the function.
         e.g. .\UniFiConfig.json

         .PARAMETER force
         Replaces the contents of a file, even if the file is read-only. Without this parameter, read-only files are not changed.

         .EXAMPLE
         PS C:\> New-UniFiConfig

         .EXAMPLE
         PS C:\> New-UniFiConfig -UniFiUsername 'unfi.admin.user' -UniFiPassword 'mySuperSecretPassworHere' -UniFiProtocol 'https' -UniFiSelfSignedCert $true -UniFiHostname 'unifi.contoso.com' -UniFiPort '8443' -Path '.\UniFiConfig.json'

         .EXAMPLE
         PS C:\> New-UniFiConfig -UniFiUsername 'unfi.admin.user' -UniFiPassword 'mySuperSecretPassworHere' -UniFiProtocol 'https' -UniFiSelfSignedCert $true -UniFiHostname 'unifi.contoso.com' -UniFiPort '8443' -Path '.\UniFiConfig.json' -force

         .NOTES
         Just an helper function to create a JSON config

         .LINK
         Get-UniFiConfig

         .LINK
         Get-UniFiCredentials
   #>

   [CmdletBinding(ConfirmImpact = 'None',
   SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiUsername')]
      [string]
      $UniFiUsername = 'unfi.admin.user',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiPassword')]
      [string]
      $UniFiPassword = 'mySuperSecretPassworHere',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [ValidateSet('http', 'https', IgnoreCase = $true)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiProtocol')]
      [string]
      $UniFiProtocol = 'https',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiSelfSignedCert')]
      [bool]
      $UniFiSelfSignedCert = $false,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 4)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiHostname')]
      [string]
      $UniFiHostname = 'unifi.contoso.com',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 5)]
      [ValidateNotNullOrEmpty()]
      [Alias('enUniFiPort')]
      [int]
      $UniFiPort = 8443,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 6)]
      [ValidateNotNullOrEmpty()]
      [Alias('enConfigPath', 'ConfigPath')]
      [string]
      $Path = '.\UniFiConfig.json',
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 7)]
      [switch]
      $force = $false
   )

   begin
   {
      Write-Verbose -Message 'Start New-UniFiConfig'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      #region JsonInputData
      $JsonInputData = [PSCustomObject][ordered]@{
         Login          = [PSCustomObject][ordered]@{
            Username = $UniFiUsername
            Password = $UniFiPassword
         }
         protocol       = $UniFiProtocol
         SelfSignedCert = $UniFiSelfSignedCert
         Hostname       = $UniFiHostname
         Port           = $UniFiPort
      }
      #endregion JsonInputData
   }

   process
   {
      try
      {
         #region JsonData
         $paramConvertToJson = @{
            InputObject   = $JsonInputData
            Depth         = 2
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $JsonData = (ConvertTo-Json @paramConvertToJson)

         $paramSetContent = @{
            Value         = $JsonData
            Path          = $Path
            PassThru      = $true
            Force         = $force
            Confirm       = $false
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         if ($pscmdlet.ShouldProcess($Path, 'Create'))
         {
            $null = (Set-Content @paramSetContent)
         }
      }
      catch
      {
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
   }

   end
   {
      # Cleanup
      $JsonInputData = $null
      $paramConvertToJson = $null

      Write-Verbose -Message 'Done New-UniFiConfig'
   }
}

function Set-UnifiClientDeviceName
{
   <#
         .SYNOPSIS
         Add/modify/remove a client device name

         .DESCRIPTION
         Add/modify/remove a client device name

         .PARAMETER Site
         UniFi Site as configured. The default is: default

         .PARAMETER Client
         ID of the client device to be modified

         .PARAMETER Name
         Name to be applied to the client device

         .EXAMPLE
         PS C:\> Set-UnifiClientDeviceName -Client 'Value1'

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
      HelpMessage = 'ID of the client-device to be modified')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiClient', 'UniFiUser', 'UniFiID')]
      [string]
      $Client,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [Alias('UniFiName', 'UniFiClientName', 'UniFiUserName')]
      [string]
      $Name
   )

   begin
   {
		Write-Verbose -Message 'begin'
   }

   process
   {
      if ($pscmdlet.ShouldProcess('client-device', 'Add/modify/remove'))
      {
         Write-Verbose -Message 'process'
      }
   }

   end
   {
		Write-Verbose -Message 'end'
   }
}

function Set-UnifiClientDeviceNote
{
<#
	.SYNOPSIS
		Add/modify/remove a client-device note

	.DESCRIPTION
		Add/modify/remove a client-device note

	.PARAMETER UnifiSite
		A description of the UnifiSite parameter.

	.PARAMETER Client
		ID of the client-device to be modified

	.PARAMETER Note
		Note to be applied to the client-device (optional)

	.EXAMPLE
		PS C:\> Set-UnifiClientDeviceNote -Client 'Value1'

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
				   HelpMessage = 'ID of the client-device to be modified')]
		[ValidateNotNullOrEmpty()]
		[Alias('UniFiClient', 'UniFiUser', 'UniFiID')]
		[string]
		$Client,
		[Parameter(ValueFromPipeline,
				   ValueFromPipelineByPropertyName,
				   Position = 2)]
		[Alias('UniFiNote', 'UniFiClientNote', 'UniFiUserNote')]
		[string]
		$Note = $null
	)

	begin
	{

	}

	process
	{
		if ($pscmdlet.ShouldProcess("client-device", "Add/modify/remove"))
		{
			#TODO: Place script here
		}
	}

	end
	{

	}
}

function Set-UniFiClientGroup
{
<#
	.SYNOPSIS
		Assign client device to another group

	.DESCRIPTION
		Assign client device to another group

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Client
		id of the user device to be modified

	.PARAMETER Group
		id of the user group to assign user to

	.EXAMPLE
		PS C:\> Set-UniFiClientGroup

	.NOTES
		TBD

	.LINK
		Get-UniFiConfig

	.LINK
		Set-UniFiDefaultRequestHeader

	.LINK
		Invoke-UniFiApiLogin

	.LINK
		Invoke-RestMethod
#>

	[CmdletBinding(ConfirmImpact = 'None',
				   SupportsShouldProcess)]
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
				   HelpMessage = 'id of the user device to be modified')]
		[ValidateNotNullOrEmpty()]
		[Alias('ClientID', 'UniFiClient')]
		[string]
		$Client,
		[Parameter(Mandatory,
				   ValueFromPipeline,
				   ValueFromPipelineByPropertyName,
				   Position = 2,
				   HelpMessage = 'id of the user group to assign user to')]
		[ValidateNotNullOrEmpty()]
		[Alias('GroupId', 'UniFiGroup')]
		[string]
		$Group
	)

	begin
	{
		Write-Verbose -Message 'begin'
	}

	process
	{
		if ($pscmdlet.ShouldProcess('client-device', 'Move to Group_ID'))
		{
			Write-Verbose -Message 'process'
		}
	}

	end
	{
		Write-Verbose -Message 'end'
	}
}

function Set-UniFiClientIpAddress
{
<#
	.SYNOPSIS
		Update client fixedip

	.DESCRIPTION
		Update client fixedip

	.PARAMETER UnifiSite
		ID of the client-device to be modified

	.PARAMETER Client
		id of the user device to be modified

	.PARAMETER UseFixedIp
		boolean defining whether if use_fixedip is true or false

	.PARAMETER Network
		network id where the ip belongs to

	.PARAMETER FixedIp
		value of client fixed_ip field

	.EXAMPLE
		PS C:\> Set-UniFiClientGroup

	.NOTES
		TBD

	.LINK
		Get-UniFiConfig

	.LINK
		Set-UniFiDefaultRequestHeader

	.LINK
		Invoke-UniFiApiLogin

	.LINK
		Invoke-RestMethod
#>

	[CmdletBinding(ConfirmImpact = 'None',
				   SupportsShouldProcess = $true)]
	param
	(
		[Parameter(Mandatory = $false,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 0)]
		[ValidateNotNullOrEmpty()]
		[Alias('Site')]
		[string]
		$UnifiSite = 'default',
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 1,
				   HelpMessage = 'id of the user device to be modified')]
		[ValidateNotNullOrEmpty()]
		[Alias('ClientID', 'UniFiClient')]
		[string]
		$Client,
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 2)]
		[Alias('UniFiUseFixedIp')]
		[switch]
		$UseFixedIp = $false,
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 3)]
		[Alias('UniFiNetwork')]
		[string]
		$Network,
		[Parameter(ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   Position = 4)]
		[Alias('UniFiFixedIp')]
		[ipaddress]
		$FixedIp
	)

	begin
	{
		Write-Verbose -Message 'begin'
	}

	process
	{
		if ($pscmdlet.ShouldProcess('client-device', 'Move to Group_ID'))
		{
			Write-Verbose -Message 'process'
		}
	}

	end
	{
		Write-Verbose -Message 'end'
	}
}

function Set-UnifiFirewallGroup
{
   <#
         .SYNOPSIS
         Get a given Firewall Group via the API of the UniFi Controller

         .DESCRIPTION
         Get a given Firewall Group via the API of the Ubiquiti UniFi Controller

         .PARAMETER UnfiFirewallGroup
         Unfi Firewall Group

         .PARAMETER UnifiCidrInput
         IPv4 or IPv6 input List (PSObject)

         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default

         .EXAMPLE
         PS C:\> Set-UnifiFirewallGroup -UnfiFirewallGroup 'Value1' -UnifiCidrInput $value2

         Get a given Firewall Group via the API of the Ubiquiti UniFi Controller

         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UnifiFirewallGroups

         .LINK
         Get-UnifiFirewallGroupBody

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
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'Unfi Firewall Group')]
      [ValidateNotNullOrEmpty()]
      [Alias('FirewallGroup')]
      [string]
      $UnfiFirewallGroup,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'IPv4 or IPv6 input List')]
      [ValidateNotNullOrEmpty()]
      [Alias('CidrInput')]
      [psobject]
      $UnifiCidrInput,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default'
   )

   begin
   {
      Write-Verbose -Message 'Start Set-UnifiFirewallGroup'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      # Cleanup
      $TargetFirewallGroup = $null
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
                  if (-not (Get-UniFiIsAlive)) { Throw }
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

      Write-Verbose -Message ('Check if {0} exists' -f $UnfiFirewallGroup)

      $TargetFirewallGroup = (Get-UnifiFirewallGroups | Where-Object -FilterScript {
            ($_.Name -eq $UnfiFirewallGroup)
      })

      if (-not $TargetFirewallGroup)
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)

         Write-Error -Message ('Unable to find the Firewall Group {0}' -f $UnfiFirewallGroup) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }

      Write-Verbose -Message ('{0} exists' -f $UnfiFirewallGroup)

      $UnfiFirewallGroupBody = (Get-UnifiFirewallGroupBody -UnfiFirewallGroup $TargetFirewallGroup -UnifiCidrInput $UnifiCidrInput)
   }

   process
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/firewallgroup/' + $TargetFirewallGroup._id

         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
         #endregion SetRequestURI

         #region Request
         Write-Verbose -Message 'Send the Request'

         $paramInvokeRestMethod = @{
            Method        = 'Put'
            Uri           = $ApiRequestUri
            Headers       = $RestHeader
            Body          = $UnfiFirewallGroupBody
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
            Line	  = $e.InvocationInfo.ScriptLineNumber
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

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Done Set-UnifiFirewallGroup'
   }
}

function Set-UnifiNetworkDetails
{
   <#
         .SYNOPSIS
         Modifies one network via the API of the UniFi Controller

         .DESCRIPTION
         Modifies one network via the API of the UniFi Controller

         .PARAMETER UnifiNetwork
         The ID (network_id) of the network you would like to get detailed information about.

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
         Invoke-UniFiApiLogin

         .LINK
         Invoke-RestMethod
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'The ID (network_id) of the network you would like to get detaild information about.')]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiNetworkId', 'NetworkId')]
      [string]
      $UnifiNetwork,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'JSON formed Body for the Request')]
      [ValidateNotNullOrEmpty()]
      [Alias('Body')]
      [string]
      $UniFiBody,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default'
   )

   begin
   {
      Write-Verbose -Message 'Start Set-UnifiNetworkDetails'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

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
                  if (-not (Get-UniFiIsAlive)) { Throw }
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
   }

   process
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

         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/networkconf/' + $UnifiNetwork

         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
         #endregion SetRequestURI

         #region Request
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
            Line	  = $e.InvocationInfo.ScriptLineNumber
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

      #region RestoreProgressPreference
      $ProgressPreference = $ExistingProgressPreference
      #endregion RestoreProgressPreference

      Write-Verbose -Message 'Done Set-UnifiNetworkDetails'
   }
}
#endregion ModulePublicFunctions

#region CHANGELOG
<#
      Version: 1.0.10 - 2019-01-23

      Deprecated
      - Get-HostsFile should never be a part of this module. I just use them for some internal tests.
      - Get-HostsFile should never be a part of this module. I just use them for some internal tests.
      - Get-HostsFile should never be a part of this module. I just use them for some internal tests.
      
      
      Version: 1.0.9 - 2019-01-20

      Added
      - Invoke-UnifiForgetClient - Forget one or more client devices via the API of the UniFi Controller
      - Invoke-UnifiUnblockClient - Unblock a client device via the API of the UniFi Controller
      - Invoke-UnifiBlockClient - Block a client device via the API of the UniFi Controller
      - Invoke-UnifiReconnectClient - Reconnect a client device via the API of the UniFi Controller
      - Invoke-UnifiUnauthorizeGuest - Unauthorize a client device via the API of the UniFi Controller
      - Invoke-UnifiAuthorizeGuest - Authorize a client device via the API of the UniFi Controller
      - Get-UnifiSpeedTestResult has now a -last parameter to get only the latest result
      
      Changed
      - Change some links to the GitHub Wiki
      - Change the Verbose output (Detailed connection details)
      - Refactored a lot of code.
      
      
      Version: 1.0.8 - 2019-01-19

      Added
      - Get-UnifiSpeedTestResult - Get the UniFi Security Gateway (USG) Speed Test results
      - Add-HostsEntry - Add a single Hosts Entry to the HOSTS File (Helper)
      - Remove-HostsEntry - Removes a single Hosts Entry from the HOSTS File (Helper)
      - Get-HostsFile - Print the HOSTS File in a more clean format (Helper)
      - ConvertFrom-UnixTimeStamp - Converts a Timestamp (Epochdate) into Datetime (Helper)
      - ConvertTo-UnixTimeStamp - ConvertTo-UnixTimeStamp (Helper)
      - Get-UniFiIsAlive - Use a simple API call to see if the session is alive (internal not exported function)
      
      Changed
      - Refactored some of the code that handles all errors.
      - All commands now use Get-UniFiIsAlive internally. That should make it easier for new users.
      - Get-UnifiSpeedTestResult has now filtering and returns values human readable
      
      
      Version: 1.0.7 - 2019-01-14

      Added
      - Add License.md, a Markdown version of LICENSE
      - Editor Config
      - Git Attributes File
      - Get-UnifiFirewallGroupDetails - Related to #10
      
      Changed
      - Moved Get-UnifiFirewallGroupBody from Public to Private (No longer exported as command)
      - Add -name parameter to Get-UnifiNetworkDetails - Related to #9
      - Get-UnifiNetworkDetails: For the parameter -UnifiNetworkName an ID (Network_id) must be used, necessary to make it a non breaking change
      - Get-UnifiNetworkDetails: -UnifiNetworkName is now a legacy alias, necessary to make it a non breaking change
      - Add -Id parameter to Get-UnifiNetworkDetails. This replaced the -UnifiNetworkName parameter - Related to #9
      - Add Multi valued inputs to Get-UnifiNetworkDetails
      - Git Ignore extended
      - Markdown Documents tweaked (Header)
      
      Fixed
      - Found the following issue: Even if an obejct is not found (e.g. network) the UniFi API returns OK (200) with null bytes in Data. That is OK, but we need a workaround. Added the Workaround to Get-UnifiFirewallGroupDetails and Get-UnifiNetworkDetails for testing.
      - Position numbers corrected (Now starts with 0 instead off 1)
      
      
      Version: 1.0.6 - 2019-01-13

      Added
      - New function New-UniFiConfig - #1
      - CHANGELOG.md (this file) is back
      - Set $ProgressPreference to 'SilentlyContinue' - #7
      
      
      Version: 1.0.5 - 2019-01-12

      Changed
      - Invoke-UniFiCidrWorkaround now has the parameter -6 to handle IPv6 CIDR data - #5
      - Describe the config.json handling #2
      - Changed the Build System - #3
      - Samples optimized
      - Tweak the build system
      
      Removed
      - Invoke-UniFiCidrWorkaroundV6 is now part of Invoke-UniFiCidrWorkaround - #5
      
      
      Version: 1.0.4 - 2019-01-08

      Changed
      - Samples optimized
      - Tweak the build system
      
      
      Version: 1.0.3 - 2019-01-07

      Added
      - Sample: UpdateUniFiVpnPeerIP - Update a VPN PeerIp for a given UniFi Network (IPSec VPN with dynamic IP)
      - Sample: UpdateUniFiWithLatestExchangeOnlineEndpoints - Update existing UniFi Firewall Groups with the latest Exchange Online Endpoints.
      
      Fixed
      - Debug output removed
      
      
      Version: 1.0.2 - 2019-01-07

      Changed
      - Internal Build Process: Initial internal release
      
      
      Version: 1.0.1 - 2019-01-07

      Added
      - Invoke-UniFiCidrWorkaround for CIDR handling
      - Invoke-UniFiCidrWorkaroundV6 for CIDR handling
      
      
      Version: 1.0.0 - 2019-01-01

      Added
      - config.json instead of hardcoded configuration
      - SYNOPSIS for all functions
      - XML/MAML Documentation
      - Samples
      
      Changed
      - Removed all internal systems (hardcoded for internal use)
      
      
      Version: 0.9.1 - 2019-01-01

      Deprecated
      - Invoke-UBNT* is now Invoke-UniFi*
      
      
      Version: 0.9.0 - 2019-01-01

      Added
      - Controller Parameter (URI) in the Header of the PS1 File
      
      Changed
      - Migrated Invoke-UBNTApiLogin and Invoke-UBNTApiLogout from Invoke-WebRequest to Invoke-RestMethod
      - Better Session handling for Invoke-UBNTApiRequest
      
      
      Version: 0.8.0 - 2019-01-01

      Security
      - Removed Hard coded credentials from the code
      
      
      Version: 0.7.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release
      
      
      Version: 0.6.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release
      
      
      Version: 0.5.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release
      
      
      Version: 0.4.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release
      
      
      Version: 0.3.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release
      
      
      Version: 0.2.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release
      
      
      Version: 0.1.0 - 2019-01-01

      Added
      - Invoke-UBNTApiLogout - With harcoded Controller info
      - Invoke-UBNTApiRequest - Universal Invoke-RestMethod wrapper, tweaked for UBNT Equipment
      - Invoke-UBNTApiLogin - With harcoded credentials and Controller info
#>
#endregion CHANGELOG

#region LICENSE
<#
      Copyright (c) 2019, enabling Technology
      All rights reserved.

      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
      1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
      2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
      3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

      By using the Software, you agree to the License, Terms and Conditions above!
#>
#endregion LICENSE

#region DISCLAIMER
<#
      DISCLAIMER:
      - Use at your own risk, etc.
      - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
      - This is a third-party Software
      - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
      - The developer of this Software is NOT sponsored by or affiliated with Ubiquiti Networks, Inc (UBNT) or any of its subsidiaries in any way
      - The Software is not supported by Microsoft Corp (MSFT)
      - The Software is not supported by Ubiquiti Networks, Inc (UBNT)
      - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER

$ThisModuleLoaded = $true
