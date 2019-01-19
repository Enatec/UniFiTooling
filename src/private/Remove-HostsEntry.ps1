function Remove-HostsEntry
{
   <#
         .SYNOPSIS
         Removes a single Hosts Entry from the HOSTS File

         .DESCRIPTION
         Removes a single Hosts Entry from the HOSTS File, multiple are not supported yet!

         .PARAMETER Path
         The path to the hosts file where the entry should be set. Defaults to the local computer's hosts file.

         .PARAMETER HostName
         The hostname for the hosts entry.

         .EXAMPLE
         PS C:\> Remove-HostsEntry -HostName 'Dummy'

         Remove the entry for the host 'Dummy' from the HOSTS File

         .NOTES
         Internal Helper, inspired by an old GIST I found

         .LINK
         Get-HostsFile

         .LINK
         Add-HostsEntry

         .LINK
         https://gist.github.com/markembling/173887/1824b370be3fe468faceaed5f39b12bad010a417
   #>

   [CmdletBinding(ConfirmImpact = 'Medium',
   SupportsShouldProcess)]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'The hostname for the hosts entry.')]
      [ValidateNotNullOrEmpty()]
      [Alias('Host', 'Name')]
      [string]
      $HostName,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('Hosts', 'hostsfile', 'file', 'Filename')]
      [string]
      $Path = "$env:windir\System32\drivers\etc\hosts"
   )

   begin {
      Write-Verbose -Message 'Start Remove-HostsEntry'

      try
      {
         $paramGetContent = @{
            Path          = $Path
            Raw           = $true
            Force         = $true
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $HostsFileContent = (((Get-Content @paramGetContent ).TrimEnd()).ToString())
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

      $newLines = @()
   }

   process {
      foreach ($line in $HostsFileContent)
      {
         $bits = [regex]::Split($line, '\t+')
         if ($bits.count -eq 2)
         {
            if ($bits[1] -ne $HostName)
            {
               $newLines += $line
            }
         }
         else
         {
            $newLines += $line
         }
      }

      # Write file
      try
      {
         if ($pscmdlet.ShouldProcess('Target', 'Operation'))
         {
            $paramClearContent = @{
               Path          = $Path
               Force         = $true
               Confirm       = $false
               ErrorAction   = 'Stop'
               WarningAction = 'SilentlyContinue'
            }
            $null = (Clear-Content @paramClearContent)

            $paramSetContent = @{
               Path          = $Path
               Value         = $newLines
               Force         = $true
               Confirm       = $false
               Encoding      = 'UTF8'
               ErrorAction   = 'Stop'
               WarningAction = 'SilentlyContinue'
            }
            $null = (Set-Content @paramSetContent)
         }
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

   end {
      Write-Verbose -Message 'Donw Remove-HostsEntry'
   }
}
