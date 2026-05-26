# Claude Code + Local LLM (llama.cpp)

ใช้งาน Claude Code กับ model ภาษาท้องถิ่น ผ่าน LiteLLM proxy

## สถาปัตยกรรม

```
Claude Code  →  LiteLLM proxy (:4000)  →  llama.cpp server (:8080)
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

### 3. แก้ไข config ให้ตรงกับเครื่องของคุณ

แก้ไขไฟล์ `~/.claude/litellm_config.yaml`:

```yaml
model_list:
  - model_name: gemma-local          # ชื่อที่ใช้เรียก model
    litellm_params:
      model: openai/ชื่อไฟล์-model.gguf
      api_base: http://IP-ของเครื่อง:PORT/v1   # เปลี่ยน IP และ port
      api_key: dummy
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

**proxy ไม่ start**
```bash
# ดู log
cat /tmp/litellm.log

# start ด้วยตัวเอง
~/.claude/start-litellm.sh
```

**ไม่สามารถเชื่อมต่อ llama.cpp**
```bash
# ตรวจสอบว่า server ทำงานอยู่
curl http://192.168.68.67:8080/v1/models

# ถ้าใช้ ollama ต้อง start ก่อน
ollama serve
```

**content ว่างเปล่า**

model นี้เป็น thinking model (Gemma 4) ที่ใช้ reasoning tokens ก่อนตอบ ให้เพิ่ม `max_tokens` ใน request ให้มากพอ (แนะนำ 1024+)

---

## ทดสอบการเชื่อมต่อ

```bash
# 1. ตรวจสอบ llama.cpp server
curl http://192.168.68.67:8080/v1/models

# 2. ตรวจสอบ LiteLLM proxy
curl http://localhost:4000/health

# 3. ทดสอบ Anthropic API format ผ่าน proxy
curl http://localhost:4000/v1/messages \
  -H "Content-Type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -H "x-api-key: dummy" \
  -d '{
    "model": "gemma-local",
    "max_tokens": 500,
    "messages": [{"role": "user", "content": "สวัสดี"}]
  }'
```
