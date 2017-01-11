<#
.SYNOPSIS
    This function let you choose the right subscription
.EXAMPLE
    C:\PS> Get-cAzureSubscription
    
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    This script is made for Azure Backup deployement
#>
Function Get-cAzureSubscription
{
    $ErrorActionPreference = "Stop"
    if(Get-cPowershellVersion -eq $false){
        Write-Host "Powershell is outdated !"
        break;
    } 
    #We surround the script by a Try/Catch to override the error display 
    #   time after we can manage the error to add autocorrection
    try {
        #First we need to connect to Azure's client portal
        $Login = Login-AzureRmAccount 
        if($Login){
            Write-Host `
                'Azure connected successfully' `
                -foreground Green
        }
        #We also need to check how many subscription we have
        #We need to check if they are Enabled too 
        $AzureSubscriptions = Get-AzureRmSubscription `
            | Where-Object{ $_.State -eq "Enabled" }
        
        #If we have more than 2 subscription we will show a dialogue
        if ($AzureSubscriptions.Count -gt 1 ) {
            
            #Let's display a quick sentence :-)
            Write-Host `
                'Select the subscription for the azure backup deployement' `
                -foreground Green
            
            #$x is a temp variable to get a counter in the foreach loop 
            $x = 1
            
            #Let's loop over the $AzureSubscriptions to get all showed
            foreach ($AzureSubscription in $AzureSubscriptions) {
                Write-Host "Subscription $($x) :`n"
                Write-Host "`t"$($AzureSubscription.SubscriptionName)
                Write-Host "`t"$($AzureSubscription.SubscriptionId)
                Write-Host "`t"$($AzureSubscription.TenantId)
                Write-Host "`n"
                $x++
            }
            
            #we add a control over the variable with [int] to be sure 
            # that you will input number,
            #   SubsChoice is shorten for readability and mean 
            #       Subscription Choice
            Write-Host `
                "What is the Id of the subscription?`n" -foreground Cyan
            [int]$SubsChoice = Read-Host 
            
            #We need to substract 1 to match the array wich start a 0
            $SubValue = $SubsChoice - 1

            #Let's store the Subscription object !
            $Subsription = $AzureSubscriptions.Item($SubValue)
        }
        else 
        {
            #If we have only one Subscription
            $Subsription = $AzureSubscriptions
        }
    }
    catch {
        Write-Host "Something went wrong :-("
    }
    finally{
        #Add a confirm, `t is to display a tabulation 
        Write-Host "Here is the Subscription choosed :`n" -foreground Yellow
        Write-Host "`t" $($Subsription.SubscriptionName)
        Write-Host "`t" $($Subsription.SubscriptionId)
        Write-Host "`t" $($Subsription.TenantId)
        
        Select-AzureRmSubscription `
                -SubscriptionName `
                    $($Subsription.SubscriptionName) `
                -TenantId `
                    $($Subsription.TenantId) | Out-Null
    }
}


<#
.SYNOPSIS
    Function to get Powershell Version 
.EXAMPLE
    C:\PS>Get-PowershellVersion
    True or False
.NOTES 
    This script is made for Azure Backup deployement
#>
function Get-cPowershellVersion {
    if($PSVersionTable.PSVersion -gt 3){
        return $true
    }else{
        return $false
    }    
}

