# Claude Code + Local LLM (llama.cpp)

ใช้งาน Claude Code กับ model ภาษาท้องถิ่น ผ่าน LiteLLM proxy พร้อม WebSearch ด้วย DuckDuckGo (ไม่ต้องใช้ API key)

## สถาปัตยกรรม

```
Claude Code  →  LiteLLM proxy (:4000)  →  llama.cpp server
  [Anthropic API format]    ↑               [OpenAI-compatible]
                     system_prompt_hook
                     (WebSearch via ddgs)
```

---

## ความต้องการ

- Python 3.x + pip
- [llama.cpp](https://github.com/ggerganov/llama.cpp) server รันอยู่
- Claude Code CLI (`npm install -g @anthropic-ai/claude-code`)

---

## การติดตั้ง

```bash
git clone https://github.com/boyaideveloper-oss/claude-local-setup.git
cd claude-local-setup
bash install.sh
```

script จะถามโหมดการเชื่อมต่อ:

```
[3/5] เลือกโหมดการเชื่อมต่อ
      1) Local     — Claude Code และ llama.cpp อยู่บนเครื่องเดียวกัน
      2) LAN       — llama.cpp อยู่เครื่องอื่นในวง LAN
      3) Tailscale — llama.cpp อยู่นอก LAN (ต่างบ้าน / มือถือ)
```

---

## โหมด 1 — Local (เครื่องเดียวกัน)

ใช้เมื่อ: รัน Claude Code และ llama.cpp บนเครื่องเดียวกัน

```
Claude Code → LiteLLM (:4000) → 127.0.0.1:8080 → llama.cpp
```

**ขั้นตอน:**

```bash
bash install.sh
# เลือก: 1
# PORT ของ llama.cpp (default 8080): [Enter]
```

ตั้งค่าที่ได้: `LLAMA_API_BASE=http://127.0.0.1:8080/v1`

---

## โหมด 2 — LAN

ใช้เมื่อ: llama.cpp รันบนเครื่องอื่นในบ้าน/ออฟฟิศวงเดียวกัน

```
Claude Code → LiteLLM (:4000) → 192.168.x.x:8080 → llama.cpp
```

**ขั้นตอน:**

```bash
bash install.sh
# เลือก: 2
# IP:PORT: 192.168.1.100:8080
```

**หา IP ของเครื่องที่รัน llama.cpp:**

```bash
# Linux
ip addr show | grep "inet "

# macOS
ifconfig | grep "inet "

# Windows
ipconfig
```

ตั้งค่าที่ได้: `LLAMA_API_BASE=http://192.168.1.100:8080/v1`

---

## โหมด 3 — Tailscale (นอก LAN)

ใช้เมื่อ: llama.cpp รันอยู่บ้านแต่อยากใช้จากที่อื่น หรือใช้จากมือถือ

```
Claude Code → LiteLLM (:4000) → localhost:18080 → Tailscale → llama.cpp
```

**ขั้นตอน:**

1. ติดตั้ง Tailscale บนทั้งสองเครื่อง login account เดียวกัน

2. หา Tailscale IP ของเครื่องที่รัน llama.cpp:
```bash
tailscale status
# ได้ IP รูปแบบ 100.x.x.x
```

3. รัน install.sh:
```bash
bash install.sh
# เลือก: 3
# ใส่ Tailscale IP: 100.x.x.x
# PORT: 8080
```

ตั้งค่าที่ได้: `LLAMA_API_BASE=http://100.x.x.x:8080/v1` + `TAILSCALE_SOCKS5=localhost:1055`

---

## การใช้งาน

```bash
# เปิด interactive session
claude-local

# ถามแบบ one-shot
claude-local -p "ราคาทองวันนี้เท่าไร"
```

`claude-local` จะ:
1. ตรวจสอบ network อัตโนมัติ (LAN หรือ Tailscale)
2. ดึงชื่อ model จาก llama.cpp
3. Start LiteLLM proxy บน port 4000
4. เปิด Claude Code พร้อมใช้งาน

---

## ฟีเจอร์ WebSearch

hook ที่ติดตั้งมาจะ intercept การค้นหาและใช้ DuckDuckGo แทน (ไม่ต้องมี API key)

```
User: "ราคาทองวันนี้"
  → hook รัน ddgs.text("ราคาทองวันนี้")
  → ส่งผลลัพธ์จริงให้ model สรุป
  → ตอบพร้อม source links
```

ทดสอบ WebSearch โดยตรง:

```bash
curl -s -X POST http://localhost:4000/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: dummy" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "local",
    "max_tokens": 2048,
    "messages": [{"role": "user", "content": "ราคาทองวันนี้"}],
    "tools": [{"name": "web_search", "type": "web_search_20250305"}]
  }'
```

---

## ไฟล์ที่ติดตั้ง

| ไฟล์ในโปรเจกต์ | ติดตั้งที่ | หน้าที่ |
|---|---|---|
| `claude-local` | `/usr/local/bin/claude-local` | คำสั่งหลัก |
| `tailscale-forward` | `/usr/local/bin/tailscale-forward` | TCP port forwarder ผ่าน Tailscale |
| `litellm_config.yaml` | `~/.claude/litellm_config.yaml` | config LiteLLM proxy |
| `litellm_hooks/system_prompt_hook.py` | `/root/litellm_hooks/system_prompt_hook.py` | hook WebSearch + system prompt |

---

## แก้ไขปัญหา

**proxy ไม่ start / เชื่อมต่อไม่ได้**
```bash
cat /tmp/litellm.log
curl http://localhost:4000/health
```

**ไม่สามารถเชื่อมต่อ llama.cpp**
```bash
# ทดสอบตรงๆ
curl $LLAMA_API_BASE/models

# ตรวจสอบว่า llama.cpp รันอยู่และเปิด port ถูกต้อง
# llama.cpp ต้อง start ด้วย --host 0.0.0.0 ถ้าต้องการให้เครื่องอื่นเข้าถึงได้
./llama-server -m model.gguf --host 0.0.0.0 --port 8080
```

**WebSearch ไม่ทำงาน**
```bash
python3 -c "from ddgs import DDGS; print(list(DDGS().text('test', max_results=1)))"
tail -20 /tmp/litellm_debug.log
```

**Debian/Ubuntu: ติดตั้ง package ไม่ได้ (PyYAML error)**

install.sh จัดการให้อัตโนมัติด้วย `--ignore-installed` แต่ถ้ายังติดปัญหา:
```bash
pip install --break-system-packages --ignore-installed 'litellm[proxy]' 'httpx[socks]' 'ddgs'
```
