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
    This cmdlet will get all your vnet in your subscription and
    generate csv with all the free ip, or the attached resources.
.DESCRIPTION
    This cmdlet will get all your vnet in your subscription and
    generate csv with all the free ip, or the attached resources.
.EXAMPLE
    PS C:\> Test-AzureRMRange -verbose
    VERBOSE: [04-09-2017 15:27:52]: First IP in Range is: 172.27.128.164
    VERBOSE: [04-09-2017 15:27:52]: First IP in Range is: 172.27.128.174
    VERBOSE: [04-09-2017 15:27:52]: Start Processing Subnet : acs-master-snet 172.27.128.164 to 172.27.128.174
    VERBOSE: [04-09-2017 15:27:52]: Testing 172.27.128.164 Availability
    VERBOSE: [04-09-2017 15:27:54]: Testing 172.27.128.164: is Available
    VERBOSE: [04-09-2017 15:27:54]: Testing 172.27.128.164: Generating output
    VERBOSE: [04-09-2017 15:27:54]: Testing 172.27.128.165 Availability
    VERBOSE: [04-09-2017 15:27:56]: Testing 172.27.128.165: is Available
    VERBOSE: [04-09-2017 15:27:56]: Testing 172.27.128.165: Generating output
    VERBOSE: [04-09-2017 15:27:56]: Testing 172.27.128.166 Availability
    VERBOSE: [04-09-2017 15:27:58]: Testing 172.27.128.166: is Available
    VERBOSE: [04-09-2017 15:27:58]: Testing 172.27.128.166: Generating output
    VERBOSE: [04-09-2017 15:27:58]: Testing 172.27.128.167 Availability
    VERBOSE: [04-09-2017 15:28:00]: Testing 172.27.128.167: is Available

    PS C:\> Test-AzureRMRange
    no output check csv file in current folder

.NOTES
    This script is under MIT License.
    This script use function grabbed a long time ago (in 2012) from http://www.truesec.com
    Made by Etienne Deneuve from Cellenza. etienne[at]deneuve.xyz
