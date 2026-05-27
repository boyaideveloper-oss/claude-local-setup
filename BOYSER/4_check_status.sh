#!/system/bin/sh
# ==============================================================================
# Script Name : 4. BOYSER CHECK STATUS
# Developer   : BOYSER DEV • บอยเซอร์
# ==============================================================================

G='\e[01;32m'; R='\e[01;31m'; Y='\e[01;33m'; C='\e[01;36m'; W='\e[01;37m'; N='\e[00;37;40m'
PASS="${G}✅ PASS${N}"
FAIL="${R}❌ FAIL${N}"
WARN="${Y}⚠️  WARN${N}"

TIKTOK_PKG=""
for pkg in com.zhiliaoapp.musically com.ss.android.ugc.trill; do
    pm list packages 2>/dev/null | grep -q "$pkg" && TIKTOK_PKG="$pkg" && break
done

score=0
total=0

check() {
    local label="$1"
    local result="$2"
    local status="$3"
    total=$((total+1))
    [ "$status" = "pass" ] && score=$((score+1))
    local icon
    case "$status" in
        pass) icon="$PASS" ;;
        fail) icon="$FAIL" ;;
        *)    icon="$WARN" ;;
    esac
    printf "  %-38s %b  %s\n" "$label" "$icon" "$result"
}

clear
echo -e "\n${C}╔══════════════════════════════════════════════════════════╗${N}"
echo -e "${C}║${Y}      🔍 BOYSER [STEP 4] : CHECK STATUS (TikTok)      ${C}║${N}"
echo -e "${C}╚══════════════════════════════════════════════════════════╝${N}"
echo -e "${W}📅 $(date '+%d %B %Y | %H:%M:%S')${N}\n"

# ─────────────────────────────────────────
echo -e "${C}━━━ [1] DEVICE PROPS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
BRAND=$(getprop ro.product.brand)
MODEL=$(getprop ro.product.model)
SDK=$(getprop ro.build.version.sdk)
FP=$(getprop ro.build.fingerprint)
BOARD=$(getprop ro.product.board)

[ "$BRAND" = "samsung" ] || [ "$BRAND" = "google" ] || [ -z "$BRAND" ] \
    && check "Brand (ไม่ใช่ Samsung/Google)" "$BRAND" "fail" \
    || check "Brand (spoofed)" "$BRAND" "pass"

[ "$SDK" -ge 33 ] 2>/dev/null \
    && check "SDK version (≥33)" "$SDK" "pass" \
    || check "SDK version (≥33)" "$SDK" "fail"

echo -e "  ${W}Fingerprint: ${C}$(echo "$FP" | cut -c1-55)...${N}"
echo -e "  ${W}Board: ${C}$BOARD${N}\n"

# ─────────────────────────────────────────
echo -e "${C}━━━ [2] MODULES & INTEGRITY ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"

# TrickyStore
TS_COUNT=$(ps -A 2>/dev/null | grep -c TrickyStore)
[ "$TS_COUNT" -gt 0 ] \
    && check "TrickyStore daemon" "${TS_COUNT} process" "pass" \
    || check "TrickyStore daemon" "ไม่รัน" "fail"

# keybox
[ -f /data/adb/tricky_store/keybox.xml ] \
    && check "keybox.xml" "$(wc -c < /data/adb/tricky_store/keybox.xml) bytes" "pass" \
    || check "keybox.xml" "ไม่พบ" "fail"

# PIF
if [ -f /data/adb/modules/playintegrityfix/custom.pif.prop ]; then
    PIF_BRAND=$(grep "^BRAND=" /data/adb/modules/playintegrityfix/custom.pif.prop 2>/dev/null | cut -d= -f2)
    check "PlayIntegrityFix (custom.pif.prop)" "$PIF_BRAND" "pass"
elif [ -f /data/adb/modules/playintegrityfix/pif.prop ]; then
    PIF_BRAND=$(grep "^BRAND=" /data/adb/modules/playintegrityfix/pif.prop 2>/dev/null | cut -d= -f2)
    check "PlayIntegrityFix (pif.prop)" "$PIF_BRAND" "pass"
else
    check "PlayIntegrityFix" "ไม่พบ module" "fail"
fi

# Root hide (KSU allowlist หรือ Magisk denylist)
if strings /data/adb/ksu/.allowlist 2>/dev/null | grep -q "$TIKTOK_PKG"; then
    check "Root hide (KSU)" "$TIKTOK_PKG" "pass"
elif magisk --denylist ls 2>/dev/null | grep -q "$TIKTOK_PKG"; then
    check "Root hide (Magisk)" "$TIKTOK_PKG" "pass"
else
    check "Root hide" "TikTok ไม่อยู่ใน list" "warn"
fi
echo ""

# ─────────────────────────────────────────
echo -e "${C}━━━ [3] TIKTOK DETECTION ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"

if [ -z "$TIKTOK_PKG" ]; then
    echo -e "  ${Y}TikTok ไม่ได้ติดตั้ง${N}\n"
