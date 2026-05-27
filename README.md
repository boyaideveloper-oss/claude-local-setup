```
 ██████╗  ██████╗ ██╗   ██╗███████╗███████╗██████╗ 
 ██╔══██╗██╔═══██╗╚██╗ ██╔╝██╔════╝██╔════╝██╔══██╗
 ██████╔╝██║   ██║ ╚████╔╝ ███████╗█████╗  ██████╔╝
 ██╔══██╗██║   ██║  ╚██╔╝  ╚════██║██╔══╝  ██╔══██╗
 ██████╔╝╚██████╔╝   ██║   ███████║███████╗██║  ██║
 ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝
```

# Claude Code + Local LLM (llama.cpp)

Run Claude Code with a **local LLM** via LiteLLM proxy — free, private, with real WebSearch powered by DuckDuckGo (no API key required).

**Platform support:** Linux · macOS · Windows

## Why?

- **Free** — no $20/month Anthropic API bill
- **Private** — your code and data never leave your machine
- **WebSearch** — real-time search results, not hallucinated answers
- **One-command install** — works on Local / LAN / Tailscale

---

## Architecture

```
Claude Code  →  LiteLLM proxy (:4000)  →  llama.cpp server
  [Anthropic API format]    ↑               [OpenAI-compatible]
                     system_prompt_hook
                     (WebSearch via ddgs)
```

---

## Requirements

- Python 3.x + pip
- [llama.cpp](https://github.com/ggerganov/llama.cpp) server running with a model loaded
- Claude Code CLI (`npm install -g @anthropic-ai/claude-code`)
- **Windows only:** PowerShell 5.1+ (included in Windows 10/11)

---

## Install

### Linux / macOS

```bash
git clone https://github.com/boyaideveloper-oss/claude-local-setup.git
cd claude-local-setup
bash install.sh
```

### Windows

```powershell
git clone https://github.com/boyaideveloper-oss/claude-local-setup.git
cd claude-local-setup
powershell -ExecutionPolicy Bypass -File install.ps1
```

Both installers ask for your connection mode:

```
[3/5] Select connection mode
      1) Local     — Claude Code and llama.cpp on the same machine
      2) LAN       — llama.cpp on another machine in the same network
      3) Tailscale — llama.cpp outside LAN (remote / mobile)
```

---

## Mode 1 — Local (same machine)

Use when: Claude Code and llama.cpp run on the same machine.

```
Claude Code → LiteLLM (:4000) → 127.0.0.1:8080 → llama.cpp
```

**Linux / macOS**
```bash
bash install.sh
# Choose: 1
# llama.cpp port (default 8080): [Enter]
```

**Windows**
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
# Choose: 1
# llama.cpp port (default 8080): [Enter]
```

Sets: `LLAMA_API_BASE=http://127.0.0.1:8080/v1`

---

## Mode 2 — LAN

Use when: llama.cpp runs on another machine in your home/office network.

```
Claude Code → LiteLLM (:4000) → 192.168.x.x:8080 → llama.cpp
```

**Linux / macOS**
```bash
bash install.sh
# Choose: 2
# llama.cpp IP:PORT: 192.168.1.100:8080
```

**Windows**
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
# Choose: 2
# llama.cpp IP:PORT: 192.168.1.100:8080
```

> llama.cpp must be started with `--host 0.0.0.0` to accept connections from other machines:
> ```bash
> ./llama-server -m model.gguf --host 0.0.0.0 --port 8080
> ```

Sets: `LLAMA_API_BASE=http://192.168.1.100:8080/v1`

---

## Mode 3 — Tailscale (remote)

Use when: llama.cpp is at home but you're somewhere else, or accessing from mobile.

```
Claude Code → LiteLLM (:4000) → localhost:18080 → Tailscale → llama.cpp
```

**Linux / macOS**
```bash
bash install.sh
# Choose: 3
# Tailscale IP: 100.x.x.x
# Port: 8080
```

**Windows**
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
# Choose: 3
# Tailscale IP: 100.x.x.x
# Port: 8080
```

> Install Tailscale for Windows from [tailscale.com/download/windows](https://tailscale.com/download/windows) and log in before running `claude-local`.

Sets: `LLAMA_API_BASE=http://100.x.x.x:8080/v1` + `TAILSCALE_SOCKS5=localhost:1055`

---

## Usage

**Linux / macOS**
```bash
# Start interactive session
claude-local

# One-shot query
claude-local -p "What is the gold price today?"
```

**Windows**
```powershell
# Start interactive session
claude-local

# One-shot query
claude-local -p "What is the gold price today?"
```

> On Windows, `claude-local.bat` is installed to `%USERPROFILE%\.local\bin\` and added to PATH automatically. Restart your terminal after install.

`claude-local` will automatically:
1. Detect network (LAN or Tailscale)
2. Fetch model name from llama.cpp
3. Start LiteLLM proxy on port 4000
4. Launch Claude Code ready to use

---

## WebSearch

The installed hook intercepts any `web_search` tool call and runs a real DuckDuckGo search via `ddgs` — no API key needed.

```
User: "What is the gold price today?"
  → hook runs ddgs.text("What is the gold price today?")
  → sends real results to the model
  → model summarizes with source links
```

Test WebSearch directly:

```bash
curl -s -X POST http://localhost:4000/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: dummy" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "local",
    "max_tokens": 2048,
    "messages": [{"role": "user", "content": "latest AI news"}],
    "tools": [{"name": "web_search", "type": "web_search_20250305"}]
  }'
