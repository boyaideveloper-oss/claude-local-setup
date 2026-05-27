# BOYSER Check Status Skill

เช็คสถานะความพร้อมของเครื่อง Android สำหรับ TikTok Shop bypass

## วิธีใช้

```
/boyser-check [serial|all|install|machine|consent]
```

- ไม่ระบุ argument → เช็คเครื่อง ADB แรกที่เชื่อมต่อ
- ระบุ serial → เช็คเครื่องนั้น เช่น `/boyser-check b9f8dc1`
- `all` → เช็คทุกเครื่องพร้อมกัน (เครื่องหลัก + ทุก ADB device)
- `install` → ติดตั้ง script บนเครื่อง
- `machine` → เช็คเฉพาะ machine.json
- `consent` → เช็คเฉพาะ consent

---

## Instructions

เมื่อ user เรียก skill นี้ให้ทำตามขั้นตอนต่อไปนี้:

### Step 1 — หา serial

ถ้าไม่มี argument:
```bash
adb devices
```
เลือก serial แรกที่ status เป็น `device`

### Step 2 — รัน check script บนเครื่อง

```bash
adb -s <serial> shell "su -c 'sh /storage/emulated/0/BOYSER/งาน/4_check_status.sh'"
```

ถ้าไม่พบ script ให้แจ้ง user ว่า "ไม่พบ 4_check_status.sh — รัน `/boyser-check install` เพื่อติดตั้งก่อน"

### Step 3 — แสดงผล

แสดง output ทั้งหมดจาก script ตามที่ได้มา

### Step 4 — วิเคราะห์และแนะนำ

หลังแสดง output ให้สรุป:

**ถ้า Score ≥ 80% (พร้อม):**
- แจ้งว่าพร้อม shop ได้
- ระบุจุดที่ยัง WARN ถ้ามี

**ถ้า Score 60-79% (เกือบพร้อม):**
- ระบุทุก FAIL และ WARN
- ให้คำแนะนำวิธีแก้แต่ละจุด

**ถ้า Score < 60% (ยังไม่พร้อม):**
- ระบุปัญหาหลัก
- แนะนำลำดับขั้นตอนที่ต้องทำ

---

## `/boyser-check all`

เช็คทุกเครื่องพร้อมกันในคำสั่งเดียว ทำตามนี้:

**1. หาเครื่องทั้งหมด:**
```bash
adb devices
```
รวบรวม serial ทุกตัวที่ status = `device`

**2. รัน parallel — เครื่องหลัก + ทุก ADB device:**
```bash
# เครื่องหลัก (chroot)
chroot /proc/1/root /system/bin/sh /storage/emulated/0/BOYSER/งาน/4_check_status.sh 2>/dev/null | grep -E "PASS|FAIL|WARN|Score|🟢|🟡|🔴|Finger|Board" &

# แต่ละ ADB device
for serial in <serial1> <serial2> ...; do
    adb -s $serial shell "su -c 'sh /storage/emulated/0/BOYSER/งาน/4_check_status.sh'" 2>/dev/null | grep -E "PASS|FAIL|WARN|Score|🟢|🟡|🔴|Finger|Board" &
done
wait
```

**3. สรุปเป็นตาราง** เปรียบเทียบทุกเครื่อง:

| รายการ | เครื่องหลัก | serial1 | serial2 | ... |
|---|---|---|---|---|
| Brand | ... | ... | ... | |
| PIF | ... | ... | ... | |
| TrickyStore | ... | ... | ... | |
| Score | X/14 | X/14 | X/14 | |

ระบุถ้าเครื่องไหนมี ❌ FAIL และแนะนำวิธีแก้

---

## คำสั่งเสริม

### `/boyser-check install [serial]`

ติดตั้ง/อัปเดต 4_check_status.sh บนเครื่อง ทำตามขั้นตอนนี้ทุกครั้ง:

**สำหรับ ADB device:**
```bash
# 1. push ไปที่ tmp ก่อน
adb -s <serial> push /proc/1/root/storage/emulated/0/BOYSER/งาน/4_check_status.sh /data/local/tmp/4_check_status.sh

# 2. สร้างโฟลเดอร์ (ถ้าไม่มี) แล้ว copy + chmod
adb -s <serial> shell "su -c 'mkdir -p /storage/emulated/0/BOYSER/งาน && cp /data/local/tmp/4_check_status.sh /storage/emulated/0/BOYSER/งาน/4_check_status.sh && chmod 755 /storage/emulated/0/BOYSER/งาน/4_check_status.sh && echo OK'"
```

**สำหรับเครื่องหลัก (chroot):** script อยู่ที่ `/proc/1/root/storage/emulated/0/BOYSER/งาน/4_check_status.sh` อยู่แล้ว

> **หมายเหตุ:** ต้องมีไฟล์ต้นฉบับอยู่บนเครื่องหลักก่อนเสมอ — ถ้าไม่มีให้สร้างใหม่จาก checklist ด้านล่าง

### `/boyser-check machine [serial]`
เช็คเฉพาะ machine.json อย่างเดียว (เร็ว):
```bash
adb -s <serial> shell "su -c 'cat /data/data/\$(pm list packages 2>/dev/null | grep -o \"com.zhiliaoapp.musically\\|com.ss.android.ugc.trill\" | head -1 | cut -d: -f2)/files/machine/machine.json 2>/dev/null'"
```
แล้ว parse state และ flags แสดงเป็น pass/fail

