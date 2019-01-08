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
            # Cleanup
            $RestBody = $null
            $JsonBody = $null

            Write-Verbose -Message 'Check for API Credentials'
            if ((-not $ApiUsername) -or (-not $ApiPassword))
            {
               Write-Error -Message 'Please set the UniFi API Credentials'
					
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
               # Verbose stuff
               $Script:line = $_.InvocationInfo.ScriptLineNumber
               Write-Verbose -Message ('Error was in Line {0}' -f $line)
					
               # Default error handling: Re-Throw the error
               Write-Error -Message ('Error was {0}' -f $_) -ErrorAction Stop
					
               # Only here to catch a global ErrorAction overwrite
               break
            }
         }
			
         end
         {
            Write-Verbose -Message 'Created the Body Object'

            # Cleanup
            $RestBody = $null
         }
      }