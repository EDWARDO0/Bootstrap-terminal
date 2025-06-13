# Bootstrap Terminal

**Purpose:**  
Quickly bootstrap a Windows machine for terminal use, security investigation, and PowerShell profile setup.

---

## Features

✅ Install Git (if missing)  
✅ Clone your `terminal-profiles` repo  
✅ Link PowerShell profile automatically  
✅ Download key forensic & security tools  
✅ Fully automated → supports one-liner bootstrap  
✅ No sensitive data stored in the repo (uses `$env:GITHUB_PAT`)

---

## Usage

**Set your GitHub PAT as environment variable (required for private repo access)**:

```powershell
$env:GITHUB_PAT='ghp_xxxxxx'

**Run the bootstrap script in one line:**

$env:GITHUB_PAT='ghp_xxxxxx'; irm https://raw.githubusercontent.com/EDWARDO0/bootstrap-terminal/main/bootstrap.ps1 | iex
