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

# firts of all we need to run torizon/binfmt
# to enable qemu for arm64 and arm32
docker run --rm --privileged torizon/binfmt
DockerRegistryLogin
GhrcRegistryLogin
GithubAuth

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
        $env:BASE_REGISTRY = $args.BASE_REGISTRY
        $env:BASE_IMAGE = $args.BASE_IMAGE
        $env:BASE_VERSION = $args.BASE_VERSION
        $env:GPU = $args.GPU

        Write-Host -ForegroundColor Yellow `
            "Building:"
        Write-Host -ForegroundColor Yellow `
            "`tImage: $($env:IMAGE_REGISTRY)$($env:IMAGE_NAME):$($env:IMAGE_VERSION)"
        Write-Host -ForegroundColor Yellow `
            "`tImage Base: $($env:BASE_REGISTRY)$($env:BASE_IMAGE)$($env:GPU):$($env:BASE_VERSION)"
        Write-Host -ForegroundColor Yellow `
            "`tGPU: $($args.GPU)"

        $_archs = ""
        foreach ($arch in $args.arch) {
            Write-Host -ForegroundColor Yellow `
                "`tArch: $arch"

            if ($_archs -ne "") { 
                $_archs = "$_archs,linux/$arch"
            } else {
                $_archs = "linux/$arch"
            }
        }

        docker buildx bake `
            -f $ContainerFileFolder/docker-compose.yml `
            --set *.platform=$_archs `
            --push
        
    }
} else {
    Write-Host -ForegroundColor Red `
        "$ContainerFileFolder does not exists"
}
