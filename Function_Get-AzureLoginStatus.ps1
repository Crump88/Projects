<#

Description:
This function is utilized to determine if an active session was created within Powershell
to access Azure.

Use:
Can place in other scripts that perform azure functions without having to prompt for login
every instance that script is run.

#>

  Function Get-AzureLoginStatus
{
  # Create Variable to confirm login status - If this Variable is null - it concludes no session
  # has been created
  $LoggedInChecker = Get-AzureRmContext

 #If Statement to proceed to Login if $LoggedInChecker = $Null
 If($LoggedInChecker -eq $null)
 {
    # Provide output for user clarification with a slight delay before receiving Microsoft Login prompt 
    Write-Host "There is no active AzureRM connection - prompting for Login Credentials..." -ForegroundColor Green
    Start-Sleep -Seconds 3
    Login-AzureRmAccount
 }
 else
 {
    # Provide output for user clarification that no Login is needed. 
    Write-Host "Active Session detected" -ForegroundColor Green
 }
}

Get-AzureLoginStatus