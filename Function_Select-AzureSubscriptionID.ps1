<#

Description: This function is utilized to dynamically select
             the Azure Subscription that the logged into account
             has access to.
             This elimnates the need to manually find the Subscription
             ID in the Azure Portal

Use:         Select-AzureSubscriptionID will prompt the user to select
             the corresponding number to the Subscription they want to
             perform actions on.

Notes:       This function will not operate if a user is not logged in 
             via Login-AzureRMAccount

#>

Function Select-AzureSubscriptionID
{

# Logic used to ensure the user has an Active Azure Session in Powershell
# prior to prompting for information that requires a session

$LoggedInChecker = Get-AzureRMContext

# Comparison to only proceed with the subscription selection if an Active
# session is detected via $LogginChecker

If($null -ne $LoggedInChecker) # IfStatement_1 (Search for ElseStatement_1)
{

    # Obtain all Subscriptions the user account has access to and place them in $Subscriptions

    $Subscriptions = Get-AzureRmSubscription

    # Initialize the $SubscriptionArray and the Index ($i) variable

    $SubscriptionArray = @()
    $i = 1

    # For Loop to output each subscription the user account has access to.

    ForEach($Sub in $Subscriptions)
    {

    
        $OutputObject=[PsCustomObject]@{
            "Number" = $i
            "Name" = $Sub.Name
            "Subscription ID" = $Sub.ID
        }

    $i++                                  # Increment the Index Variable per iteration of the For Loop
    $SubscriptionArray += $OutputObject   # Enumerate the Array with the $OutputObject within the For Loop
        
    }

    # Provide clarification to user for the output they are receiving
    
    Write-Host "This is a list of all Azure Subscriptions the User Account has access to:" -ForegroundColor Green
    
    Do # DoWhile Loop to ensure the user confirms the selection they make. DoStatement_1 (Search for While_Statement1)
    {
        
        # Provide the $SubscriptionArray that was built in the For Loop to the Shell

        $SubscriptionArray | Out-Host



        # Prompt User to Select the subscription based on the Index "Number" and place in $SubscriptionChoice variable
        Write-Host "Please Type the Number corresponding to the needed Subscription: " -ForegroundColor Green -NoNewLine
        $StringSubscriptionChoice = Read-Host
        $SubscriptionChoice = [convert]::ToInt32($StringSubscriptionChoice, 10)
        $SubscriptionChoice--

        if($SubscriptionChoice -le $SubscriptionArray.Length) # IfStatement_2 (Search for ElseStatement_2)
        {
        
            # Provide Confirmation to User for their Chosen Subscription 
            $ChosenSubscription = Get-AzureRmSubscription -SubscriptionId $SubscriptionArray[$SubscriptionChoice].'Subscription ID' 
            Write-Host "`nYou have selected the following subscription:" -ForegroundColor Green
            $ChosenSubscription | Out-Host

            # Allow User to Confirm their selection
            Write-Host "Is this the correct Subscription[yes/no]? " -ForegroundColor Green -NoNewLine
            $Confirmation = Read-Host 

            # Logic to proceed with Selecting the Subscription if the user confirms their choice.
            if($Confirmation.tolower() -eq 'yes') # IfStatement_3 (Search for ElseStatement_3)
            {
                $SubscriptionID = $SubscriptionArray[$SubscriptionChoice].'Subscription ID'


                <# Set the Azure Subscription to User Choice #>

                Select-AzureRmSubscription -Subscription $SubscriptionID
            }
            else # ElseStatement_3 (Search for IfStatement_3)
            {

                Write-Host "User did not confirm selection.`n" -ForegroundColor Yellow

            }
        }
        else # ElseStatement_2 (Search for IfStatement_2)
        {

            Write-Host "You chose an invalid selection. Your choice was: $SubscriptionChoice`nPlease choose from the below options:" -ForegroundColor Yellow
            $Confirmation = 'no'

        }
    } While ($Confirmation.tolower() -ne 'yes') # WhileStatement_1 (Search for DoStatement_1)
}
else  # ElseStatement_1 (Search for IfStatement_1)
{

Write-Host "No active Azure Session in Powershell - please login with Connect-AzureRMAccount then re-run the function" -ForegroundColor Yellow

}
}
