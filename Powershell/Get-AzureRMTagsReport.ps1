Login-AzureRmAccount

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
    This cmdlet will get all your Tags in your subscription in a CSV.
.DESCRIPTION
    This cmdlet will get all your Tags in your subscription in a CSV.
.EXAMPLE
    PS C:\> Get-AzureRMReportTag

.NOTES
    This script is under MIT License.
    Made by Etienne Deneuve from Cellenza. etienne[at]deneuve.xyz
#>
Get-AzureRMReportTag
{
[CmdletBinding()]
param(
$filename = "$env:USERPROFILE\Desktop\Export-$(Get-Date -f "ddMMyyyy-HHmmss")-tag.csv" 
)
Check-AzureRMSession
$RGs = Get-AzureRmResourceGroup
$Resources = Get-AzureRmResource
foreach($rg in $RGs){
    $list = $Resources |Where-Object { $_.ResourceGroupName -eq $rg.ResourceGroupName }
    foreach($item in $list){
       $itemtag = $rgtag = $null
       $rgtag = $(
           foreach($tag in $($rg.Tags)){
                   if( [string]::IsNullOrEmpty($tag.Keys) -and [string]::IsNullOrEmpty($tag.Values) ){
                   "N/A"
                   }else{
                   "$($tag.Keys)=$($tag.Values)"
                   }
           }
           )
       $itemtag = $(
           foreach($tag in $($item.Tags)){
                   if( [string]::IsNullOrEmpty($tag.Keys) -and [string]::IsNullOrEmpty($tag.Values) ){
                    "N/A"
                   }else{
                    "$($tag.Keys)=$($tag.Values)"
                   }
           }
           )

        $item | Select-Object Name, ResourceGroupName, `
                @{Name="ResourceType";Expression={$(($item.ResourceType).Split("/")[-1])}},`
                @{Name="Tags";Expression={$itemtag}}, @{Name="ResourceGroupTags";Expression={$($rgtag)}} | `
                 Export-Csv -Path $filename -Encoding UTF8 -NoClobber -NoTypeInformation -Delimiter ";" -Append

    }
}
}