else
    DATA="/data/data/$TIKTOK_PKG"

    # machine.json
    if [ -f "$DATA/files/machine/machine.json" ]; then
        STATE=$(grep -o '"lastStateName":"[^"]*"' "$DATA/files/machine/machine.json" 2>/dev/null | cut -d'"' -f4)
        FLAGS=$(grep -o '"flags":[0-9]*' "$DATA/files/machine/machine.json" 2>/dev/null | head -1 | cut -d: -f2)
        ROLLBACK=$(grep -o '"mRollBackState":{[^}]*}' "$DATA/files/machine/machine.json" 2>/dev/null)
        STOP=$(grep -o '"mStopState":{[^}]*}' "$DATA/files/machine/machine.json" 2>/dev/null)

        case "$STATE" in
            QuietState)  check "machine.json state" "QuietState (ผ่านแล้ว)" "pass" ;;
            CheckingState) check "machine.json state" "CheckingState (กำลัง verify)" "warn" ;;
            RollBackState) check "machine.json state" "RollBackState (ตรวจพบ!)" "fail" ;;
            StopState)   check "machine.json state" "StopState (blocked!)" "fail" ;;
            *)           check "machine.json state" "$STATE" "warn" ;;
        esac

        [ "${FLAGS:-0}" = "0" ] \
            && check "Risk flags" "flags=0 (สะอาด)" "pass" \
            || check "Risk flags" "flags=$FLAGS (มี flag!)" "fail"

        [ "$ROLLBACK" = '"mRollBackState":{}' ] \
            && check "RollBack state" "ว่าง (ไม่โดน)" "pass" \
            || check "RollBack state" "มีข้อมูล! ($ROLLBACK)" "fail"
    else
        check "machine.json" "ยังไม่มี (ยังไม่ login)" "warn"
    fi

    # cert.info
    [ -f "$DATA/files/cert.info" ] \
        && check "cert.info" "EXISTS (device bound)" "pass" \
        || check "cert.info" "ยังไม่สร้าง" "warn"

    # is_new_install
    NEW_INSTALL=$(grep -o 'name="is_new_install" value="[^"]*"' "$DATA/shared_prefs/aweme-app.xml" 2>/dev/null | grep -o 'value="[^"]*"' | cut -d'"' -f2)
    [ "$NEW_INSTALL" = "0" ] \
        && check "is_new_install" "0 (warm อยู่แล้ว)" "pass" \
        || check "is_new_install" "${NEW_INSTALL:-unknown} (ใหม่ — ต้อง warm-up)" "warn"
fi
echo ""

# ─────────────────────────────────────────
echo -e "${C}━━━ [4] CONSENT STATUS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"

if [ -n "$TIKTOK_PKG" ] && [ -d "/data/data/$TIKTOK_PKG/files/keva/repo/CONSENT_SDK_KEVA" ]; then
    KEVA_BLK="/data/data/$TIKTOK_PKG/files/keva/repo/CONSENT_SDK_KEVA/CONSENT_SDK_KEVA.blk"

    check_consent() {
        local key="$1"
        local label="$2"
        local status=$(strings "$KEVA_BLK" 2>/dev/null | grep -o "\"key\":\"$key\"[^}]*\"status\":\"[^\"]*\"" | grep -o '"status":"[^"]*"' | tail -1 | cut -d'"' -f4)
        case "$(echo "$status" | tr 'a-z' 'A-Z')" in
            APPROVE) check "$label" "APPROVE ✓" "pass" ;;
            CONSENT_UNDECIDED) check "$label" "UNDECIDED (ยังไม่ accept)" "fail" ;;
            "") check "$label" "ไม่พบข้อมูล" "warn" ;;
            *) check "$label" "$status" "warn" ;;
        esac
    }

    check_consent "conditions-policy-device-consent" "Device Consent"
    check_consent "conditions-policy-tiktok-series-sale-terms" "Shop Sale Terms (SEA)"
    check_consent "conditions-policy-privacy-policy" "Privacy Policy"
else
    check "Consent data" "TikTok ยังไม่ login หรือ ไม่มีข้อมูล" "warn"
fi
echo ""

# ─────────────────────────────────────────
echo -e "${C}━━━ [5] SCORE & VERDICT ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
PCT=$((score * 100 / total))
echo -e "  ${W}Score: ${C}$score/$total (${PCT}%)${N}"

if [ "$PCT" -ge 80 ]; then
    echo -e "\n  ${G}🟢 พร้อม shop ได้เลย!${N}"
elif [ "$PCT" -ge 60 ]; then
    echo -e "\n  ${Y}🟡 เกือบพร้อม — ยังมีจุดที่ต้องแก้${N}"
else
    echo -e "\n  ${R}🔴 ยังไม่พร้อม — ต้องแก้ก่อน${N}"
fi
echo -e "\n${C}════════════════════════════════════════════════════════════${N}\n"
