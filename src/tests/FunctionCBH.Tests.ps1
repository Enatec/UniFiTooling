#requires -Version 2.0 -Modules Pester

<#
      This pester test verifies the module's public functions all have proper comment based help required for building documentation via PlatyPS.

      Example:
      PS> Invoke-Pester -Script @{Path = '.\src\tests\FuncitonCBH.Tests.ps1'; Parameters = @{ ModuleName = MyModule}}
#>

[CmdletBinding()]
Param(
   [string]$ModuleName
)

If (($ModuleName -like '*.psd1') -and (Test-Path -Path $ModuleName)) 
{
   $Module = (Split-Path -Path $ModuleName -Leaf) -replace '.psd1', ''
}
else 
{
   $Module = $ModuleName
}

if (-not (Get-Module -Name $Module)) 
{
   try 
   {
      Import-Module -Name $ModuleName -Force
   }
   catch 
   {
      throw ('{0} is not loaded.' -f $Module)
   }
}

Describe -Name "Comment Based Help tests for $Module" -Tag Build -Fixture {
   $functions = Get-Command -Module $Module -CommandType Function
   foreach($Function in $functions)
   {
      $help = Get-Help -Name $Function.name
      Context -Name $help.name -Fixture {
         It -Name 'Has a HelpUri' -Test {
            $Function.HelpUri | Should Not BeNullOrEmpty
         }
         It -Name 'Has related Links' -Test {
            $help.relatedLinks.navigationLink.uri.count | Should BeGreaterThan 0
         }
         It -Name 'Has a description' -Test {
            $help.description | Should Not BeNullOrEmpty
         }
         It -Name 'Has an example' -Test {
            $help.examples | Should Not BeNullOrEmpty
         }
         foreach($parameter in $help.parameters.parameter)
         {
            if($parameter -notmatch 'whatif|confirm')
            {
               It -Name "Has a Parameter description for '$($parameter.name)'" -Test {
                  $parameter.Description.text | Should Not BeNullOrEmpty
               }
            }
         }
      }
   }
}