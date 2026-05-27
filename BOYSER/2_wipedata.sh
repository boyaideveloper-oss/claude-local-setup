#!/system/bin/sh
# ==============================================================================
# Script Name : 2. BOYSER WIPE DATA (Thanos Snap)
# Developer   : BOYSER DEV • บอยเซอร์
# ==============================================================================

G='\e[01;32m'; R='\e[01;31m'; Y='\e[01;33m'; C='\e[01;36m'; W='\e[01;37m'; N='\e[00;37;40m'
TIKTOK_ASIA="/data/data/com.ss.android.ugc.trill"
TIKTOK_INDO="/data/data/com.zhiliaoapp.musically"

show_banner() {
    clear
    # ดึงค่าแบรนด์ โมเดล และรหัสจำลองจากระบบ Android ณ ปัจจุบัน
    CUR_BRAND=$(getprop ro.product.brand | tr 'a-z' 'A-Z')
    CUR_MODEL=$(getprop ro.product.model)
    CUR_RELEASE=$(getprop ro.build.version.release)
    CUR_DATE=$(date '+%d %B %Y | %H:%M:%S')

    echo -e "\n${C}╔══════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║${Y}      🚀 BOYSER [STEP 2] : WIPE DATA (THANOS SNAP)   ${C}║${N}"
    echo -e "${C}╚══════════════════════════════════════════════════════════╝${N}"
    echo -e "${G}             ผู้พัฒนา : BOYSER DEV • บอยเซอร์${N}\n"
    echo -e "${W}📅 เวลาปัจจุบัน : ${C}$CUR_DATE${N}"
    echo -e "${W}📱 โมเดลปัจจุบัน : ${G}$CUR_BRAND $CUR_MODEL ${Y}(Android $CUR_RELEASE)${N}"
    echo -e "${C}════════════════════════════════════════════════════════════${N}\n"
}

# reset_network() {
#     echo -e "${Y}🌐 กำลังรีเซ็ตเครือข่าย (เปลี่ยน IP)...${N}"
#     settings put global airplane_mode_on 1
#     am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true > /dev/null 2>&1
#     sleep 3
#     settings put global airplane_mode_on 0
#     am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false > /dev/null 2>&1
#     echo -e "${G}✅ รีเซ็ต IP สำเร็จ${N}\n"
# }

wipe_apps_data() {
    echo -e "${Y}🧹 กำลังบังคับหยุดและล้างข้อมูลแอปพลิเคชัน...${N}"
    APPS_LIST=(
        "com.microsoft.office.outlook" "org.bromite.chromium" "id.dana" "verde.vpn.android"
        "net.upx.proxy.browser" "com.lemurbrowser.exts" "com.kiwibrowser.browser" "mark.via.gp"
        "org.bromite.bromite" "mobi.mgeek.TunnyBrowser" "com.lazada.android" "com.tokopedia.tkpd"
        "com.facebook.katana" "com.facebook.orca" "air.kukulive.mailnow" "jp.naver.line.android"
        "com.ss.android.ugc.trill" "com.zhiliaoapp.musically"
        "com.google.android.gms" "com.google.android.gsf" "com.android.vending" "com.android.chrome"
        "com.google.android.webview" "com.android.webview" "com.google.android.apps.restore"
        "com.google.android.carriersetup" "com.google.android.configupdater" "com.google.android.ext.services"
        "com.google.android.ext.shared" "com.google.android.feedback" "com.google.android.partnersetup"
        "com.google.android.projection.gearhead" "com.google.android.setupwizard" "com.google.android.tts"
        "com.google.android.syncadapters.calendar" "com.google.android.syncadapters.contacts"
        "com.android.wifi.resources" "com.android.wifi.resources.xiaomi_sdm660"
    )

    for app in "${APPS_LIST[@]}"; do
        if pm list packages | grep -q "$app"; then
            am force-stop "$app" > /dev/null 2>&1
            pm clear "$app" > /dev/null 2>&1
            echo -e "  ${C}Cleared:${N} $app"
        fi
    done
    echo -e "${G}✅ ล้างข้อมูลแอปสำเร็จ${N}\n"
}

deep_clean_tiktok() {
    echo -e "${Y}🎯 กำลังทำลายร่องรอย (Deep Clean) ของ TikTok...${N}"
    for path in "$TIKTOK_ASIA" "$TIKTOK_INDO"; do
        rm -rf "$path/app_pns_sdk" 2>/dev/null
        rm -rf "$path/app_textures" 2>/dev/null
        rm -f "$path/shared_prefs/device_id.xml" 2>/dev/null
    done
    echo -e "${G}✅ ทำลายร่องรอย TikTok สำเร็จ${N}\n"
}