#>
Function Test-AzureRMRange {
    [CmdletBinding()]
    param(

    )    
    $ErrorActionPreference = 'stop'
    Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tCheck Existing AzureRM Session..."
    Check-AzureRMSession
    Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tLoading vNet..."
    $vnets = Get-AzureRmVirtualNetwork
    Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tLoading Nics..."
    $nics = get-azurermnetworkinterface
    Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tLoading LoadBalancer..."
    $lbs = Get-AzureRmLoadBalancer
    Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tLoading VM..."
    $vms = Get-AzureRMVM
    $timestamp = Get-Date -f dd-MM-yyyy_hh-mm
    foreach ($vnet in $vnets) {
        Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tCreating .\$($timestamp)-$($vnet.name)-Export.csv..." 
        "`"Nom du VNet`",`"RG du VNET`",`"Nom du Subnet`",`"Prefix du Subnet`",`"Resource Group`",`"Machine Virtuelle`",`"Nom de la Nic`",`"Allocation`",`"IP`"" | Out-File -FilePath .\$($timestamp)-$($vnet.name)-Export.csv -Encoding UTF8  -Force
        foreach ($snet in  $vnet.subnets) {
            $array = $($snet.AddressPrefix).Split("/")
            $networkid = $array[0]
            $netmask = $array[1]
            $StartRange = Get-NetworkRange -IP $networkid -Mask $netmask -Azure
            Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tFirst IP in Range is:`t$StartRange"
            $EndRange = Get-NetworkRange -IP $networkid -Mask $netmask
            Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tFirst IP in Range is:`t$EndRange"
            Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tStart Processing Subnet :`t$($snet.Name) $StartRange to $EndRange"
            foreach ($a in ($StartRange.Split(".")[0]..$EndRange.Split(".")[0])) {
                foreach ($b in ($StartRange.Split(".")[1]..$EndRange.Split(".")[1])) {
                    foreach ($c in ($StartRange.Split(".")[2]..$EndRange.Split(".")[2])) {
                        foreach ($d in ($StartRange.Split(".")[3]..$EndRange.Split(".")[3])) {
                            Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tTesting $("$a.$b.$c.$d") Availability"
                            $adress = Test-AzureRmPrivateIPAddressAvailability -VirtualNetworkName $($vnet.Name) -IPAddress $("$a.$b.$c.$d")  -ResourceGroupName $($vnet.ResourceGroupName)
                            if ($adress.Available -eq $false ) { 
                                Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tTesting $("$a.$b.$c.$d"): is not Available"
                                try {
                                    $nic = $nics | Where-Object { $_.IpConfigurations.PrivateIpAddress -eq "$a.$b.$c.$d" }
                                    Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tTesting $("$a.$b.$c.$d"): is a Nic"
                                    $nicvm = $nic.VirtualMachine.Id.Split("/")[8]
                                    Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tTesting $("$a.$b.$c.$d"): is attached to $($nicvm)"
                                    $vm = $vms | Where-Object { $_.Name -eq $nicvm }
                                    Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tTesting $("$a.$b.$c.$d"): VM is found"
                                    Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tTesting $("$a.$b.$c.$d"): Generating output"
                                    Write-Output "$($vnet.Name),$($vnet.ResourceGroupName),$($snet.Name),$($snet.AddressPrefix),$($vm.ResourceGroupName),$($vm.Name),$($nic.Name),$($nic.IpConfigurations.PrivateIpAllocationMethod),$($nic.IpConfigurations.PrivateIpAddress)" | Out-File -FilePath .\$($timestamp)-$($vnet.name)-Export.csv -Encoding UTF8 -Append
                                }
                                catch {
                                    $lb = $lbs |Where-Object { $_.FrontendIpConfigurations.PrivateIpAddress -eq "$a.$b.$c.$d" }
                                    Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tTesting $("$a.$b.$c.$d"): is an ILB"
                                    Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tTesting $("$a.$b.$c.$d"): Generating output"
                                    Write-Output "$($vnet.Name),$($vnet.ResourceGroupName),$($snet.Name),$($snet.AddressPrefix),$($lb.ResourceGroupName),LoadBalancer,$($lb.Name),$($lb.FrontendIpConfigurations.PrivateIpAllocationMethod),$($lb.FrontendIpConfigurations.PrivateIpAddress)" | Out-File -FilePath .\$($timestamp)-$($vnet.name)-Export.csv -Encoding UTF8 -Append
                                }
                            }
                            else {
                                Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tTesting $("$a.$b.$c.$d"): is Available"
                                Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tTesting $("$a.$b.$c.$d"): Generating output"
                                Write-Output "$($vnet.Name),$($vnet.ResourceGroupName),$($snet.Name),$($snet.AddressPrefix),free,free,free,free,$("$a.$b.$c.$d")" | Out-File -FilePath .\$($timestamp)-$($vnet.name)-Export.csv -Encoding UTF8 -Append
                            }
                        }
                    }
                }
            }
            Write-Verbose "[$(Get-Date -f "dd-MM-yyyy HH:mm:ss")]:`tEnd Processing Subnet :`t$($snet.Name) $StartRange to $EndRange"
        }
    }
}

#region Range Calc
Function Get-NetworkRange {
    Param (
        [String]$IP,
        [String]$Mask,
        [Switch]$Start,
        [switch]$Azure
    )
    If ($IP.Contains("/")) {
        $Temp = $IP.Split("/")
        $IP = $Temp[0]
        $Mask = $Temp[1]
    }
    If (!$Mask.Contains(".")) {
        $Mask = ConvertTo-Mask $Mask
    }
    $DecimalIP = ConvertTo-DecimalIP $IP
    $DecimalMask = ConvertTo-DecimalIP $Mask
    $Network = $DecimalIP -BAnd $DecimalMask
    $Broadcast = $DecimalIP -BOr ((-BNot $DecimalMask) -BAnd [UInt32]::MaxValue)
    if ($start) {
        ConvertTo-DottedDecimalIP $($Network + 1)
    }
    elseif ($Azure) {
        ConvertTo-DottedDecimalIP $($Network + 4)
    }
    else {
        ConvertTo-DottedDecimalIP $($Broadcast - 1)
    }
}  

<#
.Synopsis
  Converts a Decimal IP address into a 32-bit unsigned integer.
.Description
  ConvertTo-DecimalIP takes a decimal IP, uses a shift-like operation on each octet and returns a single UInt32 value.
.Parameter IPAddress
  An IP Address to convert.
#>
Function ConvertTo-DecimalIP {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [Net.IPAddress]$IPAddress
    )

    Process {
        $i = 3; $DecimalIP = 0;
        $IPAddress.GetAddressBytes() | ForEach-Object { $DecimalIP += $_ * [Math]::Pow(256, $i); $i-- }

        Return [UInt32]$DecimalIP
    }
}

Function ConvertTo-DottedDecimalIP {
    <#
    .Synopsis
      Returns a dotted decimal IP address from either an unsigned 32-bit integer or a dotted binary string.
    .Description
      ConvertTo-DottedDecimalIP uses a regular expression match on the input string to convert to an IP address.
    .Parameter IPAddress
      A string representation of an IP address from either UInt32 or dotted binary.
  #>
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [String]$IPAddress
    )
   
    Process {
        Switch -RegEx ($IPAddress) {
            "([01]{8}\.){3}[01]{8}" {
                Return [String]::Join('.', $( $IPAddress.Split('.') | ForEach-Object { [Convert]::ToUInt32($_, 2) } ))
            }
            "\d" {
                $IPAddress = [UInt32]$IPAddress
                $DottedIP = $( For ($i = 3; $i -gt -1; $i--) {
                        $Remainder = $IPAddress % [Math]::Pow(256, $i)
                        ($IPAddress - $Remainder) / [Math]::Pow(256, $i)
                        $IPAddress = $Remainder
                    } )
        
                Return [String]::Join('.', $DottedIP)
            }
           default {
                Write-Error "Cannot convert this format"
            }
        }
    }
}
Function ConvertTo-Mask {
    <#
    .Synopsis
      Returns a dotted decimal subnet mask from a mask length.
    .Description
      ConvertTo-Mask returns a subnet mask in dotted decimal format from an integer value ranging 
      between 0 and 32. ConvertTo-Mask first creates a binary string from the length, converts 
      that to an unsigned 32-bit integer then calls ConvertTo-DottedDecimalIP to complete the operation.
    .Parameter MaskLength
      The number of bits which must be masked.
  #>
   
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [Alias("Length")]
        [ValidateRange(0, 32)]
        $MaskLength
    )
   
    Process {
        Return ConvertTo-DottedDecimalIP ([Convert]::ToUInt32($(("1" * $MaskLength).PadRight(32, "0")), 2))
    }
}
