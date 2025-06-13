# Bootstrap-terminal.ps1
# Terminal Bootstrap Script → Install Git, clone terminal-profiles, download forensic tools.
# Logs run results to local log, and to Obsidian vault if present.

# Usage (put in your Obsidian note):
# $env:GITHUB_PAT='ghp_xxxxxx'; irm https://raw.githubusercontent.com/EDWARDO0/bootstrap-terminal/main/bootstrap.ps1 | iex

# --------------------
# Configuration
# --------------------

# Possible Obsidian Vault paths (update as needed)
$possibleVaultPaths = @(
    "C:\Users\meg.dva\OneDrive\Dokumenter\Obsidian Vault",           # Work PC with personal OneDrive
    "C:\Users\Micha\OneDrive\Obsidian Vault",                        # Private PC main
    "C:\Users\Micha\OneDrive\Dokumenter\Obsidian Vault"              # Private PC alt (Dokumenter version)
)

# Find first existing Obsidian vault path (if any)
$obsidianVaultPath = $null
foreach ($path in $possibleVaultPaths) {
    if (Test-Path $path) {
        $obsidianVaultPath = $path
        break
    }
}

# Local log path (always used)
$localLogFolder = "$env:USERPROFILE\Documents\bootstrap-logs"
$localLogPath = "$localLogFolder\terminal-logs.md"

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

function Log-Content {
    param([string]$text)

    # Always log locally
    Add-Content -Path $localLogPath -Value $text

    # If Obsidian vault exists → also log there
    if ($obsidianVaultPath) {
        $obsidianLogPath = "$obsidianVaultPath\terminal-logs.md"
        Add-Content -Path $obsidianLogPath -Value $text
    }
}

function Install-GitIfMissing {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "[*] Git not found → Installing Git for Windows..." -ForegroundColor Yellow
        $gitInstaller = "$env:TEMP\Git-Setup.exe"
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/latest/download/Git-2.44.0-64-bit.exe" -OutFile $gitInstaller
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT" -Wait
        Remove-Item $gitInstaller
        Write-Host "[+] Git installed." -ForegroundColor Green
        Log-Content "- Install-GitIfMissing: SUCCESS`n"
    } else {
        Write-Host "[+] Git already installed." -ForegroundColor Green
        Log-Content "- Install-GitIfMissing: ALREADY INSTALLED`n"
    }
}

function Clone-TerminalProfiles {
    if (-not $env:GITHUB_PAT) {
        Write-Error "ERROR: GITHUB_PAT environment variable not set. Please set it first."
        Log-Content "- Clone-TerminalProfiles: ERROR → GITHUB_PAT not set`n"
        exit 1
    }

    if (-not (Test-Path $TargetProfilePath)) {
        Write-Host "[*] Cloning terminal-profiles repo..." -ForegroundColor Yellow
        git clone https://EDWARDO0:$env:GITHUB_PAT@github.com/EDWARDO0/terminal-profiles.git $TargetProfilePath
        Log-Content "- Clone-TerminalProfiles: SUCCESS → Cloned new`n"
    } else {
        Write-Host "[+] Repo already exists → Pulling latest changes..." -ForegroundColor Green
        cd $TargetProfilePath
        git pull
        Log-Content "- Clone-TerminalProfiles: SUCCESS → Pulled latest`n"
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
    Log-Content "- Link-PowerShellProfile: SUCCESS`n"
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
    Log-Content "- Sysinternals Suite: SUCCESS`n"

    # WinDump
    Write-Host "[*] Downloading WinDump..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $WinDumpURL -OutFile "$ToolsPath\windump.exe"
    Write-Host "[+] WinDump ready." -ForegroundColor Green
    Log-Content "- WinDump: SUCCESS`n"

    # Manual tools
    Write-Host "[*] NOTE: For GMER, WinPEAS, Seatbelt → please download manually as needed." -ForegroundColor Cyan
    Log-Content "- Manual tools (GMER / WinPEAS / Seatbelt): MANUAL STEP`n"
}

# --------------------
# Main Execution Flow
# --------------------

# Ensure local log folder exists
if (-not (Test-Path $localLogFolder)) {
    New-Item -ItemType Directory -Path $localLogFolder | Out-Null
}

# Log header
Log-Content "### 🚀 Bootstrap Run - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"

Write-Host "`n===== 🚀 Terminal Bootstrap Starting =====" -ForegroundColor Cyan

Install-GitIfMissing
Clone-TerminalProfiles
Link-PowerShellProfile
Download-Tools

Write-Host "`n===== ✅ Terminal Bootstrap Complete! =====" -ForegroundColor Green
Write-Host "Tools available at: $ToolsPath" -ForegroundColor Cyan
Write-Host "PowerShell profile linked: $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -ForegroundColor Cyan

# Log footer
Log-Content "---`n"
