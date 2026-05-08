# HANA Insight Windows Server Setup Script

Automated Windows setup script for provisioning the HANA Insight stack on a fresh Windows machine.
This script installs and configures the required development/runtime dependencies and clones the project repositories automatically. 

---

# Features

* Installs:

  * Git
  * Node.js LTS
  * PM2
  * PostgreSQL 18
  * Nginx
* Generates SSH key for GitHub authentication
* Opens GitHub SSH settings automatically
* Verifies GitHub SSH connectivity
* Creates project directory structure
* Clones backend, frontend, and updater repositories
* Adds PostgreSQL to system PATH
* Logs full setup output to a file
* Includes fail-fast error handling with stack traces

---

# Project Structure

After setup:

```txt
C:\apps\insight\
├── backend/            # hana-insight (Express/Node.js)
├── frontend/           # hana-insight-ui (React/TypeScript)
└── semi-auto-update/   # hi-semi-auto-update utility
```

---

# Requirements

* Windows 10/11
* Run installer with Administrator privileges
* Internet connection
* GitHub account access to private repositories

---

# Installed Components

| Component     | Installation Method |
| ------------- | ------------------- |
| Git           | winget              |
| Node.js LTS   | winget              |
| PM2           | npm                 |
| PostgreSQL 18 | Direct installer    |
| Nginx         | ZIP extraction      |

---

# Usage

## 1. Download Files

Ensure both files exist in the same directory:

```txt
setup-server.ps1
run-setup.bat
```

---

## 2. Run Setup

Right click:

```txt
run-setup.bat
```

Then select:

```txt
Run as administrator
```

---

## 3. What the BAT File Does

The batch file launches PowerShell with execution policy bypass enabled automatically.

So manual PowerShell execution is no longer required.

---

## 4. Setup Starts Automatically

The installer will:

* Install required software
* Configure environment variables
* Generate SSH keys
* Clone repositories
* Verify installations

Just follow the prompts shown in the terminal window.

---

# During Setup

The script will ask for:

## PostgreSQL Password

```txt
Enter postgres password [default: postgres]
```

If left blank:

```txt
postgres
```

will be used.

---

## SSH Key Label

Example:

```txt
testServerName
```

The script will:

* Generate SSH key
* Show public key
* Open GitHub SSH settings page
* Pause until key is added

GitHub SSH settings:

[GitHub SSH Keys](https://github.com/settings/keys)

---

# Installed Locations

| Component          | Location                             |
| ------------------ | ------------------------------------ |
| App Base Directory | `C:\apps\insight`                    |
| Nginx              | `C:\nginx`                           |
| PostgreSQL Bin     | `C:\Program Files\PostgreSQL\18\bin` |
| Setup Log          | `C:\setup-log.txt`                   |

---

# Repositories Cloned

| Repository          | Directory          |
| ------------------- | ------------------ |
| hana-insight        | `backend`          |
| hana-insight-ui     | `frontend`         |
| hi-semi-auto-update | `semi-auto-update` |

---

# PATH Updates

The script permanently adds PostgreSQL binaries to the system PATH.

---

# Verification Commands

The script automatically verifies:

```powershell
git --version
node -v
npm -v
pm2 -v
psql --version
nginx -v
```

---

# Logging

Full setup logs are stored at:

```txt
C:\setup-log.txt
```

Useful for debugging failed installations.

---

# Error Handling

The script includes:

* Immediate failure on errors
* Installer exit code validation
* Stack traces
* Full PowerShell exception output

---

# Notes

## Winget Required

The script depends on:

```txt
winget
```

Ensure App Installer is available on Windows.

---

## GitHub SSH Authentication

Private repositories require properly configured SSH access.

You can test manually:

```powershell
ssh -T git@github.com
```

---

# Security Notes

* PostgreSQL password is entered interactively
* SSH keys are generated locally
* Script should be reviewed before running in production environments

---

# Future Improvements

Potential additions:

* Automatic PM2 startup service
* Nginx service registration
* PostgreSQL database bootstrap
* Environment variable templating
* SSL setup
* Windows service wrappers
* Health checks
* Automated app deployment after clone

---

# Troubleshooting

## `winget` not found

Install:

[Microsoft App Installer](https://apps.microsoft.com/detail/9nblggh4nns1?utm_source=chatgpt.com)

---

## `psql not recognized`

Restart PowerShell after installation.

Or verify PATH contains:

```txt
C:\Program Files\PostgreSQL\18\bin
```

---

## GitHub Permission Denied

Verify:

```powershell
ssh -T git@github.com
```

And ensure SSH public key was added correctly.

---

# License

Internal company setup utility.