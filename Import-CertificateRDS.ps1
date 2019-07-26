####
####
####
#
#   Author: Brian Crump
#   Version: 1.0
#   Purpose: Install certificate on local store and apply to RDS configuration
#   Contents: 
#        1.0 Import Specific Modules
#        2.0 Define Functions
#        3.0 Begin Main Script
#
####
####
####

######
######
#
#     1.0 Import Specific Modules
#
######
######


Import-Module RemoteDesktopServices
Import-Module WebAdministration


######
######
#
#     2.0 Define Functions
#
######
######


# Function that applies certificate for the 2008 OS

Function Apply-08Certificate{

    param([String]$Thumbprint)
    Set-Item -Path 'RDS:\GatewayServer\SSLCertificate\Thumbprint' $Thumbprint
    Set-Item -Path 'RDS:\RemoteApp\DigitalSignatureSettings\Thumbprint' $Thumbprint
    Set-Item -Path 'RDS:\ConnectionBroker\DigitalSignatureSettings\Thumbprint' $Thumbprint

}

# Function that applies the certificate for the 2012/2016 OS's

Function Apply-1216Certificate{
    
    param(
    [string]$ImportFile, 
    [System.Security.SecureString]$Cred
    )


    Set-RDCertificate -Role RDRedirector -ImportPath $ImportFile -Password $Cred -Force
    Set-RDCertificate -Role RDPublishing -ImportPath $ImportFile -Password $Cred -Force
    Set-RDCertificate -Role RDWebAccess -ImportPath $ImportFile -Password $Cred -Force
    Set-RDCertificate -Role RDGateway -ImportPath $ImportFile -Password $Cred -Force

}


# Function to Obtain OS of Current Server

Function Get-OSType{

# Obtains the OS Name via WMI attributes

$OS = (Get-WmiObject Win32_OperatingSystem).Caption
return $OS

}

# Function to Enable SSL Bridging (HTTPS to HTTP)

Function Set-GatewayBridging{

    # Sets value of SSL Bridging to 1 (Enabled with HTTPS to HTTP)
    
    Set-Item -Path RDS:\GatewayServer\SSLBridging 1


}


######
######
#
#     3.0 Begin Main Script
#
######
######

Write-Host "This script will install the certificate you choose (have password ready)."
Write-Host "Running this will bring the customer down temporarily - do you want to proceed(y/n):" -ForegroundColor Red -NoNewline
$Answer = Read-Host

If($Answer.ToLower() -eq "y")
{

    # Call function to retrieve the certificate file
    Write-Host "Browse and Select the Certificate file to import..."
    sleep -Seconds 2

    ############################################
    #File dialog to select Certificate
    ############################################

    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-nUll

    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        InitialDirectory = [Environment]::GetFolderPath('Desktop')
    } 
    # Show Help needed specifically for 2008 - without it, the dialog shows off screen and the script will hang
    $FileBrowser.ShowHelp = $true          
    $FileBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost=$True})) | Out-Null
    $FileBrowser.Filename
        
    $Creds =  Read-Host "Enter the password for the certificate" -AsSecureString
    
    <# Call function to install certificate on local store
    Import-PersonalCertificate($FileBrowser.Filename, $Creds)
    Write-Host "Completed certificate Import..." -ForegroundColor Green #>

    $pfx = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2

    $pfx.import($FileBrowser.Filename, $Creds,"Exportable,PersistKeySet,MachineKeySet")

    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store('My','LocalMachine')
    $store.Open("MaxAllowed")
    $store.Add($pfx)
    $store.Close()
    

    # Obtain thumbprint of installed certificate
    $Thumbprint = (Get-ChildItem Cert:\LocalMachine\My | Where {$_.Subject -like "*internal*"}).Thumbprint

    # Call function to obtain OS Type
    $OSType = Get-OSType

    # If statement to complete either the 2008 or 2012/2016 function to install cert across RDS configuration
    If ($OSType -like "*2008*")
        {

            Apply-08Certificate($Thumbprint)
            Write-Host "Certificate has been applied to the RDS Configuration..." -ForegroundColor Green

        }
    Else
        {
            # Module is not valid in 2008r2, so it is not loaded globally - only when the OS is detected as 2012/2016
            Import-Module RemoteDesktop
            Apply-1216Certificate -ImportFile $FileBrowser.Filename -Cred $Creds
            Write-Host "Certificate has been applied to the RDS Configuration..." -ForegroundColor Green

        }


    # Enable SSL Bridging (HTTPS to HTTP) and restart the gateway service

    Set-GatewayBridging
    Write-Host "Gateway Bridging has been set..." -ForegroundColor Green

    Get-Service "*Gateway*" | restart-Service
    Write-Host "Remote Desktop Gateway service has been restarted" -ForegroundColor Green
}
Else
{
    Write-Host "Did not receive confirmation to proceed - exiting script..." -ForegroundColor Yellow
    sleep -Seconds 3

}
 

Write-Host "Import completed. Press enter to exit..." -ForegroundColor Green
Read-Host

 



