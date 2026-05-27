# Claude Code with local LLM via LiteLLM proxy (Windows)
param([Parameter(ValueFromRemainingArguments=$true)]$ClaudeArgs)

$PROXY_URL     = "http://localhost:4000"
$CONFIG_FILE   = "$env:USERPROFILE\.claude\litellm_config.yaml"
$HOOKS_DIR     = "$env:USERPROFILE\litellm_hooks"
$FORWARD_PORT  = 18080
$LOG_DIR       = $env:TEMP

$LAN_IP    = if ($env:LLAMA_LAN_IP) { $env:LLAMA_LAN_IP } else { "192.168.68.67" }
$TS_IP     = if ($env:LLAMA_TS_IP)  { $env:LLAMA_TS_IP  } else { "100.89.99.41"  }
$LLAMA_PORT = if ($env:LLAMA_PORT)  { $env:LLAMA_PORT   } else { "8080"           }

Write-Host "กำลังตรวจสอบ network..."

$LLAMA_API_BASE    = $null
$EFFECTIVE_API_BASE = $null

try {
    Invoke-WebRequest "http://${LAN_IP}:${LLAMA_PORT}/health" -TimeoutSec 2 -UseBasicParsing | Out-Null
    Write-Host "Network: LAN ($LAN_IP)"
    $LLAMA_API_BASE     = "http://${LAN_IP}:${LLAMA_PORT}/v1"
    $EFFECTIVE_API_BASE = $LLAMA_API_BASE
} catch {
    Write-Host "Network: Tailscale ($TS_IP)"
    $LLAMA_API_BASE = "http://${TS_IP}:${LLAMA_PORT}/v1"

    # Kill existing forwarder on this port
    Get-CimInstance Win32_Process -Filter "Name = 'python.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match "tailscale-forward.*$FORWARD_PORT" } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

    $fwdPath = Join-Path $PSScriptRoot "tailscale-forward"
    Write-Host "Forwarding: ${TS_IP}:${LLAMA_PORT} -> localhost:${FORWARD_PORT}"
    Start-Process python -ArgumentList @($fwdPath, $FORWARD_PORT, $TS_IP, $LLAMA_PORT) `
        -WindowStyle Hidden `
        -RedirectStandardOutput "$LOG_DIR\ts-forward.log" `
        -RedirectStandardError  "$LOG_DIR\ts-forward-err.log"
    Start-Sleep 2
    $EFFECTIVE_API_BASE = "http://localhost:${FORWARD_PORT}/v1"
}

# Get model name
try {
    $resp = Invoke-RestMethod "$LLAMA_API_BASE/models" -TimeoutSec 5
    $fullName = ($resp.data ?? $resp.models)[0].id
} catch {
    Write-Error "Error: ไม่สามารถดึงชื่อ model จาก $LLAMA_API_BASE"
    exit 1
}
$name = ($fullName ?? "local-model") -replace '\.gguf$', ''
if ($name -match '^([a-zA-Z]+-[0-9]+)') { $MODEL_NAME = "$($Matches[1]) (local)" }
else { $MODEL_NAME = "$($name.Split('-')[0]) (local)" }
Write-Host "Model: $MODEL_NAME"

# Write LiteLLM config
$hookPath = ($HOOKS_DIR -replace '\\', '/')
New-Item -ItemType Directory -Force (Split-Path $CONFIG_FILE) | Out-Null
@"
model_list:
  - model_name: $MODEL_NAME
    litellm_params:
      model: openai/$MODEL_NAME
      api_base: $EFFECTIVE_API_BASE
      api_key: dummy
      supports_function_calling: true

litellm_settings:
  drop_params: true
  use_chat_completions_url_for_anthropic_messages: true
  callbacks: ["$hookPath/system_prompt_hook.proxy_handler_instance"]
"@ | Set-Content $CONFIG_FILE -Encoding UTF8

# Kill existing proxy
Get-CimInstance Win32_Process -Filter "Name = 'python.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match "proxy_cli\.py.*4000" } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep 1

# Start LiteLLM proxy in background
$litellmDir = python -c "import litellm.proxy, os; print(os.path.dirname(litellm.proxy.__file__))"
$proxyCli   = Join-Path $litellmDir "proxy_cli.py"
Write-Host "Starting LiteLLM proxy..."
Start-Process python -ArgumentList @($proxyCli, "--config", $CONFIG_FILE, "--port", "4000") `
    -WindowStyle Hidden `
    -RedirectStandardOutput "$LOG_DIR\litellm.log" `
    -RedirectStandardError  "$LOG_DIR\litellm_err.log"
Start-Sleep 6

# Launch Claude
$env:ANTHROPIC_BASE_URL = $PROXY_URL
$env:ANTHROPIC_API_KEY  = "dummy"
& claude --model $MODEL_NAME @ClaudeArgs
