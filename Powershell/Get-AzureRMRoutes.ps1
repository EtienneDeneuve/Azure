function Check-AzureRMSession () {
    $Error.Clear()
    #if context already exist
    try {
        Get-AzureRmVM -ErrorAction Stop
    }
    catch [System.Management.Automation.PSInvalidOperationException] {
        Login-AzureRmAccount
    }
    $Error.Clear();
}

<#
.SYNOPSIS
    This cmdlet will get all your Routes Tables in your subscription and
    all Routes.
.DESCRIPTION
    This cmdlet will get all your Routes Tables in your subscription and
    all Routes.
.EXAMPLE
    PS C:\> Get-AzureRMRoutes
  k8s-master-39841000-routetable 10.244.0.0/24 VirtualAppliance 172.27.129.10
  k8s-master-39841000-routetable 10.244.1.0/24 VirtualAppliance 172.27.129.11
  k8s-master-39841000-routetable 10.244.3.0/24 VirtualAppliance 172.27.129.4
  k8s-master-39841000-routetable 10.244.4.0/24 VirtualAppliance 172.27.129.5
  k8s-master-39841000-routetable 10.244.2.0/24 VirtualAppliance 172.27.129.127
.NOTES
    This script is under MIT License.
    Made by Etienne Deneuve from Cellenza. etienne[at]deneuve.xyz
#>

Function Get-AzureRMRoutes 
{
[CmdletBinding()]
    param(

    )
Check-AzureRMSession
$tables = Get-AzureRmRouteTable
foreach ($table in $tables) { 
    $routes = Get-AzureRmRouteConfig -RouteTable $table 
    foreach ($route in $routes) {
        Write-Host $table.Name $($route.AddressPrefix) $($route.NextHopType) $($route.NextHopIpAddress)
    }
}
}
