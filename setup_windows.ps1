<#
============================================================
  Coinmania - AI Training Setup Script (Windows)
  Installs all required apps and CLI tools for the training.

  How to run: double-click install_windows.bat
  (this script self-elevates via a UAC prompt)

  Note: this window shows English text only. The full
  Georgian guide is on the website.
============================================================
#>

# --- Self-elevate to Administrator (fixes "closes on launch" when not admin) ---
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        if ([string]::IsNullOrEmpty($PSCommandPath)) {
            # Launched from the web (irm | iex) - re-run elevated by re-fetching
            Start-Process powershell.exe -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-Command',"iex (irm 'https://coinmania-ai-pulse-training.vercel.app/setup_windows.ps1')")
        } else {
            # Launched from a file - re-run the same file elevated
            Start-Process powershell.exe -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
        }
    } catch {
        Write-Host ""
        Write-Host "  [!] Administrator rights are required. Please accept the UAC prompt." -ForegroundColor Red
        Read-Host "  Press Enter to exit"
    }
    exit
}

# --- Config ---
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# --- Helpers ---
function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "  >> $Message" -ForegroundColor Cyan
    Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray
}
function Write-Success { param([string]$Message) Write-Host "     [OK] $Message" -ForegroundColor Green }
function Write-Warn    { param([string]$Message) Write-Host "     [!]  $Message" -ForegroundColor Yellow }
function Write-Info    { param([string]$Message) Write-Host "     [..] $Message" -ForegroundColor Gray }
function Test-Cmd      { param([string]$C) $null -ne (Get-Command $C -ErrorAction SilentlyContinue) }

# --- Header ---
Clear-Host
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Magenta
Write-Host "     Coinmania - AI Training Setup" -ForegroundColor Magenta
Write-Host "     Automatic installer" -ForegroundColor Magenta
Write-Host "  ============================================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "  This will install:" -ForegroundColor White
Write-Host "    - Developer Mode, WSL2, Hyper-V" -ForegroundColor Gray
Write-Host "    - Git, Node.js, VS Code, Cursor, Claude Desktop, ChatGPT, Obsidian" -ForegroundColor Gray
Write-Host "    - Claude Code CLI, Codex CLI, Grok CLI, Antigravity CLI" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "  Start installation? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') { Write-Host "  Cancelled." -ForegroundColor Yellow; exit 0 }

$needsRestart = $false

# ============================================================
# STEP 1: DEVELOPER MODE
# ============================================================
Write-Step "Step 1: Developer Mode"
try {
    $k = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path $k)) { New-Item -Path $k -Force | Out-Null }
    Set-ItemProperty -Path $k -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $k -Name "AllowAllTrustedApps" -Value 1 -Type DWord -Force
    Write-Success "Developer Mode enabled"
} catch { Write-Warn "Developer Mode: $($_.Exception.Message)" }

