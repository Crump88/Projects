<#

This script is utilized to pull Group Policy Objects directly from a Domain Controller.
The output will provide a CSV file with Group Policy Objects by name along with which
objects are within the Scope of that Policy.

#>

$GPO = Get-GPO -All

$ReportArray = @()

Foreach ($GPObject in $GPO)

{

 $Trustee = Get-GPPermission -name $GPObject.DisplayName -all | Where Permission -eq GPOApply | Select Trustee
 
 $OutputObject = [PSCustomObject]@{

        'GPO' = $GPObject.DisplayName
        'Applied To' = (@($Trustee.Trustee.Name) -join ', ')
    }

$ReportArray += $OutputObject

}

$ReportArray | Export-CSV "C:\bin\GPOPWrShl.csv" -NoTypeInformation