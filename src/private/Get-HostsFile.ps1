function Get-HostsFile
{
   <#
         .SYNOPSIS
         Print the HOSTS File in a more clean format

         .DESCRIPTION
         Print the HOSTS File in a more clean format

         .PARAMETER Path
         The path to the hosts file where the entry should be set. Defaults to the local computer's hosts file.

         .PARAMETER raw
         Print raw Hosts File

         .EXAMPLE
         PS C:\> Get-HostsFile

         Print the HOSTS File in a more clean format

         .EXAMPLE
         PS C:\> Get-HostsFile -raw

         Print the HOSTS File in the regular format

         .NOTES
         Internal Helper, inspired by an old GIST I found

         .LINK
         Add-HostsEntry

         .LINK
         Remove-HostsEntry

         .LINK
         https://gist.github.com/markembling/173887/1824b370be3fe468faceaed5f39b12bad010a417
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('Hosts', 'hostsfile', 'file', 'filename')]
      [string]
      $Path = "$env:windir\System32\drivers\etc\hosts",
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [Alias('plain')]
      [switch]
      $raw = $false
   )

   begin
   {
      Write-Verbose -Message 'Start Get-HostsFile'

      try
      {
         # Get a clean (end of) file
         $paramGetContent = @{
            Path          = $Path
            Raw           = $true
            Force         = $true
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $HostsFileContent = (Get-Content @paramGetContent )
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

   process
   {
      foreach ($line in $HostsFileContent)
      {
         if ($raw)
         {
            Write-Output -InputObject $line
         }
         else
         {
            $bits = [regex]::Split($line, '\t+')
            if ($bits.count -eq 2)
            {
               [string]$HostsFileLine = $bits

               if (-not ($HostsFileLine.StartsWith('#')))
               {
                  Write-Output -InputObject $HostsFileLine
               }
            }
         }
      }
   }

   end {
      Write-Verbose -Message 'Done Get-HostsFile'
   }
}
