# Current script path
[string]$ModulePath = Split-Path -Path (Get-Variable -Name myinvocation -Scope script).value.Mycommand.Definition -Parent

# Module Pre-Load code
. (Join-Path -Path $ModulePath -ChildPath 'src\other\PreLoad.ps1') @ProfilePathArg

# Private and other methods and variables
Get-ChildItem -Path (Join-Path -Path $ModulePath -ChildPath 'src\private') -Recurse -Filter '*.ps1' -File | Sort-Object -Property Name | ForEach-Object -Process {
   Write-Verbose -Message "Dot sourcing private script file: $($_.Name)"
   . $_.FullName
}

# Load and export public methods
Get-ChildItem -Path (Join-Path -Path $ModulePath -ChildPath 'src\public') -Recurse -Filter '*.ps1' -File | Sort-Object -Property Name | ForEach-Object -Process {
   Write-Verbose -Message "Dot sourcing public script file: $($_.Name)"
   . $_.FullName

   # Find all the functions defined no deeper than the first level deep and export it.
   # This looks ugly but allows us to not keep any uneeded variables in memory that are not related to the module.
   ([Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll({
         $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] 
   }, $false) | ForEach-Object -Process {
      Export-ModuleMember -Function $_.Name
   }
}

# Module Post-Load code
. (Join-Path -Path $ModulePath -ChildPath 'src\other\PostLoad.ps1')
