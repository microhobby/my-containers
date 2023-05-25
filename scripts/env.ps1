
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = "Stop"

function Env {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$Default
    )

    # check if the environment variable exists
    if (Test-Path env:$Name) {
        # return the value of the environment variable
        return (Get-Item env:$Name).Value
    } else {
        # return default
        return $Default
    }
}
