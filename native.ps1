param (
    [string]$Docker = "docker",
    [string]$DockerFile = "./Dockerfile",
    [string]$Version = "",
    [string]$ExeOpts = "",
    [string]$DllOpts = "",
    [string]$LibOpts = ""
)

$Branch = "develop"

if ($Version -ne "") {
    $Branch = "v$Version"
}

Write-Host "Docker     ""$Docker"""
Write-Host "DockerFile ""$DockerFile"""
Write-Host "Version    ""$Version"""
Write-Host "Branch     ""$Branch"""
Write-Host "ExeOpts    ""$ExeOpts"""
Write-Host "DllOpts    ""$DllOpts"""
Write-Host "LibOpts    ""$LibOpts"""

& $Docker build -t winbqn -f $DockerFile . `
    --build-arg NATIVE=1 `
    --build-arg VERSION=$Version `
    --build-arg BRANCH=$Branch `
    --build-arg EXE_OPTS=$ExeOpts `
    --build-arg DLL_OPTS=$DllOpts `
    --build-arg LIB_OPTS=$LibOpts `
    --build-arg CACHEBUST=$(Get-Date)

& $Docker create --name build winbqn
& $Docker cp build:/build/out/bqn.zip bqn-native.zip
& $Docker rm build
& $Docker rmi winbqn