### `/boyser-check consent [serial]`
เช็คเฉพาะ consent status ทั้งหมด:
```bash
adb -s <serial> shell "su -c 'strings /data/data/com.zhiliaoapp.musically/files/keva/repo/CONSENT_SDK_KEVA/CONSENT_SDK_KEVA.blk 2>/dev/null | grep -o \"\\\"key\\\":\\\"[^\\\"]*\\\"[^}]*\\\"status\\\":\\\"[^\\\"]*\\\"\"'"
```
Parse และแสดงเป็นตาราง: key | status | พร้อมไหม

---

## Checklist ที่ script ตรวจ (4_check_status.sh)

| # | รายการ | ผ่านเมื่อ |
|---|---|---|
| 1 | Brand (ไม่ใช่ Samsung/Google) | brand ≠ samsung, google |
| 2 | SDK version | SDK ≥ 33 |
| 3 | TrickyStore daemon | process รันอยู่ |
| 4 | keybox.xml | ไฟล์มีอยู่ |
| 5 | PlayIntegrityFix | pif.prop หรือ custom.pif.prop มีอยู่ |
| 6 | Root hide | TikTok อยู่ใน KSU `.allowlist` **หรือ** Magisk denylist |
| 7 | machine.json state | QuietState |
| 8 | Risk flags | flags = 0 |
| 9 | RollBack state | mRollBackState = {} |
| 10 | cert.info | EXISTS ที่ `/data/data/<pkg>/files/cert.info` |
| 11 | is_new_install | = 0 (warm แล้ว) |
| 12 | Device Consent | APPROVE |
| 13 | Shop Sale Terms | APPROVE |
| 14 | Privacy Policy | APPROVE หรือ ไม่ required สำหรับ TH |

**Score 80%+ = พร้อม shop**

---

## ความรู้เรื่องเครื่อง (อัปเดต 2026-05-27)

### เครื่องหลัก (chroot via /proc/1/root)
- Root: KernelSU (KSU)
- Brand: Xiaomi (nezha profile)
- PIF: `custom.pif.prop` → ยังเป็น Google profile ⚠️ (ควรแก้)
- TikTok package: `com.ss.android.ugc.trill`
- machine.json: CheckingState (ถูก reset วันนี้ รอ warm-up)
- cert.info: EXISTS (April 27)
- Score: 11/14 (78%)

### เครื่องฟาร์ม (serial: b9f8dc1)
- Root: KernelSU (KSU)
- Brand: vivo V2355 (spoofed via service.d)
- PIF: `pif.prop` → vivo ✅
- TikTok package: `com.zhiliaoapp.musically`
- Props file: `/data/adb/boyser_vivo.prop`
- Score: 9/14 (64%) — รอ warm-up

### เครื่องใหม่ (serial: 83ca6e0c — อาจเปลี่ยน serial)
- Root: KernelSU (KSU)
- Brand: vivo V2355 (spoofed)
- PIF: `pif.prop` → vivo ✅
- TikTok package: `com.zhiliaoapp.musically`
- Score: 9/14 (64%) — รอ warm-up

### เครื่อง Infinix (serial: 634b5418)
- Root: **Magisk** (ไม่ใช่ KSU!)
- Brand: Infinix Note 60 (X6879)
- PIF: `pif.prop` v13.4 format (FIRST_API_LEVEL) → Infinix ✅
- TikTok package: `com.zhiliaoapp.musically`
- Root hide: Magisk denylist ✅
- SDK spoof: ผ่าน `MagiskHidePropsConf` module → แก้ sdk=36 แล้ว
- Props module: `/data/adb/modules/boyser_props/` (post-fs-data.sh + system.prop)
- `MagiskHidePropsConf` system.prop: ตั้ง fingerprint + SDK ทุกตัว
- Score: กำลัง verify หลัง reboot ล่าสุด

---

## สิ่งที่ต้องระวัง

### cert.info path
- **ถูก:** `/data/data/<pkg>/files/cert.info`
- **ผิด (เดิม):** `/data/data/<pkg>/shared_prefs/cert.info`
- script ถูกแก้แล้วเมื่อ 2026-05-27

### Root hide — KSU vs Magisk
- **KSU:** ตรวจจาก `strings /data/adb/ksu/.allowlist`
- **Magisk:** ตรวจจาก `magisk --denylist ls`
- script รองรับทั้งสองแบบแล้ว (ตรวจ KSU ก่อน ถ้าไม่มีตรวจ Magisk)

### SDK spoof บนเครื่อง Magisk
- ถ้า `getprop ro.build.version.sdk` = 30 ทั้งที่ fingerprint บอก Android 16
- ต้องแก้ใน `MagiskHidePropsConf/system.prop` ทุก sdk variant (6 ตัว)
- `post-fs-data.sh` ใน custom module มักช้าเกินไป — MagiskHidePropsConf inject เร็วกว่า

### machine.json
- `CheckingState` ปกติ ถ้าเพิ่ง: login ใหม่, รัน 3_spoofing_v2.sh, หรือ wipedata
- `QuietState` = trusted device (ใช้เวลา 3-5 วัน warm-up)
- timestamp ของ machine.json บอกได้ว่าเพิ่ง reset หรือเปล่า

---

## หมายเหตุ

- script อยู่ที่: `/storage/emulated/0/BOYSER/งาน/4_check_status.sh`
- ต้องการ root (KernelSU/Magisk) บนเครื่อง
- ใช้คู่กับ `3_spoofing_v2.sh` และ `2_wipedata.sh`
- machine.json จาก `CheckingState` → `QuietState` ต้องใช้เวลา warm-up 3-5 วัน
