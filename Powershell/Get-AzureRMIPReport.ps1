Login-AzureRmAccount

$vnets = Get-AzureRmVirtualNetwork 
$nics = get-azurermnetworkinterface
$lbs = Get-AzureRmLoadBalancer
$timestamp = Get-Date -f HHmmss
"`"Nom du VNet`",`"Nom du Subnet`",`"Prefix du Subnet`",`"Resource Group`",`"Machine Virtuelle`",`"Nom de la Nic`",`"Allocation`",`"IP`"" | Out-File -FilePath .\$($timestamp)-Export.csv -Encoding UTF8  -Force
foreach ($vnet in $vnets) {

    Get-SubnetDetails -vnet $vnet -subnet $vnet.Subnets -nics $nics | Out-File -FilePath .\$($timestamp)-Export.csv -Encoding UTF8 -Append
    

}

<#
    .SYNOPSIS
        Get the all the network resources in the provided subnet
    .DESCRIPTION
        
    .EXAMPLE
        PS C:\> Get-SubnetDetails -vnet $vnet -subnet $vnet.Subnets -nics $nics
        
    .NOTES
        This commandlet have been created for a cool customer by Etienne Deneuve from Cellenza
    #>
function Get-SubnetDetails {
    [cmdletbinding()]
    param(
        $vnet,
        $subnet,
        $nics
    )
    foreach ($snet in  $subnet) {
        foreach ($ip in $snet.IpConfigurations) {
            $ipid = $ip.ID.Split("/")
            if ($($ipid[7]) -eq "networkInterfaces") {
                $nic = $nics |Where-Object { $_.Name -eq $($ipid[8]) }
                $vm = $nic.VirtualMachine.Id.Split("/")[8]
                Write-Output "$($vnet.Name),$($snet.Name),$($snet.AddressPrefix),$($ipid[4]),$($vm),$($ipid[8]),$($nic.IpConfigurations.PrivateIpAllocationMethod),$($nic.IpConfigurations.PrivateIpAddress)"
            }
            elseif ($($ipid[7]) -eq "LoadBalancers") {
                $lb = $lbs |Where-Object { $_.Name -eq $($ipid[8]) }
                Write-Output "$($vnet.Name),$($snet.Name),$($snet.AddressPrefix),$($ipid[4]),LoadBalancer,$($ipid[8]),$($lb.FrontendIpConfigurations.PrivateIpAllocationMethod),$($lb.FrontendIpConfigurations.PrivateIpAddress)"
            }
        }
    }    
}
