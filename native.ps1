param (
    [string]$Version,
    [string]$DockerFile = "./Dockerfile"
)

$Branch = "develop"

if ($Version -ne "") {
    $Branch = "v$Version"
}

Write-Host "Version    ""$Version"""
Write-Host "Branch     ""$Branch"""
Write-Host "DockerFile ""$DockerFile"""

docker build -t winbqn -f $DockerFile . `
    --build-arg NATIVE=1 `
    --build-arg VERSION=$Version `
    --build-arg BRANCH=$Branch `
    --build-arg CACHEBUST=$(Get-Date)

docker create --name build winbqn
docker cp build:/build/out/bqn.zip bqn-native.zip
docker rm build
docker rmi winbqn
