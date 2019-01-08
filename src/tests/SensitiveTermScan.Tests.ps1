#requires -Version 2.0 -Modules Pester
<#
      This pester test verifies the files in the specified path do not contain sensitive information.

      Example:
      Invoke-Pester -Script @{Path = '.\src\tests\SensitiveTermScan.Tests.ps1'; Parameters = @{ Path = 'C:\Users\zloeber\Dropbox\Zach_Docs\Projects\Git\PSAD'; Terms = @('mydomainname.com', 'myservername') }}
#>

[CmdletBinding()]
Param(
   [string]$Path,
   [string[]]$Terms
)

if (Test-Path -Path $Path) 
{
   Describe -Name 'Scan for sensitive terms.' -Fixture {
      foreach ($Term in $Terms) 
      {
         $TermSearch = @(Get-ChildItem -Recurse -Path $Path | Select-String -Pattern $Term)
         Context -Name "Files in $Path" -Fixture {
            It -Name "should not contain the term $Term" -Test {
               $TermSearch.Count -gt 0 | Should Be $false
            }
         }
      }
   }
}
