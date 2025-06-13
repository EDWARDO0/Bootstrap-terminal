# Bootstrap-terminal.ps1
# 🚀 Terminal Bootstrap Script → Install Git, clone terminal-profiles, download forensic tools.

# Usage (put in your Obsidian note):
# $env:GITHUB_PAT='ghp_xxxxxx'; irm https://raw.githubusercontent.com/EDWARDO0/bootstrap-terminal/main/bootstrap.ps1 | iex

# --------------------
# Configuration
# --------------------

# GitHub Repo
$RepoURL = "https://github.com/EDWARDO0/terminal-profiles.git"

# Target Paths
$TargetProfilePath = "$env:USERPROFILE\Documents\GitHub\terminal-profiles"
$ToolsPath = "$env:USERPROFILE\Tools"
$SysinternalsURL = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
$WinDumpURL = "https://www.winpcap.org/windump/install/bin/windump.exe"

# --------------------
# Functions
# --------------------

function Install-GitIfMissing {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "[*] Git not found → Installing Git for Windows..." -ForegroundColor Yellow
        $gitInstaller = "$env:TEMP\Git-Setup.exe"
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/latest/download/Git-2.44.0-64-bit.exe" -OutFile $gitInstaller
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT" -Wait
        Remove-Item $gitInstaller
        Write-Host "[+] Git installed." -ForegroundColor Green
    } else {
        Write-Host "[+] Git already installed." -ForegroundColor Green
    }
}

function Clone-TerminalProfiles {
    if (-not $env:GITHUB_PAT) {
        Write-Error "ERROR: GITHUB_PAT environment variable not set. Please set it first."
        exit 1
    }

    if (-not (Test-Path $TargetProfilePath)) {
        Write-Host "[*] Cloning terminal-profiles repo..." -ForegroundColor Yellow
        git clone https://EDWARDO0:$env:GITHUB_PAT@github.com/EDWARDO0/terminal-profiles.git $TargetProfilePath
    } else {
        Write-Host "[+] Repo already exists → Pulling latest changes..." -ForegroundColor Green
        cd $TargetProfilePath
        git pull
    }
}

function Link-PowerShellProfile {
    $PSProfileSource = "$TargetProfilePath\powershell\Microsoft.PowerShell_profile.ps1"
    $PSProfileTarget = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

    if (Test-Path $PSProfileTarget) {
        Write-Host "[*] Existing PowerShell profile found → Backing up..." -ForegroundColor Yellow
        Copy-Item $PSProfileTarget "$PSProfileTarget.bak" -Force
    }

    Write-Host "[*] Linking PowerShell profile..." -ForegroundColor Yellow
    Copy-Item $PSProfileSource $PSProfileTarget -Force
    Write-Host "[+] PowerShell profile linked." -ForegroundColor Green
}

function Download-Tools {
    Write-Host "[*] Preparing Tools directory..." -ForegroundColor Yellow
    if (-not (Test-Path $ToolsPath)) {
        New-Item -ItemType Directory -Path $ToolsPath | Out-Null
    }

    # Sysinternals Suite
    Write-Host "[*] Downloading Sysinternals Suite..." -ForegroundColor Yellow
    $sysinternalsZip = "$ToolsPath\SysinternalsSuite.zip"
    Invoke-WebRequest -Uri $SysinternalsURL -OutFile $sysinternalsZip
    Expand-Archive -Path $sysinternalsZip -DestinationPath "$ToolsPath\SysinternalsSuite" -Force
    Remove-Item $sysinternalsZip
    Write-Host "[+] Sysinternals Suite ready." -ForegroundColor Green

    # WinDump
    Write-Host "[*] Downloading WinDump..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $WinDumpURL -OutFile "$ToolsPath\windump.exe"
    Write-Host "[+] WinDump ready." -ForegroundColor Green

    # Manual tools
    Write-Host "[*] NOTE: For GMER, WinPEAS, Seatbelt → please download manually as needed." -ForegroundColor Cyan
}

# --------------------
# Main Execution Flow
# --------------------

Write-Host "`n===== 🚀 Terminal Bootstrap Starting =====" -ForegroundColor Cyan

Install-GitIfMissing
Clone-TerminalProfiles
Link-PowerShellProfile
Download-Tools

Write-Host "`n===== ✅ Terminal Bootstrap Complete! =====" -ForegroundColor Green
Write-Host "Tools available at: $ToolsPath" -ForegroundColor Cyan
Write-Host "PowerShell profile linked: $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -ForegroundColor Cyan
