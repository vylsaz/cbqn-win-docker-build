param (
    [string]$Version = "",
    [string]$DockerFile = "./Dockerfile",
    [string]$ExeOpts = "",
    [string]$DllOpts = "",
    [string]$LibOpts = ""
)

$Branch = "develop"

if ($Version -ne "") {
    $Branch = "v$Version"
}

Write-Host "Version    ""$Version"""
Write-Host "Branch     ""$Branch"""
Write-Host "DockerFile ""$DockerFile"""
Write-Host "ExeOpts    ""$ExeOpts"""
Write-Host "DllOpts    ""$DllOpts"""
Write-Host "LibOpts    ""$LibOpts"""

docker build -t winbqn -f $DockerFile . `
    --build-arg NATIVE=1 `
    --build-arg VERSION=$Version `
    --build-arg BRANCH=$Branch `
    --build-arg EXE_OPTS=$ExeOpts `
    --build-arg DLL_OPTS=$DllOpts `
    --build-arg LIB_OPTS=$LibOpts `
    --build-arg CACHEBUST=$(Get-Date)

docker create --name build winbqn
docker cp build:/build/out/bqn.zip bqn-native.zip
docker rm build
docker rmi winbqn
