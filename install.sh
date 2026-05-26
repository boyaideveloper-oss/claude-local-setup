#!/bin/bash
set -e

echo "=== Claude Code + Local LLM Setup ==="
echo ""

# 1. ติดตั้ง LiteLLM
echo "[1/4] ติดตั้ง LiteLLM..."
pip install 'litellm[proxy]' --break-system-packages -q
echo "      สำเร็จ"

# 2. คัดลอก config files
echo "[2/4] คัดลอก config files..."
mkdir -p ~/.claude
cp litellm_config.yaml ~/.claude/
cp start-litellm.sh ~/.claude/ && chmod +x ~/.claude/start-litellm.sh
echo "      สำเร็จ"

# 3. ติดตั้ง claude-local command
echo "[3/4] ติดตั้งคำสั่ง claude-local..."
cp claude-local /usr/local/bin/claude-local && chmod +x /usr/local/bin/claude-local
echo "      สำเร็จ"

# 4. ตั้งค่า LLAMA_API_BASE
echo "[4/4] ตั้งค่า LLAMA_API_BASE..."
read -p "      ใส่ IP และ PORT ของ llama.cpp server (เช่น 192.168.1.100:8080): " HOST

LLAMA_URL="http://$HOST/v1"

# ทดสอบการเชื่อมต่อ
echo "      ทดสอบการเชื่อมต่อ $LLAMA_URL ..."
if curl -s --max-time 5 "$LLAMA_URL/models" > /dev/null; then
    echo "      เชื่อมต่อสำเร็จ"
else
    echo "      คำเตือน: ไม่สามารถเชื่อมต่อได้ตอนนี้ (ตรวจสอบว่า llama.cpp server รันอยู่)"
fi

# เพิ่มใน shell config
SHELL_RC="$HOME/.bashrc"
[ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"
[ "$SHELL" = "/bin/zsh" ] && SHELL_RC="$HOME/.zshrc"

if grep -q "LLAMA_API_BASE" "$SHELL_RC" 2>/dev/null; then
    sed -i "s|export LLAMA_API_BASE=.*|export LLAMA_API_BASE=$LLAMA_URL|" "$SHELL_RC"
    echo "      อัปเดต LLAMA_API_BASE ใน $SHELL_RC"
else
    echo "export LLAMA_API_BASE=$LLAMA_URL" >> "$SHELL_RC"
    echo "      เพิ่ม LLAMA_API_BASE ใน $SHELL_RC"
fi

export LLAMA_API_BASE="$LLAMA_URL"

echo ""
echo "=== ติดตั้งเสร็จเรียบร้อย ==="
echo ""
echo "วิธีใช้:"
echo "  claude-local              เปิด interactive session"
echo "  claude-local -p 'คำถาม'  ถามแบบ one-shot"
echo ""
echo "หากเปิด terminal ใหม่ LLAMA_API_BASE จะถูกโหลดอัตโนมัติจาก $SHELL_RC"