```

---

## Installed Files

### Linux / macOS

| Repo file | Installed to | Purpose |
|---|---|---|
| `claude-local` | `/usr/local/bin/claude-local` | Main CLI command |
| `tailscale-forward` | `/usr/local/bin/tailscale-forward` | TCP port forwarder via Tailscale |
| `litellm_config.yaml` | `~/.claude/litellm_config.yaml` | LiteLLM proxy config |
| `litellm_hooks/system_prompt_hook.py` | `~/litellm_hooks/system_prompt_hook.py` | WebSearch hook + system prompt injection |

### Windows

| Repo file | Installed to | Purpose |
|---|---|---|
| `claude-local.ps1` | `%USERPROFILE%\.claude\claude-local.ps1` | Main PowerShell script |
| `tailscale-forward` | `%USERPROFILE%\.claude\tailscale-forward` | TCP port forwarder via Tailscale |
| `litellm_config.yaml` | `%USERPROFILE%\.claude\litellm_config.yaml` | LiteLLM proxy config |
| `litellm_hooks/system_prompt_hook.py` | `%USERPROFILE%\litellm_hooks\system_prompt_hook.py` | WebSearch hook + system prompt injection |
| *(generated)* | `%USERPROFILE%\.local\bin\claude-local.bat` | CLI launcher (added to PATH) |
| *(generated)* | `%USERPROFILE%\.local\bin\tailscale-forward.bat` | CLI launcher |

---

## Troubleshooting

### Linux / macOS

**Proxy not starting**
```bash
cat /tmp/litellm.log
curl http://localhost:4000/health
```

**Cannot connect to llama.cpp**
```bash
curl $LLAMA_API_BASE/models
```

**WebSearch not working**
```bash
python3 -c "from ddgs import DDGS; print(list(DDGS().text('test', max_results=1)))"
tail -20 /tmp/litellm_debug.log
```

**Debian/Ubuntu: pip install fails (PyYAML RECORD error)**

`install.sh` handles this automatically with `--ignore-installed`. If it still fails:
```bash
pip install --break-system-packages --ignore-installed 'litellm[proxy]' 'httpx[socks]' 'ddgs'
```

### Windows

**Proxy not starting**
```powershell
Get-Content "$env:TEMP\litellm.log" -Tail 30
curl http://localhost:4000/health
```

**Cannot connect to llama.cpp**
```powershell
curl "$env:LLAMA_API_BASE/models"
```

**WebSearch not working**
```powershell
python -c "from ddgs import DDGS; print(list(DDGS().text('test', max_results=1)))"
Get-Content "$env:TEMP\litellm_debug.log" -Tail 20
```

**ExecutionPolicy error**

Run PowerShell as Administrator and execute:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

**claude-local not found after install**

Restart your terminal. If still missing, add the bin folder to PATH manually:
```powershell
$env:PATH += ";$env:USERPROFILE\.local\bin"
```
