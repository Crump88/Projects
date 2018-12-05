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
 $Links = Get-GPOReport -Name $GPObject.DisplayName -ReportType XML | % { ([xml]$_).gpo | Select Name,@{l="LinkedTo";e={$_.LinksTo | % {$_.SOMName}}},@{l="OUPath";e={$_.LinksTo | %{$_.SOMPATH}}}}
 
 $OutputObject = [PSCustomObject]@{

        'GPO' = $GPObject.DisplayName
        'Applied To' = (@($Trustee.Trustee.Name) -join ', ')
        'Linked To' = $Links.LinkedTo -join ', '
        'OU Path' = $Links.OUPath -join ', '
    }

$ReportArray += $OutputObject

}

$ReportArray | Export-CSV "C:\bin\GPOPWrShl.csv" -NoTypeInformation