# 🗑️ 6. ฟังก์ชันล้างไฟล์ขยะระบบและล้างความจำเครื่อง (Safe Zone)
wipe_system_junk() {
    echo -e "${Y}🗑️ กำลังล้างไฟล์ขยะระบบและลบข้อมูลความจำเครื่องทั้งหมด...${N}"
    
    # 1. เคลียร์แคชระบบ
    rm -rf /data/system/ifw/*.xml 2>/dev/null
    rm -rf /data/system/users/userlist.xml 2>/dev/null
    rm -rf /data/system/graphicsstats/* 2>/dev/null
    rm -rf /data/system/package_cache/* 2>/dev/null
    
    rm -rf /data/dalvik-cache/* 2>/dev/null
    rm -rf /data/cache/* 2>/dev/null
    rm -rf /cache/* 2>/dev/null
    
    # 2. 💣 ล้างบางความจำเครื่อง (Internal Storage) โดยละเว้นโฟลเดอร์ BOYSER 💣
    echo -e "  ${Y}กำลังสแกนหาไฟล์ใน /storage/emulated/0/...${N}"
    
    ls -A /storage/emulated/0 2>/dev/null | while read -r item; do
        if [ "$item" != "BOYSER" ]; then
            # ถ้าไม่ใช่ BOYSER ลบเรียบ! (โฟลเดอร์ Android, DCIM, Download, ไฟล์ซ่อน โดนหมด)
            rm -rf "/storage/emulated/0/$item" 2>/dev/null
        else
            # ถ้าเจอโฟลเดอร์ BOYSER ให้ข้ามการลบ
            echo -e "  ${G}🛡️ ข้ามการลบโฟลเดอร์สำคัญ: ${W}$item${N}"
        fi
    done
    
    # 3. ลบ Logs ซ่อนต่างๆ เพื่อปิดรอยเท้า
    rm -rf /data/anr/* 2>/dev/null
    rm -rf /data/tombstones/* 2>/dev/null
    rm -rf /data/system/dropbox/* 2>/dev/null
    rm -rf /data/system/usagestats/* 2>/dev/null
    rm -rf /data/log/* 2>/dev/null
    rm -rf /data/*.log 2>/dev/null
    rm -rf /data/local/tmp/* 2>/dev/null

    # ==========================================
    # ☢️ THE THANOS SNAP (ล้างบางระดับฮาร์ดแวร์) ☢️
    # ==========================================
    echo -e "  ${R}☢️ กำลังล้างข้อมูลระดับลึกสุด (Keystore, Battery, Network)...${N}"
    
    # 4. ล้างประวัติแบตเตอรี่ (หลอกว่าเครื่องเพิ่งแกะกล่องแบต 100%)
    rm -f /data/system/batterystats.bin 2>/dev/null
    rm -f /data/system/batterystats-checkin.bin 2>/dev/null
    
    # 5. ล้างกุญแจเข้ารหัส (Keystore & DRM)
    rm -rf /data/misc/keystore/user_0/* 2>/dev/null
    rm -rf /data/mediadrm/IDM* 2>/dev/null
    
    # 6. ล้างประวัติเครือข่ายและ Wi-Fi (ลืม Wi-Fi เก่าให้หมด)
    rm -rf /data/misc/wifi/wpa_supplicant.conf 2>/dev/null
    rm -rf /data/misc/wifi/networkHistory.txt 2>/dev/null
    rm -rf /data/misc/ethernet/* 2>/dev/null
    rm -rf /data/misc/network_watchlist/* 2>/dev/null
    
    # 7. ระเบิดฐานข้อมูล Google (บังคับเปลี่ยน GSF ID 100%)
    rm -rf /data/data/com.google.android.gsf/databases/* 2>/dev/null
    rm -rf /data/data/com.google.android.gms/databases/gservices.db 2>/dev/null
    
    # 8. ล้าง Properties ที่ซ่อนอยู่ (พวกค่าที่แอปชอบแอบฝัง)
    rm -rf /data/property/persist.sys.* 2>/dev/null
    
    echo -e "${G}✅ ล้างความจำเครื่อง (เก็บเฉพาะ BOYSER) เสร็จสิ้น${N}\n"
}

reset_identity() {
    echo -e "${Y}🆔 กำลังรีเซ็ต Device Identity...${N}"
    rm -rf /data/system/users/0/registered_services /data/system/users/0/fpdata 2>/dev/null
    rm -rf /data/system/users/0/settings_ssaid.xml /data/system/users/0/settings_ssaid.xml.fallback 2>/dev/null
    rm -rf /data/data/com.google.android.gms/shared_prefs/adid_settings.xml 2>/dev/null

    # รีเซ็ต android_id ใน settings_secure.xml (system-wide identifier ที่ pm clear ไม่แตะ)
    local secure_xml="/data/system/users/0/settings_secure.xml"
    if [ -f "$secure_xml" ]; then
        local old_id=$(grep -o 'name="android_id" value="[^"]*"' "$secure_xml" 2>/dev/null | grep -o 'value="[^"]*"' | cut -d'"' -f2)
        if [ -n "$old_id" ]; then
            local new_id=$(cat /dev/urandom | tr -dc '0-9a-f' | head -c 16)
            sed -i "s/$old_id/$new_id/g" "$secure_xml"
            echo -e "  ${C}android_id:${N} $old_id → $new_id"
        fi
    fi

    # ล้าง Bluetooth pairing history (มี MAC address ของ device ที่เคย pair)
    rm -f /data/misc/bluedroid/bt_config.conf 2>/dev/null
    rm -f /data/misc/bluedroid/bt_config.bak 2>/dev/null

    echo -e "${G}✅ รีเซ็ต Identity สำเร็จ${N}\n"
}

show_banner
# reset_network
wipe_apps_data
deep_clean_tiktok
wipe_system_junk
reset_identity
sleep 2
exit 0