# ============================================================
# STEP 2: WSL & VIRTUALISATION
# ============================================================
Write-Step "Step 2: WSL2, Hyper-V, VirtualMachinePlatform"
try {
    $s = (Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State
    if ($s -ne "Enabled") { Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart | Out-Null; Write-Success "VirtualMachinePlatform enabled"; $needsRestart = $true }
    else { Write-Success "VirtualMachinePlatform already enabled" }
} catch { Write-Warn "VirtualMachinePlatform: $($_.Exception.Message)" }

try {
    $hv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
    if ($hv -and $hv.State -ne "Enabled") { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart | Out-Null; Write-Success "Hyper-V enabled"; $needsRestart = $true }
    elseif ($hv) { Write-Success "Hyper-V already enabled" }
    else { Write-Info "Hyper-V not available (Windows Home - this is normal)" }
} catch { Write-Warn "Hyper-V: $($_.Exception.Message)" }

try {
    if (Test-Cmd "wsl") { wsl --update 2>$null; Write-Success "WSL updated" }
    else { wsl --install --no-distribution 2>$null; Write-Success "WSL installed"; $needsRestart = $true }
} catch { Write-Warn "WSL: $($_.Exception.Message)" }

# ============================================================
# STEP 3: WINGET APPS
# ============================================================
Write-Step "Step 3: Desktop apps (winget)"
if (-not (Test-Cmd "winget")) {
    Write-Warn "winget not found - trying to install App Installer..."
    try { Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe; Write-Success "winget ready" }
    catch { Write-Warn "winget unavailable - please install apps manually from the website" }
}
if (Test-Cmd "winget") {
    $apps = @(
        @{ Id="Git.Git";                    Name="Git" },
        @{ Id="OpenJS.NodeJS.LTS";          Name="Node.js LTS" },
        @{ Id="Microsoft.VisualStudioCode"; Name="VS Code" },
        @{ Id="Anysphere.Cursor";           Name="Cursor" },
        @{ Id="Anthropic.Claude";           Name="Claude Desktop" },
        @{ Id="OpenAI.ChatGPT";             Name="ChatGPT Desktop" },
        @{ Id="Obsidian.Obsidian";          Name="Obsidian" }
    )
    foreach ($app in $apps) {
        Write-Info "Installing $($app.Name)..."
        winget install --id $app.Id -e --accept-source-agreements --accept-package-agreements --silent 2>$null
        Write-Success "$($app.Name) - installed (or already present)"
    }
} else {
    Write-Warn "winget unavailable - please download apps manually"
}

# ============================================================
# STEP 4: CLI TOOLS
# ============================================================
Write-Step "Step 4: CLI tools"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Info "Claude Code CLI..."
try { Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression; Write-Success "Claude Code CLI installed" }
catch { Write-Warn "Claude Code CLI: $($_.Exception.Message)" }

Write-Info "Codex CLI..."
try {
    $null = & powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex" 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Success "Codex CLI installed" } else { throw "exit $LASTEXITCODE" }
} catch { Write-Warn "Codex CLI: $($_.Exception.Message)" }

Write-Info "Grok CLI..."
try { Invoke-RestMethod https://x.ai/cli/install.ps1 | Invoke-Expression; Write-Success "Grok CLI installed" }
catch { Write-Warn "Grok CLI: $($_.Exception.Message)" }

Write-Info "Antigravity CLI..."
try { Invoke-RestMethod https://antigravity.google/cli/install.ps1 | Invoke-Expression; Write-Success "Antigravity CLI installed" }
catch { Write-Warn "Antigravity CLI: $($_.Exception.Message)" }

# ============================================================
# STEP 5: VERIFY
# ============================================================
Write-Step "Step 5: Verify"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$passed = 0; $failed = 0
$checks = @(
    @{ Name="Git";             Command="git";          Args="--version" },
    @{ Name="Node.js";         Command="node";         Args="--version" },
    @{ Name="npm";             Command="npm";          Args="--version" },
    @{ Name="Claude Code CLI"; Command="claude";       Args="--version" },
    @{ Name="Codex CLI";       Command="codex";        Args="--version" },
    @{ Name="Grok CLI";        Command="grok";         Args="--version" },
    @{ Name="Antigravity CLI"; Command="antigravity";  Args="--version" }
)
foreach ($c in $checks) {
    if (Test-Cmd $c.Command) {
        try { $v = & $c.Command $c.Args 2>&1 | Select-Object -First 1; Write-Success "$($c.Name): $v" }
        catch { Write-Success "$($c.Name): installed" }
        $passed++
    } else { Write-Warn "$($c.Name): not found (check again after restart)"; $failed++ }
}

# ============================================================
# SUMMARY
# ============================================================
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host "     Result: $passed OK / $($passed + $failed) total" -ForegroundColor Green
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""

if ($needsRestart) {
    Write-Host "  [!] A restart is required (for WSL / Hyper-V)." -ForegroundColor Yellow
    $r2 = Read-Host "  Restart now? (Y/N)"
    if ($r2 -eq 'Y' -or $r2 -eq 'y') { shutdown /r /t 10 /c "Coinmania AI Training Setup" }
    else { Write-Host "  [i] Please restart later to finish the installation." -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "  Next steps: create your accounts and ask to be added to the Team." -ForegroundColor White
Write-Host "  (See Step 4 on the website.)" -ForegroundColor Gray
Write-Host "  Questions? Contact Giorgi Amiridze or Sulkhan Jashi." -ForegroundColor Gray
Write-Host ""
Read-Host "  Press Enter to exit"
