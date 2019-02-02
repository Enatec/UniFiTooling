function Get-UniFiConfig
{
   <#
         .SYNOPSIS
         It reads the UniFiTooling Module configuration file.

         .DESCRIPTION
         It reads the JSON based UniFiTooling Module configuration file and saves it into variables.

         .PARAMETER Path
         Path to the config file

         .EXAMPLE
         PS C:\> Get-UniFiConfig

         Read the UniFi config file

         .NOTES
         We do not import/read the username and password
         This is an internal helper function, only to reduce the code duplication and maintenance within our other functions.

         .LINK
         Get-UniFiCredentials

         .LINK
         Get-Content

         .LINK
         ConvertFrom-Json
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

      # Cleanup
      $RawJson = $null
      $UnifiConfig = $null

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
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
