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

# 1. ติดตั้ง LiteLLM + ddgs
echo "[1/5] ติดตั้ง LiteLLM และ ddgs..."
if ! pip install --break-system-packages -q 'litellm[proxy]' 'httpx[socks]' 'ddgs' 2>/dev/null; then
    # Debian/Ubuntu: บาง package (เช่น PyYAML) ติดตั้งโดย apt ทำให้ pip ไม่สามารถ uninstall ได้
    pip install --break-system-packages --ignore-installed -q 'litellm[proxy]' 'httpx[socks]' 'ddgs'
fi
echo "      สำเร็จ"

# 2. คัดลอก config files
echo "[2/5] คัดลอก config files..."
mkdir -p ~/.claude
mkdir -p /root/litellm_hooks
cp litellm_config.yaml ~/.claude/
cp start-litellm.sh ~/.claude/ && chmod +x ~/.claude/start-litellm.sh
cp claude-local /usr/local/bin/claude-local && chmod +x /usr/local/bin/claude-local
cp tailscale-forward /usr/local/bin/tailscale-forward && chmod +x /usr/local/bin/tailscale-forward
cp litellm_hooks/system_prompt_hook.py /root/litellm_hooks/system_prompt_hook.py
echo "      สำเร็จ"

# 3. เลือกโหมดการเชื่อมต่อ
echo ""
echo "[3/5] เลือกโหมดการเชื่อมต่อ"
echo "      1) Local  — รัน Claude Code และ llama.cpp บนเครื่องเดียวกัน"
echo "      2) LAN    — llama.cpp อยู่ในวงเดียวกัน (ใช้ IP ปกติ)"
echo "      3) Tailscale — llama.cpp อยู่นอก LAN"
read -p "      เลือก [1/2/3]: " MODE

if [ "$MODE" = "1" ]; then
    echo ""
    echo "[4/5] ตั้งค่า Local mode..."
    read -p "      PORT ของ llama.cpp (default 8080): " LOCAL_PORT
    LOCAL_PORT="${LOCAL_PORT:-8080}"
    LLAMA_URL="http://127.0.0.1:$LOCAL_PORT/v1"

    echo "      ทดสอบการเชื่อมต่อ $LLAMA_URL ..."
    if curl -s --max-time 5 "$LLAMA_URL/models" > /dev/null; then
        echo "      เชื่อมต่อสำเร็จ"
    else
        echo "      คำเตือน: เชื่อมต่อไม่ได้ตอนนี้ (ตรวจสอบว่า llama.cpp รันอยู่)"
    fi

    set_env "LLAMA_API_BASE" "$LLAMA_URL"
    echo "      ตั้งค่า LLAMA_API_BASE=$LLAMA_URL"

elif [ "$MODE" = "3" ]; then
    # ติดตั้ง Tailscale
    echo ""
    echo "[4/5] ติดตั้ง Tailscale..."
    if ! command -v tailscale &>/dev/null; then
        curl -fsSL https://tailscale.com/install.sh | sh
        echo "      ติดตั้งสำเร็จ"
    else
        echo "      Tailscale ติดตั้งแล้ว ($(tailscale version 2>/dev/null | head -1))"
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
    echo "      กรุณา login Tailscale..."
    tailscale up || true
    echo ""
    echo "      รอให้ login เสร็จแล้วกด Enter"
    read -p "      " _
    tailscale status 2>/dev/null || true

    # ให้ใส่ Tailscale IP
    echo ""
    read -p "      ใส่ Tailscale IP ของเครื่องที่รัน llama.cpp (เช่น 100.89.99.41): " TS_IP
    read -p "      PORT ของ llama.cpp (default 8080): " TS_PORT
    TS_PORT="${TS_PORT:-8080}"

    LLAMA_URL="http://$TS_IP:$TS_PORT/v1"
    set_env "LLAMA_API_BASE" "$LLAMA_URL"
    set_env "TAILSCALE_SOCKS5" "localhost:1055"
    echo "      ตั้งค่า LLAMA_API_BASE=$LLAMA_URL"
    echo "      ตั้งค่า TAILSCALE_SOCKS5=localhost:1055"

else
    echo ""
    echo "[4/5] ตั้งค่า LAN mode..."
    read -p "      ใส่ IP และ PORT ของ llama.cpp server (เช่น 192.168.1.100:8080): " HOST
    LLAMA_URL="http://$HOST/v1"

    # ทดสอบการเชื่อมต่อ
    echo "      ทดสอบการเชื่อมต่อ $LLAMA_URL ..."
    if curl -s --max-time 5 "$LLAMA_URL/models" > /dev/null; then
        echo "      เชื่อมต่อสำเร็จ"
    else
        echo "      คำเตือน: เชื่อมต่อไม่ได้ตอนนี้ (ตรวจสอบว่า llama.cpp รันอยู่)"
    fi

    set_env "LLAMA_API_BASE" "$LLAMA_URL"
fi

# 5. สรุป
echo ""
echo "[5/5] เสร็จเรียบร้อย"
echo ""
echo "=== ติดตั้งสำเร็จ ==="
echo ""
echo "วิธีใช้:"
echo "  claude-local              เปิด interactive session"
echo "  claude-local -p 'คำถาม'  ถามแบบ one-shot"
echo ""
echo "ค่าที่ตั้งไว้ใน $SHELL_RC (โหลดอัตโนมัติเมื่อเปิด terminal ใหม่)"
