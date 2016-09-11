﻿<#
.Synopsis
    Waits for Azure PIR to complete replication of VM extension

.Usage
    WaitForExtensionReplication.ps1 -extensionName ReleaseManagement1 -publisher Test.Microsoft.VisualStudio.Services -extensionVersion 1.9.0.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$extensionName,

    [Parameter(Mandatory=$true)]
    [string]$publisher,

    [Parameter(Mandatory=$true)]
    [string]$extensionVersion
)

function isReplicationComplete
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$replicationStatusList
    )

    $isReplicationCompleted = $true
    $replicationStatusList.ReplicationStatusList.ReplicationStatus | % {
        Write-Host "$_.Location : $_.Status"
        if($_.Status -ne "Completed")
        {
            $isReplicationCompleted = $false
            break
        }
    }

    return $isReplicationCompleted
}

if($extensionVersion -eq "WILL_BET_SET_AT_RUNTIME")
{
    return
}

$retryCount = 0
$isReplicated = $false

# retry after every 60 seconds
$retryInterval = 120

# maximum number of retries to attempt
$maxRetries = 30

# fetch subscription details - subscription id and management certificate
$subscription = Get-AzureSubscription -Current –ExtendedDetails
$subscription.Certificate.Thumbprint

$uri = "https://management.core.windows.net/$($subscription.SubscriptionId)/services/extensions/$publisher/$extensionName/$extensionVersion/replicationstatus"
Write-Host "uri: $uri"

do
{
  Start-Sleep -s $retryInterval
  
  # invoke GET rest api to get status of extension replication
  $relicationStatusList = Invoke-RestMethod -Method GET -Uri $uri -Certificate $subscription.Certificate -Headers @{'x-ms-version'='2014-08-01'}
  $isReplicated = isReplicationComplete $replicationStatusList
  
  if($isReplicated -ne $true)
  {
    Write-Host "Extension is not yet replicated. Will retry after $retryInterval seconds"
    $retryCount++
  }

} While (($isReplicated -ne $true) -and ($retryCount -lt $maxRetries))