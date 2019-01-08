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
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiConfig')]
      [string]
      $Path = '.\UniFiConfig.json'
   )
	
   begin
   {
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
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)

         # Default error handling: Re-Throw the error
         Write-Error -Message ('Error was {0}' -f $_) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
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
   }
}