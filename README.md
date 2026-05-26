# Claude Code + Local LLM (llama.cpp)

ใช้งาน Claude Code กับ model ภาษาท้องถิ่น ผ่าน LiteLLM proxy

## สถาปัตยกรรม

```
Claude Code  →  LiteLLM proxy (:4000)  →  llama.cpp server
  [Anthropic API format]                  [OpenAI-compatible format]
```

LiteLLM ทำหน้าที่แปลง Anthropic API format ให้เป็น OpenAI format ที่ llama.cpp รองรับ

---

## ความต้องการ

- Python 3.x
- [llama.cpp](https://github.com/ggerganov/llama.cpp) server รันอยู่
- Claude Code CLI (`claude`)

---

## การติดตั้ง

### 1. ติดตั้ง LiteLLM

```bash
pip install 'litellm[proxy]' --break-system-packages
```

### 2. คัดลอก config files

```bash
# สร้างโฟลเดอร์ถ้ายังไม่มี
mkdir -p ~/.claude

# คัดลอก config
cp litellm_config.yaml ~/.claude/litellm_config.yaml
cp start-litellm.sh ~/.claude/start-litellm.sh
chmod +x ~/.claude/start-litellm.sh

# คัดลอก wrapper script
cp claude-local /usr/local/bin/claude-local
chmod +x /usr/local/bin/claude-local
```

### 3. ตั้งค่า IP และ Port ของ llama.cpp server

ไม่ต้องแก้ไขไฟล์ config ใดๆ แค่ตั้ง environment variable ก่อนใช้งาน:

```bash
export LLAMA_API_BASE=http://<IP-เครื่องที่รัน-llama.cpp>:<PORT>/v1
```

**ตัวอย่าง:**

```bash
# llama.cpp รันบนเครื่องเดียวกัน
export LLAMA_API_BASE=http://localhost:8080/v1

# llama.cpp รันบนเครื่องอื่นในวง LAN
export LLAMA_API_BASE=http://192.168.1.100:8080/v1
```

ตรวจสอบ IP และ port ของ llama.cpp server:

```bash
curl http://<IP>:<PORT>/v1/models
```

เพื่อให้ไม่ต้อง export ทุกครั้ง ให้เพิ่มบรรทัดนี้ใน `~/.bashrc` หรือ `~/.zshrc`:

```bash
echo 'export LLAMA_API_BASE=http://<IP>:<PORT>/v1' >> ~/.bashrc
source ~/.bashrc
```

---

## ไฟล์ในโปรเจกต์

| ไฟล์ | ตำแหน่งติดตั้ง | หน้าที่ |
|------|--------------|---------|
| `litellm_config.yaml` | `~/.claude/litellm_config.yaml` | กำหนด model และ endpoint |
| `start-litellm.sh` | `~/.claude/start-litellm.sh` | script เริ่ม proxy |
| `claude-local` | `/usr/local/bin/claude-local` | คำสั่งสำหรับใช้งาน |

---

## การใช้งาน

```bash
# ตั้งค่า IP ก่อน (ทำครั้งเดียว หรือเพิ่มใน ~/.bashrc)
export LLAMA_API_BASE=http://192.168.1.100:8080/v1

# เปิด interactive session
claude-local

# ถามแบบ one-shot
claude-local -p "เขียน function Python อ่านไฟล์ CSV"

# ทดสอบว่า proxy ทำงานอยู่
curl http://localhost:4000/health
```

คำสั่ง `claude-local` จะเริ่ม LiteLLM proxy อัตโนมัติถ้ายังไม่ได้รัน

---

## แก้ไขปัญหา

**ลืมตั้ง LLAMA_API_BASE**
```bash
export LLAMA_API_BASE=http://<IP>:<PORT>/v1
```

**proxy ไม่ start**
```bash
# ดู log
cat /tmp/litellm.log

# start ด้วยตัวเอง
LLAMA_API_BASE=http://<IP>:<PORT>/v1 ~/.claude/start-litellm.sh
```

**ไม่สามารถเชื่อมต่อ llama.cpp**
```bash
# ตรวจสอบว่า server ทำงานอยู่
curl $LLAMA_API_BASE/models

# ถ้าใช้ ollama ต้อง start ก่อน
ollama serve
```

**content ว่างเปล่า**

model บางตัวเป็น thinking model ที่ใช้ reasoning tokens ก่อนตอบ ให้เพิ่ม `max_tokens` ใน request ให้มากพอ (แนะนำ 1024+)

---

## ทดสอบการเชื่อมต่อ

```bash
# 1. ตรวจสอบ llama.cpp server
curl $LLAMA_API_BASE/models

# 2. ตรวจสอบ LiteLLM proxy
curl http://localhost:4000/health

# 3. ทดสอบ Anthropic API format ผ่าน proxy
curl http://localhost:4000/v1/messages \
  -H "Content-Type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -H "x-api-key: dummy" \
  -d '{
    "model": "local",
    "max_tokens": 500,
    "messages": [{"role": "user", "content": "สวัสดี"}]
  }'
```
