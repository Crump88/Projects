This ReadMe is to describe the function and installation instructions of the module.

Contents:

1.0 - Function
2.0 - Installation Instructions
3.0 - Usage

<## 1.0 Function ##>

This module was built to add functionality in Powershell without having to rely on
the technician to know Powershell cmdlets or use the Azure Portal to obtain information.


<## 2.0 Installation Instructions ##>

Download the ConcertoAzure Folder from: https://github.com/Crump88/Projects

Place this folder locally to: C:\Windows\System32\WindowsPowershell\V1.0\Modules
(Optional) - Open Powershell and type: $env:PSModulePath -split ';'
(Optional) - This will list all default folders where Powershell will look for Modules.
(Optional) - If you prefer to place it in a different path - choose from the output provided.


<## 3.0 Usage ##>

Once the Module has been placed in a proper folder (Seen by the Environment Variable PSModulePath),
on any Powershell terminal or Powershell Script type: Import-Module ConcertoAzure