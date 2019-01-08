function Get-UnifiFirewallGroupBody
{
   <#
         .SYNOPSIS
         Build a Body for Set-UnifiFirewallGroup call
	
         .DESCRIPTION
         Build a JSON based Body for Set-UnifiFirewallGroup call
	
         .PARAMETER UnfiFirewallGroup
         Existing Unfi Firewall Group
	
         .PARAMETER UnifiCidrInput
         IPv4 or IPv6 input List
	
         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroupBody -UnfiFirewallGroup $value1 -UnifiCidrInput $value2
	
         Build a Body for Set-UnifiFirewallGroup call

         .NOTES
         This is an internal helper function only

         . LINK
         Set-UnifiFirewallGroup
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Existing Unfi Firewall Group')]
      [ValidateNotNullOrEmpty()]
      [Alias('FirewallGroup')]
      [psobject]
      $UnfiFirewallGroup,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 2,
      HelpMessage = 'IPv4 or IPv6 input List')]
      [ValidateNotNullOrEmpty()]
      [Alias('CidrInput')]
      [psobject]
      $UnifiCidrInput
   )
	
   begin
   {
      Write-Verbose -Message 'Cleanup exitsing Group'
      Write-Verbose -Message "Old Values: $UnfiFirewallGroup.group_members"
      $UnfiFirewallGroup.group_members = $null
   }
	
   process
   {
      Write-Verbose -Message 'Create a new Object'
      $NewUnifiCidrItem = @()
		
      foreach ($UnifiCidrItem in $UnifiCidrInput)
      {
         $NewUnifiCidrItem = $NewUnifiCidrItem + $UnifiCidrItem
      }
		
      # Add the new values
      $paramAddMember = @{
         MemberType = 'NoteProperty'
         Name       = 'group_members'
         Value      = $NewUnifiCidrItem
         Force      = $true
      }
      $UnfiFirewallGroup | Add-Member @paramAddMember
		
      # Cleanup
      $NewUnifiCidrItem = $null
		
      try
      {
         # Create a new Request Body
         $paramConvertToJson = @{
            InputObject   = $UnfiFirewallGroup
            Depth         = 5
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $UnfiFirewallGroupJson = (ConvertTo-Json @paramConvertToJson)
      }
      catch
      {
         $null = (Invoke-InternalScriptVariables)
			
         Write-Error -Message 'Unable to convert new List to JSON' -ErrorAction Stop
			
         break
      }
   }
	
   end
   {
      # Dump
      $UnfiFirewallGroupJson
   }
}