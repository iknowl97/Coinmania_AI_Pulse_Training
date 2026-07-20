#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════
#   🚀  Coinmania — AI Training Setup Script (macOS)
#   ─────────────────────────────────────────────────────────────────
#   ეს სკრიპტი ავტომატურად აყენებს ყველა საჭირო
#   აპლიკაციას და CLI ინსტრუმენტს ტრენინგისთვის.
#
#   გაშვება:
#     chmod +x setup_mac.sh && ./setup_mac.sh
# ══════════════════════════════════════════════════════════════════

set -euo pipefail

# ──────────────────────────────────────────────
# ფერები
# ──────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; GRAY='\033[0;90m'; BOLD='\033[1m'; NC='\033[0m'

step()    { echo; echo -e "  ${CYAN}${BOLD}$1  $2${NC}"; echo -e "  ${GRAY}$(printf '─%.0s' {1..60})${NC}"; }
success() { echo -e "     ${GREEN}✅ $1${NC}"; }
warn()    { echo -e "     ${YELLOW}⚠️  $1${NC}"; }
info()    { echo -e "     ${GRAY}ℹ️  $1${NC}"; }

cmd_exists() { command -v "$1" &>/dev/null; }

# ──────────────────────────────────────────────
# HEADER
# ──────────────────────────────────────────────
clear
echo
echo -e "  ${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "  ${CYAN}║                                                          ║${NC}"
echo -e "  ${CYAN}║   🚀  Coinmania — AI Training Setup (macOS)              ║${NC}"
echo -e "  ${CYAN}║       ავტომატური ინსტალაციის სკრიპტი                    ║${NC}"
echo -e "  ${CYAN}║                                                          ║${NC}"
echo -e "  ${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "  ${BOLD}ეს სკრიპტი დააყენებს:${NC}"
echo -e "  ${GRAY}  • Homebrew (პაკეტების მენეჯერი)${NC}"
echo -e "  ${GRAY}  • Git, Node.js${NC}"
echo -e "  ${GRAY}  • VS Code, Cursor, Claude Desktop, ChatGPT, Obsidian${NC}"
echo -e "  ${GRAY}  • Claude Code CLI, Codex CLI, Grok CLI, Antigravity CLI${NC}"
echo

read -p "  გსურთ ინსტალაციის დაწყება? (y/N): " confirm
if [[ "${confirm,,}" != "y" ]]; then
    echo -e "  ${YELLOW}ინსტალაცია გაუქმებულია.${NC}"
    exit 0
fi

# ══════════════════════════════════════════════
# ნაბიჯი 1: XCODE COMMAND LINE TOOLS
# ══════════════════════════════════════════════
step "🔧" "ნაბიჯი 1: Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
    success "Xcode Command Line Tools უკვე დაინსტალირებულია"
else
    info "Xcode Command Line Tools-ის ინსტალაცია (გამოჩნდება ფანჯარა — დააჭირეთ Install)..."
    xcode-select --install 2>/dev/null || true
    echo
    warn "გთხოვთ დაელოდოთ Xcode Command Line Tools-ის ინსტალაციას,"
    warn "შემდეგ დააჭირეთ Enter-ს გასაგრძელებლად."
    read -p "  Enter..."
fi

# ══════════════════════════════════════════════
# ნაბიჯი 2: HOMEBREW
# ══════════════════════════════════════════════
step "🍺" "ნაბიჯი 2: Homebrew (Mac-ის პაკეტ მენეჯერი)"

if cmd_exists brew; then
    success "Homebrew უკვე დაინსტალირებულია"
    info "Homebrew-ის განახლება..."
    brew update --quiet 2>/dev/null && success "Homebrew განახლებულია" || warn "განახლება ვერ მოხერხდა (ეს ნორმალურია)"
else
    info "Homebrew-ის ინსტალაცია..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # PATH-ის დამატება Apple Silicon-ისთვის
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    fi
    success "Homebrew დაინსტალირებულია"
fi

# ══════════════════════════════════════════════
# ნაბიჯი 3: CLI TOOLS (brew)
# ══════════════════════════════════════════════
step "📦" "ნაბიჯი 3: Git და Node.js"

# Git
if cmd_exists git; then
    success "Git უკვე დაინსტალირებულია ($(git --version))"
else
    info "Git-ის ინსტალაცია..."
    brew install git
    success "Git დაინსტალირებულია"
fi

# Node.js LTS
if cmd_exists node; then
    success "Node.js უკვე დაინსტალირებულია ($(node --version))"
else
    info "Node.js LTS-ის ინსტალაცია..."
    brew install node@22
    brew link node@22 --force --overwrite 2>/dev/null || true
    success "Node.js დაინსტალირებულია"
fi

# ══════════════════════════════════════════════
# ნაბიჯი 4: DESKTOP APPS (brew --cask)
# ══════════════════════════════════════════════
step "💻" "ნაბიჯი 4: დესკტოპ აპლიკაციები"

