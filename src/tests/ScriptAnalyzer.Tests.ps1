#requires -Version 3.0 -Modules Pester, PSScriptAnalyzer
<#
    This pester test verifies the files in the specified path do not contain sensitive information.

    Example:
    Invoke-Pester -Script @{Path = '.\src\tests\ScriptAnalyzer.Tests.ps1'; Parameters = @{ Path = 'C:\Users\zloeber\Dropbox\Zach_Docs\Projects\Git\PSAD' }}
#>

[CmdletBinding()]
Param(
    [string]$Path
)

if (-not (Get-Item -Path $Path -ErrorAction:SilentlyContinue).PSIsContainer) {
    throw "Either $Path is not a directory or does not exist"
}

Describe -Name 'Testing against PSSA rules' -Fixture {
    Context -Name 'PSSA Standard Rules' -Fixture {
        $analysis = Invoke-ScriptAnalyzer -Path  $Path
        $scriptAnalyzerRules = Get-ScriptAnalyzerRule
        forEach ($rule in $scriptAnalyzerRules) {
            It -Name "Should pass $rule" -Test {
                If ($analysis.RuleName -contains $rule) {
                    $analysis | Where RuleName -EQ $rule -outvariable failures | Out-Default
                    $failures.Count | Should Be 0
                }
            }
        }
    }
}