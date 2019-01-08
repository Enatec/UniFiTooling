#requires -Version 3.0 -Modules Pester

<#
      This pester test verifies the PowerShell module manifest file has valid content that will be required to 
      upload to the PowerShell Gallary.

      .EXAMPLE
      PS> Invoke-Pester -Script @{Path = '.\src\tests\ModuleManifest.Tests.ps1'; Parameters = @{ ManifestPath = 'C:\Users\zloeber\Dropbox\Zach_Docs\Projects\Git\PSAD'; Author = 'Zachary Loeber'; Website = 'https://github.com/zloeber/PSAD'; Tags = @('ADSI', 'Active_Directory', 'DC') }}

      Runs some standard tests and a few manual validations (Tags, Author, and Website).
      .EXAMPLE
      PS> Invoke-Pester -Script @{Path = '.\src\tests\ModuleManifest.Tests.ps1'; Parameters = @{ ManifestPath = '.\PSAD.psd1'}}

      Runs several generic tests against the PSAD.psd1 manifest to ensure all required values for uploading to the PowerShell Gallery simply exist.
#>

[CmdLetBinding(DefaultParameterSetName = 'Default')]
Param(
   [Parameter(Mandatory,HelpMessage = 'Add help message for user', ParameterSetName = 'Default')]
   [Parameter(Mandatory, ParameterSetName = 'Manual')]
   [Parameter(Mandatory, ParameterSetName = 'ModuleBuild')]
   [string]$ManifestPath,
   [Parameter(Mandatory,HelpMessage = 'Add help message for user', ParameterSetName = 'ModuleBuild')]
   [string]$ModuleBuildJSONPath,
   [Parameter(ParameterSetName = 'Manual')]
   [string]$Author,
   [Parameter(ParameterSetName = 'Manual')]
   [string]$Copyright,
   [Parameter(ParameterSetName = 'Manual')]
   [string]$Website,
   [Parameter(ParameterSetName = 'Manual')]
   [string]$LicenseURI,
   [Parameter(ParameterSetName = 'Manual')]
   [string]$Version,
   [Parameter(ParameterSetName = 'Manual')]
   [string[]]$Tags
)

