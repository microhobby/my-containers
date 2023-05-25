
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = "Stop"

# get the actual script path without the file
$SCRIPT_PATH = Split-Path -Parent $MyInvocation.MyCommand.Definition

# includes
. (Join-Path $SCRIPT_PATH ./env.ps1)

function Get-Sec {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    return Env -Name $Name -Default `
        (Get-Content -Path `
            (Join-Path $SCRIPT_PATH ../.sec/$Name))
}

function GhrcRegistryLogin {
    $REGISTRY_USERNAME = `
        Env -Name "REGISTRY_USERNAME" -Default "matheuscastello"
    $REGISTRY_PASSWORD = (Get-Sec -Name "github_token")

    Write-Output $REGISTRY_PASSWORD | `
        docker login ghcr.io -u $REGISTRY_USERNAME --password-stdin
}
