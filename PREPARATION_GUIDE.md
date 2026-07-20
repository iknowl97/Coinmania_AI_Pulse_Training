# 🚀 კურსისთვის მომზადების ინსტრუქცია (Coinmania)

მოგესალმებით! ეს ინსტრუქცია დაგეხმარებათ მოამზადოთ კომპიუტერი **აგენტური AI-ის ტრენინგისთვის**. მიყევით ნაბიჯებს ზემოდან ქვემოთ, თანმიმდევრობით.

---

## 📌 როგორ გავუშვათ ბრძანებები?

ამ ინსტრუქციაში შეხვდებით ნაცრისფერ ბლოკებში ჩასმულ ბრძანებებს. ისინი უნდა გაუშვათ **PowerShell**-ში (Windows) ან **Terminal**-ში (Mac).

### 🪟 Windows — PowerShell-ის გახსნა:

1. კლავიატურაზე დააჭირეთ **Windows ⊞** ღილაკს (ქვედა მარცხენა კუთხეში).
2. ჩაწერეთ: **`PowerShell`**
3. გამოსულ **Windows PowerShell**-ზე დააწკაპუნეთ **მარჯვენა ღილაკით**.
4. აირჩიეთ **"Run as administrator"**.
5. დააჭირეთ **"Yes"**.
6. გაიხსნება ლურჯი/შავი ფანჯარა — აქ ჩაწერთ ბრძანებებს.

### 🍎 Mac — Terminal-ის გახსნა:

1. დააჭირეთ **Command (⌘) + Space**.
2. ჩაწერეთ: **`Terminal`**
3. დააჭირეთ **Enter**.

### 📋 ბრძანების გაშვება:

1. **დააკოპირეთ** ბრძანება: მონიშნეთ მაუსით და **Ctrl + C** (Mac: **⌘ + C**).
2. **ჩასვით** PowerShell-ში/Terminal-ში: **მაუსის მარჯვენა ღილაკი** ან **Ctrl + V** (Mac: **⌘ + V**).
3. დააჭირეთ **Enter**.

---

## ⚙️ ნაბიჯი 1: Windows-ის პარამეტრების გამართვა

> 🍎 **Mac-ის მომხმარებლებმა ეს ნაბიჯი გამოტოვეთ** და გადადით ნაბიჯი 2-ზე.

### 1.1 Developer Mode-ის ჩართვა

1. კლავიატურაზე დააჭირეთ **Windows + I** (გაიხსნება Settings).
2. Start-ის ძებნაში ჩაწერეთ: **`Developer settings`** და დააწკაპუნეთ შედეგზე.
3. **Developer Mode** — გადართეთ **On** პოზიციაზე.
4. დააჭირეთ **Yes**.

### 1.2 ვირტუალიზაციის შემოწმება

1. დააჭირეთ **Ctrl + Shift + Esc** (გაიხსნება Task Manager).
2. გადადით **Performance** ჩანართზე → აირჩიეთ **CPU**.
3. მოძებნეთ **Virtualization** — უნდა წეროს **Enabled**.
   - თუ წერია **Disabled** — დაუკავშირდით გიორგის ან სულხანს.

### 1.3 WSL და Hyper-V

გახსენით **PowerShell** (როგორც ზემოთ აღწერილია) და სათითაოდ გაუშვით ეს ბრძანებები:

```powershell
wsl --install
```

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All
```

> 🔄 თუ გეკითხებათ `(Y/N)` — ჩაწერეთ **`Y`** და დააჭირეთ Enter. კომპიუტერი გადაიტვირთება.

---

## 📦 ნაბიჯი 2: პროგრამების ჩამოტვირთვა და ინსტალაცია

დააწკაპუნეთ ბმულზე → გადმოწერეთ → დააინსტალირეთ (Next → Next → Install).

### 💻 Visual Studio Code

| Windows                                                                                                                                                       | Mac                                                                                                                                                       |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 🔗 [ჩამოტვირთვა](https://vscode.download.prss.microsoft.com/dbazure/download/stable/8a7abeba6e03ea3af87bfbce9a1b7e48fed567b8/VSCodeUserSetup-x64-1.129.1.exe) | 🔗 [ჩამოტვირთვა](https://vscode.download.prss.microsoft.com/dbazure/download/stable/8a7abeba6e03ea3af87bfbce9a1b7e48fed567b8/VSCode-darwin-universal.dmg) |

### 💻 Cursor

| Windows / Mac                                                                      |
| ---------------------------------------------------------------------------------- |
| 🔗 [cursor.com](https://cursor.com) — საიტი ავტომატურად შემოგთავაზებთ სწორ ვერსიას |

### 🤖 Claude Desktop

| Windows                                                                                                                             | Mac                                                                             |
| ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| 🔗 [ჩამოტვირთვა](https://downloads.claude.ai/releases/win32/x64/1.22209.3/ClaudeSetup-babe11577dfefe3e209c06bd674628d862f0dbae.exe) | 🔗 [ჩამოტვირთვა](https://claude.ai/download) — დააწკაპუნეთ "Download for macOS" |

### 🤖 ChatGPT / Codex App

| Windows                                                                                         | Mac                                                                           |
| ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| 🔗 [ჩამოტვირთვა](https://get.microsoft.com/installer/download/9PLM9XGG6VKS?cid=website_cta_psi) | 🔗 [ჩამოტვირთვა](https://persistent.oaistatic.com/codex-app-prod/ChatGPT.dmg) |

### 🔧 Git

| Windows                                            | Mac                                                |
| -------------------------------------------------- | -------------------------------------------------- |
| 🔗 [ჩამოტვირთვა](https://git-scm.com/download/win) | 🔗 [ჩამოტვირთვა](https://git-scm.com/download/mac) |

> 💡 ინსტალაციისას ყველაფერი დატოვეთ ნაგულისხმევი (default) და დააჭირეთ Next-ს.

### 🟢 Node.js

| Windows / Mac                                                                          |
| -------------------------------------------------------------------------------------- |
| 🔗 [nodejs.org](https://nodejs.org/) — ჩამოტვირთეთ **მწვანე ღილაკით** მონიშნული ვერსია |

> ⚠️ Node.js აუცილებელია შემდეგი ნაბიჯისთვის (CLI-ებისთვის). დააინსტალირეთ სანამ გადახვალთ.

### 📝 Obsidian

| Windows / Mac                                                                         |
| ------------------------------------------------------------------------------------- |
| 🔗 [obsidian.md](https://obsidian.md/) — საიტი ავტომატურად შემოგთავაზებთ სწორ ვერსიას |

---

## 🛠️ ნაბიჯი 3: CLI ვერსიების დაყენება

გახსენით **PowerShell** (Windows) ან **Terminal** (Mac) და სათითაოდ გაუშვით ბრძანებები.

---

### 🟠 Claude Code CLI

**Windows:**

```powershell
irm https://claude.ai/install.ps1 | iex
```

**Mac:**

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**შემოწმება** — ჩაწერეთ და გაუშვით:

```
claude --version
```

---

### 🟢 Codex CLI (ChatGPT)

**Windows:**

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

**Mac:**

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
```