if (($ManifestPath.EndsWith('psd1')) -and (Test-Path -Path $ManifestPath)) 
{
   # Grab the short module name
   $ModuleName = (Split-Path -Path $ManifestPath -Leaf).Split('.')[0]

   Describe -Name 'Module Manifest - Standard Tests' -Fixture {
      Context -Name "Testing $ManifestPath" -Fixture {
         It -Name 'should be a valid module manifest file' -Test {
            {
               $Script:Manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
            } |  Should Not Throw
         }

         It -Name 'should have a valid RootModule value' -Test {
            $Script:Manifest.RootModule | Should Be "$ModuleName.psm1"
         }

         It -Name 'should have a valid GUID' -Test {
            ($Script:Manifest.Guid).Guid | Should BeLike '????????-????-????-????-????????????'
         }

         It -Name 'should have a valid PowerShellVersion value' -Test {
            $Script:Manifest.PowerShellVersion | Should Not BeNullOrEmpty
         }
      }
   }

   switch ($PSCmdlet.ParameterSetName) {
      'Default' 
      {
         # Passed just a module manifest file name with no other information to validate
         # This will check for several entries that they simply exist.
         Describe -Name 'Module Manifest - Generic Tests' -Fixture {
            Context -Name "Testing $ManifestPath" -Fixture {
               It -Name 'should have a valid Module version' -Test {
                  ($Script:Manifest.Version).ToString() -as [Version] | Should Not BeNullOrEmpty
               }

               It -Name 'should have a valid module description' -Test {
                  $Script:Manifest.Description | Should Not BeNullOrEmpty
               }

               It -Name 'should have a valid module author' -Test {
                  $Script:Manifest.Author | Should Not BeNullOrEmpty
               }

               It -Name 'should have a valid module project website' -Test {
                  $Script:Manifest.ProjectUri.OriginalString | Should Not BeNullOrEmpty
               }

               It -Name 'should have a valid license URL' -Test {
                  $Script:Manifest.LicenseUri | Should Not BeNullOrEmpty
               }

               It -Name 'should have some tags' -Test {
                  @($Script:Manifest.PrivateData.PSData.Tags).Count -gt 0 | Should Be $true
               }
            }
         }
      }
      'Manual' 
      {
         # Passed a manifest name and several manual entries to validate
         Describe -Name 'Module Manifest - Manual Tests' -Fixture {
            Context -Name "Testing $ManifestPath" -Fixture {
               if (-not [string]::IsNullOrEmpty($Version)) 
               {
                  It -Name "should be module version '$Version'" -Test {
                     ($Script:Manifest.Version).ToString() -as [Version] | Should Be $Version
                  }
               }
               if (-not [string]::IsNullOrEmpty($Description)) 
               {
                  It -Name "should have a module description of '$Description'" -Test {
                     $Script:Manifest.Description | Should Be $Description
                  }
               }

               if (-not [string]::IsNullOrEmpty($Author)) 
               {
                  It -Name "should have the module author of '$Author'" -Test {
                     $Script:Manifest.Author | Should Be $Author
                  }
               }
                    
               if (-not [string]::IsNullOrEmpty($Copyright)) 
               {
                  It -Name "should have a Copyright of '$Copyright'" -Test {
                     $Script:Manifest.Copyright | Should Be $Copyright
                  }
               }
                    
               if (-not [string]::IsNullOrEmpty($Website)) 
               {
                  It -Name "should have the project website of '$Website'" -Test {
                     $Script:Manifest.ProjectUri.OriginalString | Should Be $Website
                  }
               }

               if (-not [string]::IsNullOrEmpty($LicenseURI)) 
               {
                  It -Name "should have the license URI of '$LicenseURI'" -Test {
                     $Script:Manifest.LicenseUri  | Should Be $LicenseURI
                  }
               }
               if ($Tags.Count -gt 0) 
               {
                  It -Name "should have these tags: $($Tags -join ',')" -Test {
                     Compare-Object -ReferenceObject $Script:Manifest.PrivateData.PSData.Tags -DifferenceObject $Tags | Should Be $Null
                  }
               }
            }
         }
      }
      'ModuleBuild' 
      {
         # Passed a manifest name and a ModuleBuild json configuration file to validate
         if (($ModuleBuildJSONPath.EndsWith('psd1')) -and (Test-Path -Path $ModuleBuildJSONPath)) 
         {
            try 
            {
               $ModuleInfo = Get-Content -Path $ModuleBuildJSONPath | ConvertFrom-Json
            }
            catch 
            {
               throw "$ModuleBuildJSONPath either does not exist or is not a json file!"
            }
         }
         else 
         {
            throw "$ModuleBuildJSONPath either does not exist or is not a json file!"
         }
         # Passed a manifest name and several manual entries to validate
         Describe -Name 'Module Manifest - ModuleBuild Tests' -Fixture {
            Context -Name "Testing $ManifestPath" -Fixture {
               if (-not [string]::IsNullOrEmpty($Version)) 
               {
                  It -Name "should be module version '$Version'" -Test {
                     ($Script:Manifest.Version).ToString() -as [Version] | Should Be $ModuleInfo.ModuleVersion
                  }
               }
               if (-not [string]::IsNullOrEmpty($Description)) 
               {
                  It -Name "should have a module description of '$Description'" -Test {
                     $Script:Manifest.Description | Should Be $ModuleInfo.ModuleDescription
                  }
               }

               if (-not [string]::IsNullOrEmpty($Author)) 
               {
                  It -Name "should have the module author of '$Author'" -Test {
                     $Script:Manifest.Author | Should Be $ModuleInfo.ModuleAuthor
                  }
               }
                    
               if (-not [string]::IsNullOrEmpty($Copyright)) 
               {
                  It -Name "should have a Copyright of '$Copyright'" -Test {
                     $Script:Manifest.Copyright | Should Be $ModuleInfo.ModuleCopyright
                  }
               }
                    
               if (-not [string]::IsNullOrEmpty($Website)) 
               {
                  It -Name "should have the project website of '$Website'" -Test {
                     $Script:Manifest.ProjectUri.OriginalString | Should Be $ModuleInfo.ModuleWebsite
                  }
               }

               if (-not [string]::IsNullOrEmpty($LicenseURI)) 
               {
                  It -Name "should have the license URI of '$LicenseURI'" -Test {
                     $Script:Manifest.LicenseUri  | Should Be $ModuleInfo.ModuleLicenseURI
                  }
               }
               if ($Tags.Count -gt 0) 
               {
                  It -Name "should have these tags: $($ModuleInfo.ModuleTags -join ',')" -Test {
                     Compare-Object -ReferenceObject $Script:Manifest.PrivateData.PSData.Tags -DifferenceObject $ModuleInfo.ModuleTags | Should Be $Null
                  }
               }
            }
         }
      }
   }
}
else 
{
   Write-Error -Message "$ManifestPath was not found!"
}
