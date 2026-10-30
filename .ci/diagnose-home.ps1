param(
    [string]$Destination = 'C:/'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$root = Join-Path $Destination 'msys64'
$bash = Join-Path $root 'usr/bin/bash.exe'
$probe = Join-Path $PSScriptRoot 'home-probe.sh'

function Show-NativeHome([string]$Stage) {
    Write-Host "`n=== $Stage (Windows) ==="
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    Write-Host "Account=$($identity.Name); SID=$($identity.User.Value)"
    Write-Host "PowerShell HOME=$HOME; exists=$(Test-Path -LiteralPath $HOME -PathType Container)"
    foreach ($name in 'HOME', 'USERPROFILE', 'HOMEDRIVE', 'HOMEPATH', 'USERNAME', 'MSYSTEM') {
        $value = [Environment]::GetEnvironmentVariable($name, 'Process')
        Write-Host "${name}=$value"
    }
    if ($env:HOME) {
        Write-Host "Environment HOME exists=$(Test-Path -LiteralPath $env:HOME -PathType Container)"
    }
    Write-Host "MSYS root exists=$(Test-Path -LiteralPath $root -PathType Container)"
    $homeRoot = Join-Path $root 'home'
    if (Test-Path -LiteralPath $homeRoot) {
        Get-ChildItem -LiteralPath $homeRoot -Force | Select-Object Name, CreationTimeUtc
    }
}

function Invoke-HomeProbe([string]$Stage, [string[]]$ShellOptions) {
    Show-NativeHome $Stage
    & $bash @ShellOptions -c '. "$1" "$2"' home-probe $probe $Stage
    if ($LASTEXITCODE -ne 0) { throw "Bash probe failed: $Stage ($LASTEXITCODE)" }
}

Show-NativeHome 'before-extraction'
& (Join-Path $PSScriptRoot 'msys2.exe') -y "-o$Destination"
if ($LASTEXITCODE -ne 0) { throw "SFX extraction failed ($LASTEXITCODE)" }
Show-NativeHome 'after-extraction-before-any-bash'

Invoke-HomeProbe 'before-first-login' @('--noprofile', '--norc')
$inheritedHome = $env:HOME
try {
    $env:HOME = $null
    Invoke-HomeProbe 'without-inherited-HOME-before-first-login' @('--noprofile', '--norc')
} finally {
    $env:HOME = $inheritedHome
}

Invoke-HomeProbe 'first-login' @('-l')
Invoke-HomeProbe 'after-first-login-non-login' @('--noprofile', '--norc')
Invoke-HomeProbe 'second-login' @('-l')
Show-NativeHome 'finished'
