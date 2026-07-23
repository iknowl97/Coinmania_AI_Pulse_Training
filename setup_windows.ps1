<#
╔══════════════════════════════════════════════════════════════════╗
║  🚀 Coinmania — AI Training Setup Script (Windows)              ║
║  ─────────────────────────────────────────────────────────────── ║
║  ეს სკრიპტი ავტომატურად აყენებს ყველა საჭირო                    ║
║  აპლიკაციას და CLI ინსტრუმენტს ტრენინგისთვის.                   ║
║                                                                  ║
║  გაშვება: მარჯვენა კლიკი → Run with PowerShell                  ║
║  (სკრიპტი თავად მოითხოვს ადმინისტრატორის უფლებებს — UAC)         ║
╚══════════════════════════════════════════════════════════════════╝
#>

# ──────────────────────────────────────────────
# კონსოლის UTF-8 (ქართული/emoji სწორად გამოჩნდეს)
# ──────────────────────────────────────────────
try { chcp 65001 > $null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# ──────────────────────────────────────────────
# ავტომატური ელევაცია ადმინისტრატორამდე
# (ასწორებს "გაშვებისთანავე ჩაკეტვას", როცა admin არ არის)
# ──────────────────────────────────────────────
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ([string]::IsNullOrEmpty($PSCommandPath)) {
        Write-Host ""
        Write-Host "  ❌ გთხოვთ გაუშვათ ფაილი: მარჯვენა კლიკი -> Run with PowerShell" -ForegroundColor Yellow
        Read-Host "  Enter-ი გასასვლელად"; exit 1
    }
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    } catch {
        Write-Host ""
        Write-Host "  ⚠️  UAC მოთხოვნა უარყოფილია. სკრიპტს ადმინისტრატორის უფლებები სჭირდება." -ForegroundColor Red
        Read-Host "  Enter-ი გასასვლელად"
    }
    exit
}

# ──────────────────────────────────────────────
# კონფიგურაცია
# ──────────────────────────────────────────────
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# ──────────────────────────────────────────────
# ფუნქციები
# ──────────────────────────────────────────────
function Write-Step {
    param([string]$Emoji, [string]$Message)
    Write-Host ""
    Write-Host "  $Emoji  $Message" -ForegroundColor Cyan
    Write-Host "  $('─' * 60)" -ForegroundColor DarkGray
}

function Write-Success {
    param([string]$Message)
    Write-Host "     ✅ $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "     ⚠️  $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "     ℹ️  $Message" -ForegroundColor Gray
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# ──────────────────────────────────────────────
# HEADER
# ──────────────────────────────────────────────
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║                                                          ║" -ForegroundColor Magenta
Write-Host "  ║   🚀  Coinmania — AI Training Setup                      ║" -ForegroundColor Magenta
Write-Host "  ║       ავტომატური ინსტალაციის სკრიპტი                    ║" -ForegroundColor Magenta
Write-Host "  ║                                                          ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  ეს სკრიპტი დააყენებს:" -ForegroundColor White
Write-Host "    • Windows Developer Mode" -ForegroundColor Gray
Write-Host "    • WSL2, Hyper-V, VirtualMachinePlatform" -ForegroundColor Gray
Write-Host "    • Git, Node.js, VS Code, Cursor, Claude Desktop" -ForegroundColor Gray
Write-Host "    • ChatGPT Desktop, Obsidian" -ForegroundColor Gray
Write-Host "    • Claude Code CLI, Codex CLI, Grok CLI, Antigravity CLI" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "  გსურთ ინსტალაციის დაწყება? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "  ინსტალაცია გაუქმებულია." -ForegroundColor Yellow
    exit 0
}

$needsRestart = $false

# ══════════════════════════════════════════════
# ნაბიჯი 1: DEVELOPER MODE
# ══════════════════════════════════════════════
Write-Step "⚙️" "ნაბიჯი 1: Developer Mode-ის ჩართვა"

try {
    $devModeKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path $devModeKey)) {
        New-Item -Path $devModeKey -Force | Out-Null
    }
    Set-ItemProperty -Path $devModeKey -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $devModeKey -Name "AllowAllTrustedApps" -Value 1 -Type DWord -Force
    Write-Success "Developer Mode ჩართულია"
} catch {
    Write-Warn "Developer Mode-ის ჩართვა ვერ მოხერხდა: $($_.Exception.Message)"
    Write-Info "ხელით ჩართვა: Settings → Developer Settings → Developer Mode → On"
}

# ══════════════════════════════════════════════
# ნაბიჯი 2: WSL & VIRTUALIZATION
# ══════════════════════════════════════════════
Write-Step "🐧" "ნაბიჯი 2: WSL, Hyper-V და ვირტუალიზაციის ჩართვა"

