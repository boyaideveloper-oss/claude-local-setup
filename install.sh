#!/bin/bash
set -e

echo "=== Claude Code + Local LLM Setup ==="
echo ""

# shell config file
SHELL_RC="$HOME/.bashrc"
[ "$SHELL" = "/bin/zsh" ] && SHELL_RC="$HOME/.zshrc"

set_env() {
    local key="$1" val="$2"
    if grep -q "export $key=" "$SHELL_RC" 2>/dev/null; then
        sed -i "s|export $key=.*|export $key=$val|" "$SHELL_RC"
    else
        echo "export $key=$val" >> "$SHELL_RC"
    fi
    export "$key"="$val"
}

# 1. Install LiteLLM + ddgs
echo "[1/5] Installing LiteLLM and ddgs..."
if ! pip install --break-system-packages -q 'litellm[proxy]' 'httpx[socks]' 'ddgs' 2>/dev/null; then
    # Debian/Ubuntu: some packages (e.g. PyYAML) installed by apt have no RECORD file
    pip install --break-system-packages --ignore-installed -q 'litellm[proxy]' 'httpx[socks]' 'ddgs'
fi
echo "      Done"

# 2. Copy config files
echo "[2/5] Copying config files..."
mkdir -p ~/.claude
mkdir -p /root/litellm_hooks
cp litellm_config.yaml ~/.claude/
cp start-litellm.sh ~/.claude/ && chmod +x ~/.claude/start-litellm.sh
cp claude-local /usr/local/bin/claude-local && chmod +x /usr/local/bin/claude-local
cp tailscale-forward /usr/local/bin/tailscale-forward && chmod +x /usr/local/bin/tailscale-forward
cp litellm_hooks/system_prompt_hook.py /root/litellm_hooks/system_prompt_hook.py
echo "      Done"

# 3. Choose connection mode
echo ""
echo "[3/5] Select connection mode"
echo "      1) Local     — Claude Code and llama.cpp on the same machine"
echo "      2) LAN       — llama.cpp on another machine in the same network"
echo "      3) Tailscale — llama.cpp outside LAN (remote / mobile)"
read -p "      Choose [1/2/3]: " MODE

if [ "$MODE" = "1" ]; then
    echo ""
    echo "[4/5] Setting up Local mode..."
    read -p "      llama.cpp port (default 8080): " LOCAL_PORT
    LOCAL_PORT="${LOCAL_PORT:-8080}"
    LLAMA_URL="http://127.0.0.1:$LOCAL_PORT/v1"

    echo "      Testing connection to $LLAMA_URL ..."
    if curl -s --max-time 5 "$LLAMA_URL/models" > /dev/null; then
        echo "      Connection successful"
    else
        echo "      Warning: cannot connect (make sure llama.cpp is running)"
    fi

    set_env "LLAMA_API_BASE" "$LLAMA_URL"
    echo "      Set LLAMA_API_BASE=$LLAMA_URL"

elif [ "$MODE" = "3" ]; then
    # Install Tailscale
    echo ""
    echo "[4/5] Setting up Tailscale..."
    if ! command -v tailscale &>/dev/null; then
        curl -fsSL https://tailscale.com/install.sh | sh
        echo "      Tailscale installed"
    else
        echo "      Tailscale already installed ($(tailscale version 2>/dev/null | head -1))"
    fi

    # Start tailscaled
    echo "      Starting tailscaled..."
    pkill tailscaled 2>/dev/null || true
    sleep 1
    tailscaled --tun=userspace-networking \
        --socks5-server=localhost:1055 \
        --state=/var/lib/tailscale/tailscaled.state \
        --socket=/run/tailscale/tailscaled.sock &>/tmp/tailscaled.log &
    sleep 3

    # Login
    echo "      Please log in to Tailscale..."
    tailscale up || true
    echo ""
    echo "      Press Enter after login is complete"
    read -p "      " _
    tailscale status 2>/dev/null || true

    # Tailscale IP input
    echo ""
    read -p "      Tailscale IP of the llama.cpp machine (e.g. 100.89.99.41): " TS_IP
    read -p "      llama.cpp port (default 8080): " TS_PORT
    TS_PORT="${TS_PORT:-8080}"

    LLAMA_URL="http://$TS_IP:$TS_PORT/v1"
    set_env "LLAMA_API_BASE" "$LLAMA_URL"
    set_env "TAILSCALE_SOCKS5" "localhost:1055"
    echo "      Set LLAMA_API_BASE=$LLAMA_URL"
    echo "      Set TAILSCALE_SOCKS5=localhost:1055"

else
    echo ""
    echo "[4/5] Setting up LAN mode..."
    read -p "      llama.cpp IP:PORT (e.g. 192.168.1.100:8080): " HOST
    LLAMA_URL="http://$HOST/v1"

    echo "      Testing connection to $LLAMA_URL ..."
    if curl -s --max-time 5 "$LLAMA_URL/models" > /dev/null; then
        echo "      Connection successful"
    else
        echo "      Warning: cannot connect (make sure llama.cpp is running)"
    fi

    set_env "LLAMA_API_BASE" "$LLAMA_URL"
fi

# 5. Done
echo ""
echo "[5/5] All done!"
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Usage:"
echo "  claude-local              Start interactive session"
echo "  claude-local -p 'query'  One-shot query"
echo ""
echo "Settings saved to $SHELL_RC (auto-loaded on new terminal)"