**შემოწმება** — ჩაწერეთ `codex` და დააჭირეთ Enter. პირველად გეკითხებათ ავტორიზაცია — აირჩიეთ **Sign in with ChatGPT**.

---

### 🌐 Grok CLI

**Windows:**

```powershell
irm https://x.ai/cli/install.ps1 | iex
```

**Mac:**

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
```

---

### 🔵 Antigravity CLI (Google)

**Windows:**

```powershell
irm https://antigravity.google/cli/install.ps1 | iex
```

**Mac:**

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
```

---

## 🔑 ნაბიჯი 4: ანგარიშების მომზადება

### 🏢 Claude Team & ChatGPT Team

ეს ანგარიშები გუნდურია. თქვენი მეილის დასამატებლად:

1. გაუგზავნეთ თქვენი `@coinmania.ge` მეილი **გიორგი ამირიძეს** ან **სულხან ჯაშს**.
2. ისინი დაგამატებენ გუნდში.
3. მეილზე მოგივათ მოწვევა — მიყევით ინსტრუქციას.

### 📧 Google Gemini & NotebookLM

თქვენ უკვე გაქვთ წვდომა! შედით 🔗 [gemini.google.com](https://gemini.google.com/) თქვენი `@coinmania.ge` მეილით.

### 🌐 სხვა AI სერვისები

შედით თითოეულ საიტზე და დააწკაპუნეთ **Sign Up** ღილაკს. შეგიძლიათ გამოიყენოთ Google-ით რეგისტრაცია (Sign up with Google).

| სერვისი    | ბმული                                            |
| ---------- | ------------------------------------------------ |
| Grok       | 🔗 [grok.com](https://grok.com/)                 |
| Perplexity | 🔗 [perplexity.ai](https://www.perplexity.ai/)   |
| Kimi       | 🔗 [kimi.moonshot.cn](https://kimi.moonshot.cn/) |
| Minimax    | 🔗 [minimaxi.com](https://www.minimaxi.com/)     |
| DeepSeek   | 🔗 [deepseek.com](https://www.deepseek.com/)     |
| Qwen       | 🔗 [chat.qwenlm.ai](https://chat.qwenlm.ai/)     |

---

## ✅ მზადყოფნის ჩეკლისტი

ტრენინგამდე შეამოწმეთ:

- [ ] Windows: Developer Mode ჩართულია
- [ ] Windows: WSL დაინსტალირებულია
- [ ] Windows: ვირტუალიზაცია Enabled-ზეა
- [ ] ✅ VS Code დაინსტალირებულია
- [ ] ✅ Cursor დაინსტალირებულია
- [ ] ✅ Claude Desktop დაინსტალირებულია
- [ ] ✅ ChatGPT / Codex App დაინსტალირებულია
- [ ] ✅ Git დაინსტალირებულია
- [ ] ✅ Node.js დაინსტალირებულია
- [ ] ✅ Obsidian დაინსტალირებულია
- [ ] ✅ Claude CLI (`claude --version`)
- [ ] ✅ Codex CLI (`codex`)
- [ ] ✅ Grok CLI
- [ ] ✅ Antigravity CLI
- [ ] 🔑 Claude Team-ში ხართ დამატებული
- [ ] 🔑 ChatGPT Team-ში ხართ დამატებული
- [ ] 🔑 Google Gemini-ზე შედიხართ
- [ ] 🔑 Grok, Perplexity, Kimi, Minimax, DeepSeek, Qwen — ანგარიშები შექმნილია

---

> 📞 კითხვები? დაუკავშირდით **გიორგი ამირიძეს** ან **სულხან ჯაშს**.
