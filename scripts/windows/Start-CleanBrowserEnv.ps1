param(
    [ValidateSet("Start", "Fingerprint", "Doctor", "List", "Cleanup")]
    [string]$Action = "Start",

    [ValidateSet("Auto", "Chrome", "Edge", "Firefox")]
    [string]$Browser = "Auto",

    [string]$Url = "about:blank",

    [switch]$Yes
)

$ErrorActionPreference = "Stop"
$AppHome = if ($env:CLEAN_ENV_HOME) { $env:CLEAN_ENV_HOME } else { Join-Path $env:USERPROFILE "CleanBrowserEnv" }
$ProfileRoot = Join-Path $AppHome "profiles"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$FingerprintPage = if ($env:CLEAN_ENV_FINGERPRINT_PAGE) { $env:CLEAN_ENV_FINGERPRINT_PAGE } else { Join-Path $ProjectRoot "assets\fingerprint-test.html" }

function Write-Log {
    param([string]$Message)
    Write-Host "==> $Message"
}

function Get-BrowserPath {
    param([string]$Name)

    $candidates = @()
    switch ($Name) {
        "Chrome" {
            $candidates = @(
                "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
                "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
                "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
            )
        }
        "Edge" {
            $candidates = @(
                "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
                "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
                "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe"
            )
        }
        "Firefox" {
            $candidates = @(
                "$env:ProgramFiles\Mozilla Firefox\firefox.exe",
                "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe"
            )
        }
    }

    foreach ($path in $candidates) {
        if ($path -and (Test-Path $path)) {
            return $path
        }
    }
    return $null
}

function Resolve-Browser {
    param([string]$Requested)

    if ($Requested -ne "Auto") {
        $path = Get-BrowserPath $Requested
        if (-not $path) {
            throw "未找到浏览器: $Requested"
        }
        return @{ Name = $Requested; Path = $path }
    }

    foreach ($name in @("Chrome", "Edge", "Firefox")) {
        $path = Get-BrowserPath $name
        if ($path) {
            return @{ Name = $name; Path = $path }
        }
    }
    throw "未找到 Chrome / Edge / Firefox，请先安装其中一个浏览器"
}

function New-ProfileDir {
    New-Item -ItemType Directory -Force -Path $ProfileRoot | Out-Null
    $id = Get-Date -Format "yyyyMMdd-HHmmss"
    $profile = Join-Path $ProfileRoot "session-$id"
    New-Item -ItemType Directory -Force -Path $profile | Out-Null
    return $profile
}

function Start-CleanEnv {
    param([string]$StartUrl = $Url)

    $resolved = Resolve-Browser $Browser
    $profile = New-ProfileDir
    $metadata = @(
        "created_at=$(Get-Date -Format o)"
        "browser=$($resolved.Name)"
        "url=$StartUrl"
    )
    Set-Content -Path (Join-Path $profile "metadata.txt") -Value $metadata -Encoding UTF8

    Write-Log "Profile: $profile"
    Write-Log "Browser: $($resolved.Name)"

    if ($resolved.Name -eq "Firefox") {
        $args = @("-profile", $profile, "-no-remote", "-new-instance", $StartUrl)
    } else {
        $args = @("--user-data-dir=$profile", "--no-first-run", "--disable-sync", "--disable-extensions", "--new-window", $StartUrl)
    }
    Start-Process -FilePath $resolved.Path -ArgumentList $args
    Write-Log "已启动。原有浏览器资料不会被修改。"
}

function Start-FingerprintTest {
    if (-not (Test-Path $FingerprintPage)) {
        throw "未找到指纹测试页: $FingerprintPage"
    }
    Write-Log "打开本地指纹测试页"
    Start-CleanEnv -StartUrl $FingerprintPage
}

function Show-Doctor {
    Write-Log "Home: $AppHome"
    Write-Log "OS: Windows"
    foreach ($name in @("Chrome", "Edge", "Firefox")) {
        $path = Get-BrowserPath $name
        if ($path) {
            Write-Host ("  {0,-8} OK    {1}" -f $name, $path)
        } else {
            Write-Host ("  {0,-8} not found" -f $name)
        }
    }
}

function Show-Profiles {
    if (-not (Test-Path $ProfileRoot)) {
        Write-Log "暂无临时 Profile"
        return
    }
    Get-ChildItem -Path $ProfileRoot -Directory -Filter "session-*" | Sort-Object Name | ForEach-Object {
        Write-Host $_.FullName
    }
}

function Clear-Profiles {
    if (-not (Test-Path $ProfileRoot)) {
        Write-Log "无需清理"
        return
    }

    $profiles = @(Get-ChildItem -Path $ProfileRoot -Directory -Filter "session-*")
    if ($profiles.Count -eq 0) {
        Write-Log "无需清理"
        return
    }

    $profiles | ForEach-Object { Write-Host $_.FullName }
    if (-not $Yes) {
        $answer = Read-Host "只会删除上面这些临时 Profile，继续请输入 YES"
        if ($answer -ne "YES") {
            throw "已取消"
        }
    }

    $profiles | Remove-Item -Recurse -Force
    Write-Log "清理完成"
}

switch ($Action) {
    "Start" { Start-CleanEnv }
    "Fingerprint" { Start-FingerprintTest }
    "Doctor" { Show-Doctor }
    "List" { Show-Profiles }
    "Cleanup" { Clear-Profiles }
}