# VirtualMachinePlatform
try {
    $vmpState = (Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State
    if ($vmpState -ne "Enabled") {
        Write-Info "VirtualMachinePlatform-ის ჩართვა..."
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart | Out-Null
        Write-Success "VirtualMachinePlatform ჩართულია"
        $needsRestart = $true
    } else {
        Write-Success "VirtualMachinePlatform უკვე ჩართულია"
    }
} catch {
    Write-Warn "VirtualMachinePlatform ვერ ჩაირთო: $($_.Exception.Message)"
}

# Hyper-V (თუ ხელმისაწვდომია)
try {
    $hvFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
    if ($hvFeature) {
        if ($hvFeature.State -ne "Enabled") {
            Write-Info "Hyper-V-ის ჩართვა..."
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart | Out-Null
            Write-Success "Hyper-V ჩართულია"
            $needsRestart = $true
        } else {
            Write-Success "Hyper-V უკვე ჩართულია"
        }
    } else {
        Write-Info "Hyper-V არ არის ხელმისაწვდომი ამ Windows ვერსიაზე (ეს ნორმალურია Home ვერსიაზე)"
    }
} catch {
    Write-Warn "Hyper-V-ის შემოწმება ვერ მოხერხდა: $($_.Exception.Message)"
}

# WSL
try {
    if (Test-CommandExists "wsl") {
        Write-Info "WSL უკვე დაინსტალირებულია, განახლების მცდელობა..."
        wsl --update 2>$null
        Write-Success "WSL განახლებულია"
    } else {
        Write-Info "WSL-ის ინსტალაცია..."
        wsl --install --no-distribution 2>$null
        Write-Success "WSL დაინსტალირებულია"
        $needsRestart = $true
    }
} catch {
    Write-Warn "WSL ინსტალაცია ვერ მოხერხდა: $($_.Exception.Message)"
}

# ══════════════════════════════════════════════
# ნაბიჯი 3: WINGET INSTALLATIONS
# ══════════════════════════════════════════════
Write-Step "📦" "ნაბიჯი 3: დესკტოპ აპლიკაციების ინსტალაცია (winget)"

# შევამოწმოთ winget ხელმისაწვდომობა
if (-not (Test-CommandExists "winget")) {
    Write-Warn "winget არ არის ხელმისაწვდომი. ცდილობს App Installer-ის ინსტალაციას..."
    try {
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
        Write-Success "winget დაინსტალირებულია"
    } catch {
        Write-Warn "winget ვერ დაინსტალირდა. გთხოვთ ხელით დააინსტალიროთ Microsoft Store-დან 'App Installer'"
    }
}

if (Test-CommandExists "winget") {
    # Git
    Write-Info "Git-ის ინსტალაცია..."
    if (Test-CommandExists "git") {
        Write-Success "Git უკვე დაინსტალირებულია ($(git --version))"
    } else {
        winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements --silent 2>$null
        Write-Success "Git დაინსტალირებულია"
    }

    # Node.js LTS
    Write-Info "Node.js LTS-ის ინსტალაცია..."
    if (Test-CommandExists "node") {
        Write-Success "Node.js უკვე დაინსტალირებულია ($(node --version))"
    } else {
        winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements --silent 2>$null
        Write-Success "Node.js LTS დაინსტალირებულია"
    }

    # VS Code
    Write-Info "Visual Studio Code-ის ინსტალაცია..."
    winget install --id Microsoft.VisualStudioCode -e --accept-source-agreements --accept-package-agreements --silent 2>$null
    Write-Success "VS Code დაინსტალირებულია (ან უკვე არსებობს)"

    # Cursor
    Write-Info "Cursor-ის ინსტალაცია..."
    winget install --id Anysphere.Cursor -e --accept-source-agreements --accept-package-agreements --silent 2>$null
    Write-Success "Cursor დაინსტალირებულია (ან უკვე არსებობს)"

    # Claude Desktop
    Write-Info "Claude Desktop-ის ინსტალაცია..."
    winget install --id Anthropic.Claude -e --accept-source-agreements --accept-package-agreements --silent 2>$null
    Write-Success "Claude Desktop დაინსტალირებულია (ან უკვე არსებობს)"

    # ChatGPT Desktop
    Write-Info "ChatGPT Desktop-ის ინსტალაცია..."
    winget install --id OpenAI.ChatGPT -e --accept-source-agreements --accept-package-agreements --silent 2>$null
    Write-Success "ChatGPT Desktop დაინსტალირებულია (ან უკვე არსებობს)"

    # Obsidian
    Write-Info "Obsidian-ის ინსტალაცია..."
    winget install --id Obsidian.Obsidian -e --accept-source-agreements --accept-package-agreements --silent 2>$null
    Write-Success "Obsidian დაინსტალირებულია (ან უკვე არსებობს)"

} else {
    Write-Warn "winget არ არის ხელმისაწვდომი — გთხოვთ აპლიკაციები ხელით ჩამოტვირთოთ PREPARATION_GUIDE.md-დან"
}

# ══════════════════════════════════════════════
# ნაბიჯი 4: CLI TOOLS
# ══════════════════════════════════════════════
Write-Step "🛠️" "ნაბიჯი 4: CLI ინსტრუმენტების ინსტალაცია"

# PATH-ის განახლება მიმდინარე სესიაში
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Claude Code CLI
Write-Info "Claude Code CLI-ის ინსტალაცია..."
try {
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
    Write-Success "Claude Code CLI დაინსტალირებულია"
} catch {
    Write-Warn "Claude Code CLI ვერ დაინსტალირდა: $($_.Exception.Message)"
    Write-Info "ხელით ინსტალაცია: irm https://claude.ai/install.ps1 | iex"
}

# Codex CLI
Write-Info "Codex CLI-ის ინსტალაცია..."
try {
    $null = & powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex" 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Success "Codex CLI დაინსტალირებულია" }
    else { throw "exit code $LASTEXITCODE" }
} catch {
    Write-Warn "Codex CLI ვერ დაინსტალირდა: $($_.Exception.Message)"
    Write-Info "ხელით: powershell -ExecutionPolicy ByPass -c `"irm https://chatgpt.com/codex/install.ps1 | iex`""
}

# Grok CLI
Write-Info "Grok CLI-ის ინსტალაცია..."
try {
    Invoke-RestMethod https://x.ai/cli/install.ps1 | Invoke-Expression
    Write-Success "Grok CLI დაინსტალირებულია"
} catch {
    Write-Warn "Grok CLI ვერ დაინსტალირდა: $($_.Exception.Message)"
    Write-Info "ხელით: irm https://x.ai/cli/install.ps1 | iex"
}

# Antigravity CLI
Write-Info "Antigravity CLI-ის ინსტალაცია..."
try {
    Invoke-RestMethod https://antigravity.google/cli/install.ps1 | Invoke-Expression
    Write-Success "Antigravity CLI დაინსტალირებულია"
} catch {
    Write-Warn "Antigravity CLI ვერ დაინსტალირდა: $($_.Exception.Message)"
    Write-Info "ხელით: irm https://antigravity.google/cli/install.ps1 | iex"
}

# ══════════════════════════════════════════════
# ნაბიჯი 5: VERIFICATION
# ══════════════════════════════════════════════
Write-Step "✅" "ნაბიჯი 5: ინსტალაციების შემოწმება"

# PATH-ის ხელახალი განახლება
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$checks = @(
    @{ Name = "Git";             Command = "git";          Args = "--version" },
    @{ Name = "Node.js";         Command = "node";         Args = "--version" },
    @{ Name = "npm";             Command = "npm";          Args = "--version" },
    @{ Name = "Claude Code CLI"; Command = "claude";       Args = "--version" },
    @{ Name = "Codex CLI";       Command = "codex";        Args = "--version" },
    @{ Name = "Grok CLI";        Command = "grok";         Args = "--version" },
    @{ Name = "Antigravity CLI"; Command = "antigravity";  Args = "--version" }
)

$passed = 0
$failed = 0

foreach ($check in $checks) {
    if (Test-CommandExists $check.Command) {
        try {
            $version = & $check.Command $check.Args 2>&1 | Select-Object -First 1
            Write-Success "$($check.Name): $version"
            $passed++
        } catch {
            Write-Success "$($check.Name): ინსტალირებულია"
            $passed++
        }
    } else {
        Write-Warn "$($check.Name): ვერ მოიძებნა (შეიძლება გადატვირთვის შემდეგ გამოჩნდეს)"
        $failed++
    }
}

# ══════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                          ║" -ForegroundColor Green
Write-Host "  ║   📊  შედეგი: $passed წარმატებული / $($passed + $failed) სულ                         ║" -ForegroundColor Green
Write-Host "  ║                                                          ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

if ($needsRestart) {
    Write-Host "  ⚠️  კომპიუტერის გადატვირთვა საჭიროა!" -ForegroundColor Yellow
    Write-Host "     (WSL/Hyper-V/VirtualMachinePlatform ცვლილებებისთვის)" -ForegroundColor Yellow
    Write-Host ""
    $restartNow = Read-Host "  გსურთ ახლავე გადატვირთვა? (Y/N)"
    if ($restartNow -eq 'Y' -or $restartNow -eq 'y') {
        Write-Host "  🔄 კომპიუტერი გადაიტვირთება 10 წამში..." -ForegroundColor Cyan
        shutdown /r /t 10 /c "Coinmania AI Training Setup - გადატვირთვა"
    } else {
        Write-Host "  ℹ️  არ დაგავიწყდეთ კომპიუტერის გადატვირთვა ინსტალაციის დასრულებამდე!" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "  📋 შემდეგი ნაბიჯები:" -ForegroundColor White
Write-Host "     1. შექმენით ანგარიშები PREPARATION_GUIDE.md-ში მითითებულ საიტებზე" -ForegroundColor Gray
Write-Host "     2. გაუგზავნეთ თქვენი @coinmania.ge მეილი გიორგის ან სულხანს" -ForegroundColor Gray
Write-Host "        (Claude Team და ChatGPT Team-ში დასამატებლად)" -ForegroundColor Gray
Write-Host ""
Write-Host "  📞 კითხვები? დაუკავშირდით გიორგი ამირიძეს ან სულხან ჯაშს" -ForegroundColor Gray
Write-Host ""
Read-Host "  დააჭირეთ Enter-ს გასასვლელად"
