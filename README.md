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

1️⃣ **Set your GitHub PAT as environment variable (required for private repo access)**:

```powershell
$env:GITHUB_PAT='ghp_xxxxxx'
2️⃣ Run the bootstrap script in one line:

powershell
Copy
Edit
$env:GITHUB_PAT='ghp_xxxxxx'; irm https://raw.githubusercontent.com/EDWARDO0/bootstrap-terminal/main/bootstrap.ps1 | iex
Tools Included
Tool	Purpose	Source
Sysinternals Suite	Core troubleshooting & forensic tools	Microsoft Sysinternals
WinDump	Windows packet capture CLI	WinDump.org
(Manual) GMER	Rootkit detection	GMER (manual download recommended)
(Manual) WinPEAS / Seatbelt	Windows enumeration / hardening checks	GitHub (manual download recommended)

Structure
text
Copy
Edit
bootstrap-terminal/
├── bootstrap.ps1        ← Main bootstrap script
├── README.md            ← This file
└── tools/               ← (Optional folder for extra scripts if needed)
Notes
The bootstrap script does not hardcode your PAT — you must set $env:GITHUB_PAT before running.

Never commit your PAT to GitHub.

Manual tools (WinPEAS, GMER, Seatbelt) are not auto-downloaded to avoid triggering GitHub security policies — download separately as needed.

Expand Download-Tools function to add more tools in the future.

