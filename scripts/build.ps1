param(
    [Parameter(Mandatory=$true)]
    [string]$ContainerFileFolder
)

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true
$ErrorActionPreference = "Stop"

# get the actual script path without the file
$SCRIPT_PATH = Split-Path -Parent $MyInvocation.MyCommand.Definition

# includes
. (Join-Path $SCRIPT_PATH ./env.ps1)
. (Join-Path $SCRIPT_PATH ./sec.ps1)

if (Test-Path $ContainerFileFolder) {
    $env:CONTAINER_IMAGE_NAME = Split-Path -Parent $ContainerFileFolder

    # read metadata
    $metadata = Get-Content -Path `
        (Join-Path $ContainerFileFolder args.json) `
            | ConvertFrom-Json

    $env:IMAGE_VERSION = $metadata.version
    $env:IMAGE_REGISTRY = $metadata.registry
    $env:IMAGE_NAME = $metadata.image

    foreach ($args in $metadata.machines) {
        Write-Host -ForegroundColor Yellow `
            "Building:"
        Write-Host -ForegroundColor Yellow `
            "`tImage: $($env:IMAGE_NAME)"
        Write-Host -ForegroundColor Yellow `
            "`tArch: $($args.IMAGE_ARCH)"
        Write-Host -ForegroundColor Yellow `
            "`tGPU: $($args.GPU)"

        docker compose `
            -f $ContainerFileFolder/docker-compose.yml `
            build `
            --pull `
            --build-arg IMAGE_ARCH=$($args.IMAGE_ARCH) `
            --build-arg BASE_REGISTRY=$($args.BASE_REGISTRY) `
            --build-arg BASE_IMAGE=$($args.BASE_IMAGE) `
            --build-arg BASE_VERSION=$($args.BASE_VERSION) `
            --build-arg GPU=$($args.GPU) `
            $env:IMAGE_NAME
    }
} else {
    Write-Host -ForegroundColor Red `
        "$ContainerFileFolder does not exists"
}
