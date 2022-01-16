
#$env:CONTAINER_RUNTIME="podman"
$CONTAINER_RUNTIME="docker"
$IMAGE_REPO="matheuscastello"

$CONTAINER_FOLDER = $args[0]
$CMD = $args[1]

if (Test-Path $CONTAINER_FOLDER) {
    $CONTAINER_IMAGE_NAME=$CONTAINER_FOLDER.ToString().Replace("./", "").Replace("/", "")

    switch ($CMD) {
        "run" {
            $CONTAINER_ARGS = $(cat $CONTAINER_FOLDER/args)

            Invoke-Expression `
                "$CONTAINER_RUNTIME run $CONTAINER_ARGS $IMAGE_REPO/$CONTAINER_IMAGE_NAME"
        }
        "build" {
            & $CONTAINER_RUNTIME `
                build `
                -f $CONTAINER_FOLDER/Containerfile $CONTAINER_FOLDER `
                -t $IMAGE_REPO/$CONTAINER_IMAGE_NAME
        }
        Default {
            Write-Host -ForegroundColor Red `
                "CMD not found (must be run or build)"
        }
    }
} else {
    Write-Host -ForegroundColor Red `
        "$CONTAINER_FOLDER does not exist (must be a valid ./<folder>)"
}
