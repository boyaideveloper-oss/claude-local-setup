# Claude Code + Local LLM Setup (Windows)
# Run with: powershell -ExecutionPolicy Bypass -File install.ps1
#Requires -Version 5.1

$ErrorActionPreference = "Stop"

Write-Host "=== Claude Code + Local LLM Setup (Windows) ===" -ForegroundColor Cyan
Write-Host ""

# 1. Install Python packages
Write-Host "[1/5] Installing LiteLLM and ddgs..."
python -m pip install --quiet "litellm[proxy]" "httpx[socks]" ddgs
Write-Host "      Done"

# 2. Copy config files
Write-Host "[2/5] Copying config files..."
$claudeDir = "$env:USERPROFILE\.claude"
$hooksDir  = "$env:USERPROFILE\litellm_hooks"
$binDir    = "$env:USERPROFILE\.local\bin"
New-Item -ItemType Directory -Force $claudeDir | Out-Null
New-Item -ItemType Directory -Force $hooksDir  | Out-Null
New-Item -ItemType Directory -Force $binDir    | Out-Null

Copy-Item "litellm_config.yaml"                    "$claudeDir\litellm_config.yaml"   -Force
Copy-Item "claude-local.ps1"                       "$claudeDir\claude-local.ps1"      -Force
Copy-Item "tailscale-forward"                      "$claudeDir\tailscale-forward"     -Force
Copy-Item "litellm_hooks\system_prompt_hook.py"    "$hooksDir\system_prompt_hook.py"  -Force

# Create claude-local.bat launcher in PATH
@"
@echo off
powershell -ExecutionPolicy Bypass -File "$claudeDir\claude-local.ps1" %*
"@ | Set-Content "$binDir\claude-local.bat" -Encoding ASCII

# Create tailscale-forward.bat launcher
@"
@echo off
python "$claudeDir\tailscale-forward" %*
"@ | Set-Content "$binDir\tailscale-forward.bat" -Encoding ASCII

Write-Host "      Done"

# 3. Choose connection mode
Write-Host ""
Write-Host "[3/5] Select connection mode"
Write-Host "      1) Local     - Claude Code and llama.cpp on the same machine"
Write-Host "      2) LAN       - llama.cpp on another machine in the same network"
Write-Host "      3) Tailscale - llama.cpp outside LAN (remote / mobile)"
$mode = Read-Host "      Choose [1/2/3]"

if ($mode -eq "1") {
    Write-Host ""
    Write-Host "[4/5] Setting up Local mode..."
    $port = Read-Host "      llama.cpp port (default 8080)"
    if (-not $port) { $port = "8080" }
    $url = "http://127.0.0.1:${port}/v1"
    try { Invoke-WebRequest "$url/models" -TimeoutSec 5 -UseBasicParsing | Out-Null; Write-Host "      Connection successful" }
    catch { Write-Host "      Warning: cannot connect (make sure llama.cpp is running)" }
    [System.Environment]::SetEnvironmentVariable("LLAMA_API_BASE", $url, "User")
    $env:LLAMA_API_BASE = $url
    Write-Host "      Set LLAMA_API_BASE=$url"

} elseif ($mode -eq "3") {
    Write-Host ""
    Write-Host "[4/5] Setting up Tailscale mode..."
    Write-Host "      Make sure Tailscale is installed and logged in."
    Write-Host "      Download: https://tailscale.com/download/windows"
    $tsIp   = Read-Host "      Tailscale IP of llama.cpp machine (e.g. 100.89.99.41)"
    $tsPort = Read-Host "      llama.cpp port (default 8080)"
    if (-not $tsPort) { $tsPort = "8080" }
    $url = "http://${tsIp}:${tsPort}/v1"
    [System.Environment]::SetEnvironmentVariable("LLAMA_API_BASE",    $url,            "User")
    [System.Environment]::SetEnvironmentVariable("LLAMA_TS_IP",       $tsIp,           "User")
    [System.Environment]::SetEnvironmentVariable("TAILSCALE_SOCKS5",  "localhost:1055", "User")
    $env:LLAMA_API_BASE   = $url
    $env:LLAMA_TS_IP      = $tsIp
    $env:TAILSCALE_SOCKS5 = "localhost:1055"
    Write-Host "      Set LLAMA_API_BASE=$url"
    Write-Host "      Set TAILSCALE_SOCKS5=localhost:1055"
    Write-Host ""
    Write-Host "      Note: Tailscale must be running before using claude-local." -ForegroundColor Yellow

} else {
    Write-Host ""
    Write-Host "[4/5] Setting up LAN mode..."
    $hostPort = Read-Host "      llama.cpp IP:PORT (e.g. 192.168.1.100:8080)"
    $url = "http://$hostPort/v1"
    try { Invoke-WebRequest "$url/models" -TimeoutSec 5 -UseBasicParsing | Out-Null; Write-Host "      Connection successful" }
    catch { Write-Host "      Warning: cannot connect (make sure llama.cpp is running)" }
    [System.Environment]::SetEnvironmentVariable("LLAMA_API_BASE", $url, "User")
    $env:LLAMA_API_BASE = $url
    Write-Host "      Set LLAMA_API_BASE=$url"
}

# Add binDir to User PATH if not already present
$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User") ?? ""
if ($userPath -notlike "*$binDir*") {
    [System.Environment]::SetEnvironmentVariable("PATH", "$userPath;$binDir", "User")
    Write-Host ""
    Write-Host "      Added $binDir to PATH" -ForegroundColor Green
}

# 5. Done
Write-Host ""
Write-Host "[5/5] All done!" -ForegroundColor Green
Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage:"
Write-Host "  claude-local              Start interactive session"
Write-Host "  claude-local -p 'query'   One-shot query"
Write-Host ""
Write-Host "Restart your terminal for PATH and environment variable changes to take effect."
