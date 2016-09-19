﻿<#
.Synopsis
    This script will disable RM extension. 
    
    Currently, disable is no-op for team services agent. It will still keep running and will still be registered to machine group.
    The purpose here is to just inform user about this.
#>

$ErrorActionPreference = 'stop'
Set-StrictMode -Version latest

if (!(Test-Path variable:PSScriptRoot) -or !($PSScriptRoot)) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}

Import-Module $PSScriptRoot\AzureExtensionHandler.psm1
Import-Module $PSScriptRoot\RMExtensionStatus.psm1
Import-Module $PSScriptRoot\Log.psm1

Initialize-ExtensionLogFile
Write-Log "Disable command is no-op for agent"

Write-Log "Disabling extension handler. Creating a markup file.."
Set-ExtensionDisabledMarkup

Add-HandlerSubStatus $RM_Extension_Status.Disabled.Code $RM_Extension_Status.Disabled.Message -operationName $RM_Extension_Status.Disabled.operationName
Set-HandlerStatus $RM_Extension_Status.Disabled.Code $RM_Extension_Status.Disabled.Message -Status success