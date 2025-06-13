# Bootstrap-terminal.ps1
# Terminal Bootstrap Script → Install Git, clone terminal-profiles, download forensic tools.
# Logs run results to local log, and to Obsidian vault if present.

# Usage:
# $env:GITHUB_PAT='ghp_xxxxxx'; irm https://raw.githubusercontent.com/EDWARDO0/Bootstrap-terminal/main/bootstrap.ps1 | iex

# --------------------
# Configuration
# --------------------

# Possible Obsidian Vault paths
$possibleVaultPaths = @(
    "C:\Users\meg.dva\OneDrive\Dokumenter\Obsidian Vault",
    "C:\Users\Micha\OneDrive\Obsidian Vault",
    "C:\Users\Micha\OneDrive\Dokumenter\Obsidian Vault"
)

# Detect Obsidian vault path
$obsidianVaultPath = $null
foreach ($path in $possibleVaultPaths) {
    if (Test-Path $path) {
        $obsidianVaultPath = $path
        break
    }
}

# Local log path
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

    Add-Content -Path $localLogPath -Value $text

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
        Write-Host "[+] Git installer finished." -ForegroundColor Green

        # Wait until Git is available
        $gitReady = $false
        for ($i = 0; $i -lt 10; $i++) {
            Start-Sleep -Seconds 2
            if (Get-Command git -ErrorAction SilentlyContinue) {
                $gitReady = $true
                break
            } else {
                Write-Host "[*] Waiting for Git to become available... ($($i+1)/10)" -ForegroundColor Yellow
            }
        }

        if ($gitReady) {
            Write-Host "[+] Git is ready to use." -ForegroundColor Green
            Log-Content "- Install-GitIfMissing: SUCCESS`n"
        } else {
            Write-Error "Git installation completed but git.exe is not available. Please restart PowerShell and run the script again."
            Log-Content "- Install-GitIfMissing: FAILED → git.exe not available`n"
            exit 1
        }
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
        if ($LASTEXITCODE -eq 0) {
            Log-Content "- Clone-TerminalProfiles: SUCCESS → Cloned new`n"
        } else {
            Write-Error "Git clone failed."
            Log-Content "- Clone-TerminalProfiles: FAILED → git clone failed`n"
            exit 1
        }
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

    if (Test-Path $PSProfileSource) {
        if (Test-Path $PSProfileTarget) {
            Write-Host "[*] Existing PowerShell profile found → Backing up..." -ForegroundColor Yellow
            Copy-Item $PSProfileTarget "$PSProfileTarget.bak" -Force
        }

        Write-Host "[*] Linking PowerShell profile..." -ForegroundColor Yellow
        Copy-Item $PSProfileSource $PSProfileTarget -Force
        Write-Host "[+] PowerShell profile linked." -ForegroundColor Green
        Log-Content "- Link-PowerShellProfile: SUCCESS`n"
    } else {
        Write-Error "PowerShell profile file not found → skipping link."
        Log-Content "- Link-PowerShellProfile: SKIPPED → profile not found`n"
    }
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

    Write-Host "[*] NOTE: For GMER, WinPEAS, Seatbelt → please download manually*]()