install_cask() {
    local id="$1" name="$2"
    info "${name}-ის ინსტალაცია..."
    if brew list --cask "$id" &>/dev/null; then
        success "${name} უკვე დაინსტალირებულია"
    else
        brew install --cask "$id" --quiet 2>/dev/null && success "${name} დაინსტალირებულია" \
            || warn "${name} ვერ დაინსტალირდა — სცადეთ ხელით: brew install --cask ${id}"
    fi
}

install_cask "visual-studio-code" "Visual Studio Code"
install_cask "cursor"             "Cursor"
install_cask "claude"             "Claude Desktop"
install_cask "chatgpt"            "ChatGPT Desktop"
install_cask "obsidian"           "Obsidian"

# ══════════════════════════════════════════════
# ნაბიჯი 5: CLI TOOLS (install scripts)
# ══════════════════════════════════════════════
step "🛠️" "ნაბიჯი 5: CLI ინსტრუმენტების ინსტალაცია"

# Claude Code CLI
info "Claude Code CLI-ის ინსტალაცია..."
if cmd_exists claude; then
    success "Claude Code CLI უკვე დაინსტალირებულია ($(claude --version 2>/dev/null | head -1))"
else
    if curl -fsSL https://claude.ai/install.sh | bash 2>/dev/null; then
        success "Claude Code CLI დაინსტალირებულია"
    else
        warn "Claude Code CLI ვერ დაინსტალირდა"
        info "ხელით: curl -fsSL https://claude.ai/install.sh | bash"
    fi
fi

# Codex CLI
info "Codex CLI-ის ინსტალაცია..."
if cmd_exists codex; then
    success "Codex CLI უკვე დაინსტალირებულია"
else
    if curl -fsSL https://chatgpt.com/codex/install.sh | sh 2>/dev/null; then
        success "Codex CLI დაინსტალირებულია"
    else
        warn "Codex CLI ვერ დაინსტალირდა"
        info "ხელით: curl -fsSL https://chatgpt.com/codex/install.sh | sh"
    fi
fi

# Grok CLI
info "Grok CLI-ის ინსტალაცია..."
if cmd_exists grok; then
    success "Grok CLI უკვე დაინსტალირებულია"
else
    if curl -fsSL https://x.ai/cli/install.sh | bash 2>/dev/null; then
        success "Grok CLI დაინსტალირებულია"
    else
        warn "Grok CLI ვერ დაინსტალირდა"
        info "ხელით: curl -fsSL https://x.ai/cli/install.sh | bash"
    fi
fi

# Antigravity CLI
info "Antigravity CLI-ის ინსტალაცია..."
if cmd_exists antigravity; then
    success "Antigravity CLI უკვე დაინსტალირებულია"
else
    if curl -fsSL https://antigravity.google/cli/install.sh | bash 2>/dev/null; then
        success "Antigravity CLI დაინსტალირებულია"
    else
        warn "Antigravity CLI ვერ დაინსტალირდა"
        info "ხელით: curl -fsSL https://antigravity.google/cli/install.sh | bash"
    fi
fi

# ══════════════════════════════════════════════
# ნაბიჯი 6: VERIFICATION
# ══════════════════════════════════════════════
step "✅" "ნაბიჯი 6: ინსტალაციების შემოწმება"

# PATH-ის განახლება
export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin"

passed=0; failed=0

check_tool() {
    local name="$1" cmd="$2" args="$3"
    if cmd_exists "$cmd"; then
        local ver
        ver=$("$cmd" $args 2>/dev/null | head -1) || ver="ინსტალირებულია"
        success "${name}: ${ver}"
        passed=$((passed + 1))
    else
        warn "${name}: ვერ მოიძებნა (შეიძლება ახალ Terminal-ში გამოჩნდეს)"
        failed=$((failed + 1))
    fi
}

check_tool "Git"             git          "--version"
check_tool "Node.js"         node         "--version"
check_tool "npm"             npm          "--version"
check_tool "Claude Code CLI" claude       "--version"
check_tool "Codex CLI"       codex        "--version"
check_tool "Grok CLI"        grok         "--version"
check_tool "Antigravity CLI" antigravity  "--version"

# ══════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════
echo
echo -e "  ${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "  ${GREEN}║                                                          ║${NC}"
echo -e "  ${GREEN}║   📊  შედეგი: ${passed} წარმატებული / $((passed + failed)) სულ$(printf '%*s' $((28 - ${#passed} - ${#failed})) '')║${NC}"
echo -e "  ${GREEN}║                                                          ║${NC}"
echo -e "  ${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "  ${BOLD}📋 შემდეგი ნაბიჯები:${NC}"
echo -e "  ${GRAY}  1. შექმენით ანგარიშები PREPARATION_GUIDE.md-ში მითითებულ საიტებზე${NC}"
echo -e "  ${GRAY}  2. გაუგზავნეთ @coinmania.ge მეილი გიორგის ან სულხანს${NC}"
echo -e "  ${GRAY}     (Claude Team და ChatGPT Team-ში დასამატებლად)${NC}"
echo
echo -e "  ${GRAY}📞 კითხვები? დაუკავშირდით გიორგი ამირიძეს ან სულხან ჯაშს${NC}"
echo
