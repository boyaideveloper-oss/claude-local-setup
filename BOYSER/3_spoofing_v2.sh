#!/system/bin/sh
# ==============================================================================
# Script Name : 3. BOYSER SPOOFING (Deep System Build) v2
# Developer   : BOYSER DEV • บอยเซอร์ / ปรับปรุง: Claude Sonnet 4.6
# แก้ไข: SDK version, PIF sync, TikTok cache clear, MAC randomize, hardware props
# ==============================================================================

G='\e[01;32m'; R='\e[01;31m'; Y='\e[01;33m'; C='\e[01;36m'; W='\e[01;37m'; N='\e[00;37;40m'

show_banner() {
    clear
    CUR_BRAND=$(getprop ro.product.brand | tr 'a-z' 'A-Z')
    CUR_MODEL=$(getprop ro.product.model)
    CUR_RELEASE=$(getprop ro.build.version.release)
    CUR_DATE=$(date '+%d %B %Y | %H:%M:%S')

    echo -e "\n${C}╔══════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║${Y}      🚀 BOYSER [STEP 3] : DEEP SPOOFING v2           ${C}║${N}"
    echo -e "${C}╚══════════════════════════════════════════════════════════╝${N}"
    echo -e "${G}             ผู้พัฒนา : BOYSER DEV • บอยเซอร์${N}\n"
    echo -e "${W}📅 เวลาปัจจุบัน : ${C}$CUR_DATE${N}"
    echo -e "${W}📱 โมเดลปัจจุบัน : ${G}$CUR_BRAND $CUR_MODEL ${Y}(Android $CUR_RELEASE)${N}"
    echo -e "${C}════════════════════════════════════════════════════════════${N}\n"
}

generate_build_id() {
    local android_ver="$1"
    local pre
    case "$android_ver" in
        13) pre=("TP1A" "TQ1A" "TQ2A" "TQ3A");;
        14) pre=("UP1A" "UQ1A" "UQ2A");;
        15) pre=("VP1A" "VQ1A" "VQ2A");;
        16) pre=("WP1A" "WQ1A");;
        *)  pre=("UP1A");;
    esac
    local prefix="${pre[$((RANDOM % ${#pre[@]}))]}"
    printf "%s.%06d.%03d\n" "$prefix" $((RANDOM%300000+230000)) $((RANDOM%900+100))
}

generate_incremental() {
    local mdl="$1"
    local u_val=$((RANDOM%7+1))
    local x_chars=$(cat /dev/urandom | tr -dc 'A-Z' | head -c 2)
    local tail_val=$((RANDOM%900+100))
    printf "%sXXU%d%s%03d\n" "$mdl" "$u_val" "$x_chars" "$tail_val"
}

# แมป Android version → API level (SDK)
map_sdk() {
    case "$1" in
        13) echo 33 ;;
        14) echo 34 ;;
        15) echo 35 ;;
        16) echo 36 ;;
        *)  echo 35 ;;
    esac
}

# API level ที่ device เปิดตัว (สำหรับ DEVICE_INITIAL_SDK_INT ใน PIF)
map_initial_sdk() {
    case "$1" in
        16) echo 35 ;;  # ส่วนใหญ่เปิดตัวกับ Android 15 แล้วอัปเป็น 16
        15) echo 34 ;;
        14) echo 33 ;;
        13) echo 32 ;;
        *)  echo 33 ;;
    esac
}

# board/hardware ตาม brand (สำหรับ hardware props)
get_board() {
    case "$n1" in
        google)
            case "$n2" in
                husky|shiba|akita)              echo "zumapro" ;;
                caiman|komodo|tokay|comet|t56)  echo "comet" ;;
                frankel|blazer|mustang)         echo "wahoo" ;;
                oriole|raven)                   echo "oriole" ;;
                bluejay*)                       echo "bluejay" ;;
                cheetah|panther|lynx)           echo "cheetah" ;;
                *)                              echo "oriole" ;;
            esac ;;
        samsung)   echo "lahaina" ;;
        Xiaomi)    echo "taro" ;;
        OnePlus|OPPO) echo "taro" ;;
        vivo)      echo "parrot" ;;
        realme)    echo "taro" ;;
        motorola)  echo "taro" ;;
        Sony|ASUS) echo "kalama" ;;
        Nothing)   echo "kalama" ;;
        *)         echo "qcom" ;;
    esac
}

choose_device_model() {
    local choice=$1
    case $choice in
# ===== Google Pixel (Android 16 - March 2026) =====
1) modelok="GC3VE"; n1="google"; n2="husky"; n3="Pixel 8 Pro"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
2) modelok="GKWS6"; n1="google"; n2="shiba"; n3="Pixel 8"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
3) modelok="GZPF0"; n1="google"; n2="akita"; n3="Pixel 8a"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
4) modelok="GVU6C"; n1="google"; n2="cheetah"; n3="Pixel 7 Pro"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
5) modelok="GQML3"; n1="google"; n2="panther"; n3="Pixel 7"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
6) modelok="G82U8"; n1="google"; n2="lynx"; n3="Pixel 7a"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
7) modelok="GUR25"; n1="google"; n2="caiman"; n3="Pixel 9 Pro"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
8) modelok="GKWS6"; n1="google"; n2="komodo"; n3="Pixel 9 Pro XL"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
9) modelok="GP4BC"; n1="google"; n2="comet"; n3="Pixel 9 Pro Fold"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
10) modelok="GUL82"; n1="google"; n2="tokay"; n3="Pixel 9"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
11) modelok="GP4BC"; n1="google"; n2="felix"; n3="Pixel Fold"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
12) modelok="G2YBB"; n1="google"; n2="frankel"; n3="Pixel 10"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
13) modelok="GH9F8"; n1="google"; n2="blazer"; n3="Pixel 10 Pro"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16
14) modelok="GUL82"; n1="google"; n2="mustang"; n3="Pixel 10 Pro XL"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";; # Android 16

# ===== Samsung (One UI 8 / Android 16) =====
15) modelok="SM-S928B"; n1="samsung"; n2="dm3q"; n3="Galaxy S24 Ultra"; n4=16; n5="UP1A.231005.007"; n6="S928BXXS5CZD1"; n71="$n3"; brnd="samsung";; # Android 16
16) modelok="SM-S911B"; n1="samsung"; n2="dm1q"; n3="Galaxy S23"; n4=16; n5="UP1A.231005.007"; n6="S911BXXS9EZC1"; n71="$n3"; brnd="samsung";; # Android 16
17) modelok="SM-S938B"; n1="samsung"; n2="b0q"; n3="Galaxy S25 Ultra"; n4=16; n5="UP1A.231005.007"; n6="S938BXXU1AYA1"; n71="$n3"; brnd="samsung";; # Android 16
18) modelok="SM-S936B"; n1="samsung"; n2="b4q"; n3="Galaxy S25+"; n4=16; n5="UP1A.231005.007"; n6="S936BXXU1AYA1"; n71="$n3"; brnd="samsung";; # Android 16
19) modelok="SM-S931B"; n1="samsung"; n2="b3q"; n3="Galaxy S25"; n4=16; n5="UP1A.231005.007"; n6="S931BXXU1AYA1"; n71="$n3"; brnd="samsung";; # Android 16
20) modelok="SM-F956B"; n1="samsung"; n2="e5q"; n3="Galaxy Z Fold 6"; n4=16; n5="UP1A.231005.007"; n6="F956BXXU2CZD3"; n71="$n3"; brnd="samsung";; # Android 16
21) modelok="SM-F741B"; n1="samsung"; n2="r12q"; n3="Galaxy Z Flip 6"; n4=16; n5="UP1A.231005.007"; n6="F741BXXU2CZD3"; n71="$n3"; brnd="samsung";; # Android 16

# ===== Xiaomi (HyperOS 3 / Android 16) =====
22) modelok="23127PN0CG"; n1="Xiaomi"; n2="houji"; n3="Xiaomi 14"; n4=16; n5="OS3.0.301.0.WNCMIXM"; n6="OS3.0.301.0.WNCMIXM"; n71="$n3"; brnd="Xiaomi";; # Android 16
23) modelok="24030PN60G"; n1="Xiaomi"; n2="shennong"; n3="Xiaomi 15T Pro"; n4=16; n5="OS3.0.4.0.WOSEUXM"; n6="OS3.0.4.0.WOSEUXM"; n71="$n3"; brnd="Xiaomi";; # Android 16
24) modelok="2403EPC34G"; n1="Xiaomi"; n2="pearl"; n3="Xiaomi 15T"; n4=16; n5="OS3.0.3.0.WOEEUXM"; n6="OS3.0.3.0.WOEEUXM"; n71="$n3"; brnd="Xiaomi";; # Android 16
25) modelok="24122RKC7G"; n1="Xiaomi"; n2="garnet"; n3="Redmi Note 14 Pro"; n4=16; n5="OS3.0.2.0.UGOEUXM"; n6="OS3.0.2.0.UGOEUXM"; n71="$n3"; brnd="Xiaomi";; # Android 16
26) modelok="25023PC3CG"; n1="Xiaomi"; n2="peridot"; n3="Xiaomi 15 Ultra"; n4=16; n5="OS3.0.5.0.WNACNXM"; n6="OS3.0.5.0.WNACNXM"; n71="$n3"; brnd="Xiaomi";; # Android 16

# ===== OPPO (ColorOS 16 / Android 16) =====
27) modelok="CPH2687"; n1="OPPO"; n2="OP5929L1"; n3="OPPO Reno12 F"; n4=16; n5="CPH2687_16.0.3.501"; n6="CPH2687_16.0.3.501"; n71="$n3"; brnd="OPPO";; # Android 16
28) modelok="CPH2667"; n1="OPPO"; n2="OP5A6DL1"; n3="OPPO K12x"; n4=16; n5="CPH2667_16.0.3.500"; n6="CPH2667_16.0.3.500"; n71="$n3"; brnd="OPPO";; # Android 16
29) modelok="CPH2753"; n1="OPPO"; n2="OP5C2EL1"; n3="OPPO K13x"; n4=16; n5="CPH2753_16.0.3.500"; n6="CPH2753_16.0.3.500"; n71="$n3"; brnd="OPPO";; # Android 16
30) modelok="CPH2685"; n1="OPPO"; n2="OP5A8CL1"; n3="OPPO Reno12"; n4=16; n5="CPH2685_16.0.2.401"; n6="CPH2685_16.0.2.401"; n71="$n3"; brnd="OPPO";; # Android 16
31) modelok="CPH2655"; n1="OPPO"; n2="OP5B2EL1"; n3="OPPO Find X8 Pro"; n4=16; n5="CPH2655_16.0.1.300"; n6="CPH2655_16.0.1.300"; n71="$n3"; brnd="OPPO";; # Android 16

# ===== OnePlus (OxygenOS 16 / Android 16) =====
32) modelok="CPH2653"; n1="OnePlus"; n2="pineapple"; n3="OnePlus 12"; n4=16; n5="CPH2653_16.0.0.401"; n6="CPH2653_16.0.0.401"; n71="$n3"; brnd="OnePlus";; # Android 16
33) modelok="CPH2671"; n1="OnePlus"; n2="bamboo"; n3="OnePlus 12R"; n4=16; n5="CPH2671_16.0.0.402"; n6="CPH2671_16.0.0.402"; n71="$n3"; brnd="OnePlus";; # Android 16
34) modelok="CPH2689"; n1="OnePlus"; n2="opal"; n3="OnePlus Nord 5"; n4=16; n5="CPH2689_16.0.0.300"; n6="CPH2689_16.0.0.300"; n71="$n3"; brnd="OnePlus";; # Android 16

# ===== vivo (Funtouch OS 16 / Android 16) =====
35) modelok="V2444"; n1="vivo"; n2="V2444"; n3="vivo X200 Pro"; n4=16; n5="PD2444F_EX_A_16.0.0"; n6="PD2444F_EX_A_16.0.0"; n71="$n3"; brnd="vivo";; # Android 16
36) modelok="V2355"; n1="vivo"; n2="V2355"; n3="vivo X200"; n4=16; n5="PD2355F_EX_A_16.0.0"; n6="PD2355F_EX_A_16.0.0"; n71="$n3"; brnd="vivo";; # Android 16
37) modelok="V2415"; n1="vivo"; n2="V2415"; n3="vivo V50 Pro"; n4=16; n5="PD2415F_EX_A_16.0.0"; n6="PD2415F_EX_A_16.0.0"; n71="$n3"; brnd="vivo";; # Android 16

# ===== Realme (Realme UI 7 / Android 16) =====
38) modelok="RMX3888"; n1="realme"; n2="RMX3888"; n3="realme GT 7 Pro"; n4=16; n5="RMX3888_16.0.0.400"; n6="RMX3888_16.0.0.400"; n71="$n3"; brnd="realme";; # Android 16
39) modelok="RMX3870"; n1="realme"; n2="RMAX3870"; n3="realme 12 Pro+"; n4=16; n5="RMX3870_16.0.0.300"; n6="RMX3870_16.0.0.300"; n71="$n3"; brnd="realme";; # Android 16

# ===== Nothing (Nothing OS 4 / Android 16) =====
40) modelok="A063"; n1="Nothing"; n2="pacman"; n3="Nothing Phone (3)"; n4=16; n5="NothingOS-4.0.240403"; n6="NothingOS-4.0.240403"; n71="$n3"; brnd="Nothing";; # Android 16
41) modelok="A065"; n1="Nothing"; n2="starman"; n3="Nothing Phone (3a)"; n4=16; n5="NothingOS-4.0.240401"; n6="NothingOS-4.0.240401"; n71="$n3"; brnd="Nothing";; # Android 16

# ===== Motorola (Android 16) =====
42) modelok="XT2405-1"; n1="motorola"; n2="canyon"; n3="Moto Edge 50 Ultra"; n4=16; n5="U3TCS16.1-20-5"; n6="U3TCS16.1-20-5"; n71="$n3"; brnd="motorola";; # Android 16
43) modelok="XT2415-2"; n1="motorola"; n2="brooklyn"; n3="Moto G85 5G"; n4=16; n5="U3TCS16.1-15-3"; n6="U3TCS16.1-15-3"; n71="$n3"; brnd="motorola";; # Android 16

# ===== Android 15 Real Devices (Samsung Entry-Level) =====
44) modelok="SM-M146B"; n1="samsung"; n2="m14x"; n3="Galaxy M14 5G"; n4=15; n5="UP1A.231005.007"; n6="M146BXXSCDZB5"; n71="$n3"; brnd="samsung";; # Android 15
45) modelok="SM-E145F"; n1="samsung"; n2="e14x"; n3="Galaxy F14"; n4=15; n5="UP1A.231005.007"; n6="E145FXXSBDZB3"; n71="$n3"; brnd="samsung";; # Android 15
46) modelok="SM-A156B"; n1="samsung"; n2="a15x"; n3="Galaxy A15 5G"; n4=15; n5="UP1A.231005.007"; n6="A156BXXU4CXC1"; n71="$n3"; brnd="samsung";; # Android 15
47) modelok="SM-A256B"; n1="samsung"; n2="a25x"; n3="Galaxy A25 5G"; n4=15; n5="UP1A.231005.007"; n6="A256BXXU5CXC1"; n71="$n3"; brnd="samsung";; # Android 15

# ===== Android 14 Real Devices =====
48) modelok="SM-M146B"; n1="samsung"; n2="m14x"; n3="Galaxy M14 5G"; n4=14; n5="UP1A.231005.007"; n6="M146BXXS8CYB1"; n71="$n3"; brnd="samsung";; # Android 14
49) modelok="SM-E145F"; n1="samsung"; n2="e14x"; n3="Galaxy F14"; n4=14; n5="UP1A.231005.007"; n6="E145FXXU7CYC5"; n71="$n3"; brnd="samsung";; # Android 14
50) modelok="SM-A156B"; n1="samsung"; n2="a15x"; n3="Galaxy A15 5G"; n4=14; n5="UP1A.231005.007"; n6="A156BXXU3CWB1"; n71="$n3"; brnd="samsung";; # Android 14

# ===== HMD (Android 16 - May 2026) =====
51) modelok="TA-1695"; n1="HMD Global"; n2="vibe2"; n3="HMD Vibe 2 5G"; n4=16; n5="Android 16"; n6="V2.0.0.1"; n71="$n3"; brnd="HMD";;

# ===== Infinix (Android 16 - 2026) =====
52) modelok="X6879"; n1="Infinix"; n2="note60"; n3="Infinix Note 60"; n4=16; n5="Android 16"; n6="X6879_V1.0"; n71="$n3"; brnd="Infinix";;

# ===== Google Pixel รุ่นเพิ่มเติม (Android 16 QPR3) =====
53) modelok="G7NZY"; n1="google"; n2="bluejay"; n3="Pixel 6a"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";;
54) modelok="GX7AS"; n1="google"; n2="oriole"; n3="Pixel 6"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";;
55) modelok="G9S9B"; n1="google"; n2="raven"; n3="Pixel 6 Pro"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";;
56) modelok="G2KVG"; n1="google"; n2="tangorpro"; n3="Pixel Tablet"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";;
57) modelok="GJQ8R"; n1="google"; n2="t56"; n3="Pixel 9a"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";;
58) modelok="GR83Y"; n1="google"; n2="comet_fold"; n3="Pixel 10 Pro Fold"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";;
59) modelok="G9Q7C"; n1="google"; n2="akita_256"; n3="Pixel 10a"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";;

# ===== Samsung เพิ่มเติม (Android 15/16) =====
60) modelok="SM-A366B"; n1="samsung"; n2="a36x"; n3="Galaxy A36 5G"; n4=15; n5="UP1A.231005.007"; n6="A366BXXU1CYB1"; n71="$n3"; brnd="samsung";;
61) modelok="SM-F966B"; n1="samsung"; n2="q7q"; n3="Galaxy Z Fold7"; n4=16; n5="UP1A.231005.007"; n6="F966BXXU1CZA1"; n71="$n3"; brnd="samsung";;

# ===== Samsung Galaxy A Series (One UI 8.5 / Android 16) =====
62) modelok="SM-A166V"; n1="samsung"; n2="a16x"; n3="Galaxy A16 5G"; n4=16; n5="UP1A.231005.007"; n6="S166VUDS6CZB6"; n71="$n3"; brnd="samsung";;
63) modelok="SM-A276B"; n1="samsung"; n2="a27x"; n3="Galaxy A27 5G"; n4=16; n5="UP1A.231005.007"; n6="A276BXXU0AZC1"; n71="$n3"; brnd="samsung";;
64) modelok="SM-A556E"; n1="samsung"; n2="a55x"; n3="Galaxy A55 5G"; n4=16; n5="UP1A.231005.007"; n6="A556EXXUEZZDC"; n71="$n3"; brnd="samsung";;
65) modelok="SM-A356E"; n1="samsung"; n2="a35x"; n3="Galaxy A35 5G"; n4=16; n5="UP1A.231005.007"; n6="A356EXXU9ZZD9"; n71="$n3"; brnd="samsung";;
66) modelok="SM-A366E"; n1="samsung"; n2="a36x"; n3="Galaxy A36 5G"; n4=16; n5="UP1A.231005.007"; n6="A366EXXU8ZZD7"; n71="$n3"; brnd="samsung";;

67) modelok="SM-A346B"; n1="samsung"; n2="a34x"; n3="Galaxy A34 5G"; n4=16; n5="UP1A.231005.007"; n6="A346BXXU9DZD1"; n71="$n3"; brnd="samsung";;

68) modelok="GR1YH"; n1="google"; n2="bluejay2"; n3="Pixel 6 Pro"; n4=16; n5="CP11.251209.009"; n6="CP11.251209.009"; n71="$n3"; brnd="google";;
69) modelok="G6GGR"; n1="google"; n2="raven2"; n3="Pixel 6 Pro"; n4=16; n5="CP11.251209.009"; n6="CP11.251209.009"; n71="$n3"; brnd="google";;
70) modelok="GX7AS2"; n1="google"; n2="oriole2"; n3="Pixel 6"; n4=16; n5="CP11.251209.009"; n6="CP11.251209.009"; n71="$n3"; brnd="google";;
71) modelok="G7NZY2"; n1="google"; n2="bluejay3"; n3="Pixel 6a"; n4=16; n5="CP11.251209.009"; n6="CP11.251209.009"; n71="$n3"; brnd="google";;
72) modelok="G94XW"; n1="google"; n2="panther2"; n3="Pixel 7 Pro"; n4=16; n5="CP11.251209.009"; n6="CP11.251209.009"; n71="$n3"; brnd="google";;
73) modelok="GQML32"; n1="google"; n2="panther3"; n3="Pixel 7"; n4=16; n5="CP11.251209.009"; n6="CP11.251209.009"; n71="$n3"; brnd="google";;
74) modelok="G82U82"; n1="google"; n2="lynx2"; n3="Pixel 7a"; n4=16; n5="CP11.251209.009.A1"; n6="CP11.251209.009.A1"; n71="$n3"; brnd="google";;
75) modelok="G9S9B2"; n1="google"; n2="raven3"; n3="Pixel 6 Pro"; n4=16; n5="CP11.251209.009.A1"; n6="CP11.251209.009.A1"; n71="$n3"; brnd="google";;

76) modelok="GC3VE2"; n1="google"; n2="husky2"; n3="Pixel 8 Pro"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";;
77) modelok="GKWS62"; n1="google"; n2="shiba2"; n3="Pixel 8"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";;

78) modelok="FP5"; n1="Fairphone"; n2="FP5"; n3="Fairphone 5"; n4=15; n5="AQ3A.240912.001"; n6="VT2I"; n71="$n3"; brnd="Fairphone";;

79) modelok="SM-M336B"; n1="samsung"; n2="m33x"; n3="Galaxy M33 5G"; n4=16; n5="UP1A.231005.007"; n6="M336BXXU8DZD1"; n71="$n3"; brnd="samsung";;
80) modelok="SM-M176B"; n1="samsung"; n2="m17x"; n3="Galaxy M17 5G"; n4=16; n5="UP1A.231005.007"; n6="M176BXXU1CZA1"; n71="$n3"; brnd="samsung";;
81) modelok="SM-M066B"; n1="samsung"; n2="m06x"; n3="Galaxy M06 5G"; n4=16; n5="UP1A.231005.007"; n6="M066BXXU2CZA1"; n71="$n3"; brnd="samsung";;

82) modelok="SM-F066B"; n1="samsung"; n2="f06x"; n3="Galaxy F06 5G"; n4=16; n5="UP1A.231005.007"; n6="F066BXXU2CZA1"; n71="$n3"; brnd="samsung";;

83) modelok="SM-X216B"; n1="samsung"; n2="gta9fe"; n3="Galaxy Tab S9 FE"; n4=16; n5="UP1A.231005.007"; n6="X216BXXU6DZD1"; n71="$n3"; brnd="samsung";;

84) modelok="GJQ8R2"; n1="google"; n2="t56_2"; n3="Pixel 9a"; n4=16; n5="CP1A.260305.018"; n6="14887507"; n71="$n3"; brnd="google";;

85) modelok="SM-S938U"; n1="samsung"; n2="b0q"; n3="Galaxy S25 Ultra"; n4=16; n5="UP1A.241125.017"; n6="S938USQU1AYA1"; n71="$n3"; brnd="samsung";;
86) modelok="SM-S936U"; n1="samsung"; n2="b4q"; n3="Galaxy S25+"; n4=16; n5="UP1A.241125.017"; n6="S936USQU1AYA1"; n71="$n3"; brnd="samsung";;
87) modelok="SM-S931U"; n1="samsung"; n2="b3q"; n3="Galaxy S25"; n4=16; n5="UP1A.241125.017"; n6="S931USQU1AYA1"; n71="$n3"; brnd="samsung";;
88) modelok="SM-F956U"; n1="samsung"; n2="e5q"; n3="Galaxy Z Fold 6"; n4=16; n5="UP1A.241125.017"; n6="F956USQU2CZD3"; n71="$n3"; brnd="samsung";;
89) modelok="SM-F741U"; n1="samsung"; n2="r12q"; n3="Galaxy Z Flip 6"; n4=16; n5="UP1A.241125.017"; n6="F741USQU2CZD3"; n71="$n3"; brnd="samsung";;
90) modelok="SM-A166U"; n1="samsung"; n2="a16x"; n3="Galaxy A16 5G"; n4=16; n5="UP1A.241125.017"; n6="A166USQU6CZB6"; n71="$n3"; brnd="samsung";;
91) modelok="SM-A276U"; n1="samsung"; n2="a27x"; n3="Galaxy A27 5G"; n4=16; n5="UP1A.241125.017"; n6="A276USQU0AZC1"; n71="$n3"; brnd="samsung";;
92) modelok="SM-A356U"; n1="samsung"; n2="a35x"; n3="Galaxy A35 5G"; n4=16; n5="UP1A.241125.017"; n6="A356USQU9ZZD9"; n71="$n3"; brnd="samsung";;
93) modelok="SM-A366U"; n1="samsung"; n2="a36x"; n3="Galaxy A36 5G"; n4=16; n5="UP1A.241125.017"; n6="A366USQU8ZZD7"; n71="$n3"; brnd="samsung";;
94) modelok="SM-A556U"; n1="samsung"; n2="a55x"; n3="Galaxy A55 5G"; n4=16; n5="UP1A.241125.017"; n6="A556USQUEZZDC"; n71="$n3"; brnd="samsung";;

95) modelok="24122RKC7C"; n1="Xiaomi"; n2="garnet"; n3="Redmi Note 14 Pro+"; n4=15; n5="OS2.0.2.0.UOOCNXM"; n6="OS2.0.2.0.UOOCNXM"; n71="$n3"; brnd="Xiaomi";;
96) modelok="25023PC3CI"; n1="Xiaomi"; n2="peridot"; n3="Xiaomi 15 Ultra"; n4=15; n5="OS2.0.5.0.WNACNXM"; n6="OS2.0.5.0.WNACNXM"; n71="$n3"; brnd="Xiaomi";;
97) modelok="23127PN0CI"; n1="Xiaomi"; n2="houji"; n3="Xiaomi 14"; n4=15; n5="OS2.0.301.0.WNCCNXM"; n6="OS2.0.301.0.WNCCNXM"; n71="$n3"; brnd="Xiaomi";;
98) modelok="24030PN60I"; n1="Xiaomi"; n2="shennong"; n3="Xiaomi 15T Pro"; n4=15; n5="OS2.0.4.0.WOSINXM"; n6="OS2.0.4.0.WOSINXM"; n71="$n3"; brnd="Xiaomi";;
99) modelok="2403EPC34I"; n1="Xiaomi"; n2="pearl"; n3="Xiaomi 15T"; n4=15; n5="OS2.0.3.0.WOEINXM"; n6="OS2.0.3.0.WOEINXM"; n71="$n3"; brnd="Xiaomi";;

100) modelok="CPH2655"; n1="OnePlus"; n2="pineapple"; n3="OnePlus 13"; n4=15; n5="CPH2655_15.0.0.401"; n6="CPH2655_15.0.0.401"; n71="$n3"; brnd="OnePlus";;
101) modelok="CPH2673"; n1="OnePlus"; n2="bamboo"; n3="OnePlus 13R"; n4=15; n5="CPH2673_15.0.0.402"; n6="CPH2673_15.0.0.402"; n71="$n3"; brnd="OnePlus";;
102) modelok="CPH2691"; n1="OnePlus"; n2="opal"; n3="OnePlus Nord 5"; n4=15; n5="CPH2691_15.0.0.300"; n6="CPH2691_15.0.0.300"; n71="$n3"; brnd="OnePlus";;

103) modelok="V2445"; n1="vivo"; n2="V2445"; n3="vivo X200 Pro+"; n4=15; n5="PD2445F_EX_A_15.1.0"; n6="PD2445F_EX_A_15.1.0"; n71="$n3"; brnd="vivo";;
104) modelok="V2420"; n1="vivo"; n2="V2420"; n3="vivo V50"; n4=15; n5="PD2420F_EX_A_15.0.0"; n6="PD2420F_EX_A_15.0.0"; n71="$n3"; brnd="vivo";;
105) modelok="V2405"; n1="vivo"; n2="V2405"; n3="vivo Y300"; n4=15; n5="PD2405F_EX_A_15.0.0"; n6="PD2405F_EX_A_15.0.0"; n71="$n3"; brnd="vivo";;

106) modelok="RMX3890"; n1="realme"; n2="RMX3890"; n3="realme GT 8 Pro"; n4=15; n5="RMX3890_15.0.0.400"; n6="RMX3890_15.0.0.400"; n71="$n3"; brnd="realme";;
107) modelok="RMX3880"; n1="realme"; n2="RMX3880"; n3="realme 13 Pro+"; n4=15; n5="RMX3880_15.0.0.300"; n6="RMX3880_15.0.0.300"; n71="$n3"; brnd="realme";;

108) modelok="A063_EEA"; n1="Nothing"; n2="pacman"; n3="Nothing Phone (3)"; n4=15; n5="NothingOS-3.5.240403"; n6="NothingOS-3.5.240403"; n71="$n3"; brnd="Nothing";;
109) modelok="A065_EEA"; n1="Nothing"; n2="starman"; n3="Nothing Phone (3a)"; n4=15; n5="NothingOS-3.5.240401"; n6="NothingOS-3.5.240401"; n71="$n3"; brnd="Nothing";;

110) modelok="XT2405-2"; n1="motorola"; n2="canyon"; n3="Moto Edge 50 Pro"; n4=15; n5="U3TCS15.1-20-5"; n6="U3TCS15.1-20-5"; n71="$n3"; brnd="motorola";;
111) modelok="XT2417-1"; n1="motorola"; n2="brooklyn"; n3="Moto G85 5G"; n4=15; n5="U3TCS15.1-15-3"; n6="U3TCS15.1-15-3"; n71="$n3"; brnd="motorola";;
112) modelok="XT2431-3"; n1="motorola"; n2="hawaii"; n3="Moto G75 5G"; n4=15; n5="U3TCS15.1-10-2"; n6="U3TCS15.1-10-2"; n71="$n3"; brnd="motorola";;

113) modelok="FP5_VT2I"; n1="Fairphone"; n2="FP5"; n3="Fairphone 5"; n4=15; n5="AQ3A.240912.001"; n6="VT2I"; n71="$n3"; brnd="Fairphone";;
114) modelok="FP6"; n1="Fairphone"; n2="FP6"; n3="Fairphone 6"; n4=16; n5="BQ3A.250305.002"; n6="VT3J"; n71="$n3"; brnd="Fairphone";;

115) modelok="TA-1700"; n1="HMD Global"; n2="vibe2"; n3="Nokia G60 5G"; n4=15; n5="Android 15"; n6="V1.5.0.1"; n71="$n3"; brnd="HMD";;
116) modelok="TA-1710"; n1="HMD Global"; n2="vibe3"; n3="Nokia X30 5G"; n4=15; n5="Android 15"; n6="V1.5.0.2"; n71="$n3"; brnd="HMD";;

117) modelok="GHL1X"; n1="google"; n2="bluejay4"; n3="Pixel 6a"; n4=16; n5="CP1A.260305.018"; n6="14887508"; n71="$n3"; brnd="google";;
118) modelok="G7NZY3"; n1="google"; n2="bluejay5"; n3="Pixel 6a"; n4=16; n5="CP1A.260305.018"; n6="14887509"; n71="$n3"; brnd="google";;
119) modelok="GX7AS3"; n1="google"; n2="oriole3"; n3="Pixel 6"; n4=16; n5="CP1A.260305.018"; n6="14887510"; n71="$n3"; brnd="google";;
120) modelok="G9S9B3"; n1="google"; n2="raven4"; n3="Pixel 6 Pro"; n4=16; n5="CP1A.260305.018"; n6="14887511"; n71="$n3"; brnd="google";;
121) modelok="G94XW2"; n1="google"; n2="panther4"; n3="Pixel 7 Pro"; n4=16; n5="CP1A.260305.018"; n6="14887512"; n71="$n3"; brnd="google";;

122) modelok="X6880"; n1="Infinix"; n2="note60pro"; n3="Infinix Note 60 Pro"; n4=15; n5="Android 15"; n6="X6880_V1.0"; n71="$n3"; brnd="Infinix";;
123) modelok="X6890"; n1="Infinix"; n2="zero40"; n3="Infinix Zero 40 5G"; n4=15; n5="Android 15"; n6="X6890_V1.2"; n71="$n3"; brnd="Infinix";;

124) modelok="TECNO-CK9"; n1="TECNO"; n2="camon40"; n3="TECNO Camon 40 Premier"; n4=15; n5="Android 15"; n6="CK9_V1.0"; n71="$n3"; brnd="TECNO";;
125) modelok="TECNO-SP9"; n1="TECNO"; n2="spark40"; n3="TECNO Spark 40 5G"; n4=15; n5="Android 15"; n6="SP9_V1.1"; n71="$n3"; brnd="TECNO";;

126) modelok="ASUS_AI2401_H"; n1="ASUS"; n2="zenfone12"; n3="Zenfone 12 Ultra"; n4=15; n5="AP2A.241025.001"; n6="36.1000.2501.101"; n71="$n3"; brnd="ASUS";;
127) modelok="ASUS_AI2402_H"; n1="ASUS"; n2="rog9"; n3="ROG Phone 9"; n4=15; n5="AP2A.241025.001"; n6="36.2000.2502.102"; n71="$n3"; brnd="ASUS";;

128) modelok="XQ-DQ72"; n1="Sony"; n2="pdx247"; n3="Xperia 1 VI"; n4=15; n5="67.1.A.2.200"; n6="67.1.A.2.200"; n71="$n3"; brnd="Sony";;
129) modelok="XQ-DS72"; n1="Sony"; n2="pdx248"; n3="Xperia 5 VI"; n4=15; n5="67.1.A.2.200"; n6="67.1.A.2.200"; n71="$n3"; brnd="Sony";;
130) modelok="XQ-DT72"; n1="Sony"; n2="pdx249"; n3="Xperia 10 VI"; n4=15; n5="67.1.A.2.200"; n6="67.1.A.2.200"; n71="$n3"; brnd="Sony";;

131) modelok="LG-V600AM"; n1="LG"; n2="v60"; n3="LG V60 ThinQ 5G"; n4=14; n5="RQ3A.240705.002"; n6="V600AM30f"; n71="$n3"; brnd="LG";;
132) modelok="LM-G900TM"; n1="LG"; n2="velvet"; n3="LG Velvet 5G"; n4=14; n5="RQ3A.240705.002"; n6="G900TM30e"; n71="$n3"; brnd="LG";;

133) modelok="HONOR-MAG6P"; n1="Honor"; n2="magic6pro"; n3="Honor Magic 6 Pro"; n4=15; n5="9.0.0.135"; n6="9.0.0.135C00E110R2P1"; n71="$n3"; brnd="Honor";;
134) modelok="HONOR-MAG6"; n1="Honor"; n2="magic6"; n3="Honor Magic 6"; n4=15; n5="9.0.0.135"; n6="9.0.0.135C00E110R2P1"; n71="$n3"; brnd="Honor";;
135) modelok="HONOR-200P"; n1="Honor"; n2="honor200pro"; n3="Honor 200 Pro"; n4=15; n5="9.0.0.120"; n6="9.0.0.120C00E100R1P1"; n71="$n3"; brnd="Honor";;

136) modelok="HUAWEI-P70P"; n1="HUAWEI"; n2="pura70pro"; n3="Huawei Pura 70 Pro"; n4=15; n5="4.2.0.168"; n6="4.2.0.168C00E150R1P1"; n71="$n3"; brnd="HUAWEI";;
137) modelok="HUAWEI-M60P"; n1="HUAWEI"; n2="mate60pro"; n3="Huawei Mate 60 Pro"; n4=15; n5="4.2.0.168"; n6="4.2.0.168C00E150R1P1"; n71="$n3"; brnd="HUAWEI";;

138) modelok="LENOVO-YX3"; n1="Lenovo"; n2="yoga3"; n3="Lenovo Yoga Tab 13"; n4=15; n5="AP2A.241025.001"; n6="TB-J616F_15001"; n71="$n3"; brnd="Lenovo";;
139) modelok="LENOVO-PG3"; n1="Lenovo"; n2="legion3"; n3="Lenovo Legion Tab 3"; n4=15; n5="AP2A.241025.001"; n6="TB-J616F_15002"; n71="$n3"; brnd="Lenovo";;

140) modelok="ZTE-A2025"; n1="ZTE"; n2="axon60"; n3="ZTE Axon 60 Ultra"; n4=15; n5="MyOS15.0.0"; n6="A2026_V1.0"; n71="$n3"; brnd="ZTE";;
141) modelok="ZTE-A2026"; n1="ZTE"; n2="axon61"; n3="ZTE Axon 61 Pro"; n4=15; n5="MyOS15.0.0"; n6="A2026_V1.0"; n71="$n3"; brnd="ZTE";;

        *) echo -e "${R}❌ เลือกรุ่นไม่ถูกต้อง${N}"; return 1;;
    esac
    n5=$(generate_build_id "$n4")
    n6=$(generate_incremental "$modelok")
    return 0
}

build_system_prop() {
    echo -e "${Y}⚙️ กำลังสร้างและฝังข้อมูลตัวตนระบบใหม่ (Deep Spoof แบบจัดเต็ม)...${N}"
    local dir="/data/local/tmp/system.prop"
    local diral="/data/adb/modules/MagiskHidePropsConf/system.prop"
    local dirsym="/data/adb/modules/magisk-drm-disabler/system.prop"
    rm -f $dir

    # [แก้ไข v2] คำนวณ SDK จาก Android version จริง ไม่ hardcode
    local SDK=$(map_sdk "$n4")
    local BOARD=$(get_board)

    RANDOM_USER=$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c $((6 + RANDOM % 5)))
    host="$(cat /dev/urandom | tr -dc 'A-Z' | head -c 2)$(cat /dev/urandom | tr -dc '1-9' | head -c 3)"
    keutc1="166943$(cat /dev/urandom | tr -dc '0-9' | head -c 4)"

    number=("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12")
    hr=("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun")
    tg=("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
    th=("2022" "2023" "2024" "2025" "2026")

    number3=${number[$RANDOM % ${#number[@]}]}
    hr1=${hr[$RANDOM % ${#hr[@]}]}
    tg1=${tg[$RANDOM % ${#tg[@]}]}
    th1=${th[$RANDOM % ${#th[@]}]}

    number2=$(printf "%02d" $((RANDOM%24)))
    angka3=$(printf "%02d" $((RANDOM%60)))
    wib1="UTC+07"

    valid_patch_days=("01" "05")
    random_day=${valid_patch_days[$RANDOM % ${#valid_patch_days[@]}]}

    tgl1="$hr1 $tg1 $number3 $number2:$angka3:12 $wib1 $th1"
    sec1="$th1-$number3-$random_day"
    fpp="$n1/$n2/$n2:$n4/$n5/$n6:user/release-keys"

    cat <<EOF > $dir
# MagiskHide Props Config
ro.vendor.build.security_patch=$sec1
ro.build.version.security_patch=$sec1
ro.vendor.build.date=$tgl1
ro.odm.build.date=$tgl1
ro.system.build.date=$tgl1
ro.system_ext.build.date=$tgl1
ro.product.build.date=$tgl1
ro.vendor.build.date.utc=$keutc1
ro.odm.build.date.utc=$keutc1
ro.system.build.date.utc=$keutc1
ro.system_ext.build.date.utc=$keutc1
ro.product.build.date.utc=$keutc1
ro.bootimage.build.date.utc=$keutc1
ro.build.fingerprint=$fpp
ro.bootimage.build.fingerprint=$fpp
ro.system.build.fingerprint=$fpp
ro.vendor.build.fingerprint=$fpp
ro.product.build.fingerprint=$fpp
ro.odm.build.fingerprint=$fpp
ro.system_ext.build.fingerprint=$fpp
ro.build.description=$n2-user $n4 $n5 $n6 release-keys
ro.product.name=$n2
ro.product.system.name=$n2
ro.product.vendor.name=$n2
ro.product.product.name=$n2
ro.product.odm.name=$n2
ro.product.system_ext.name=$n2
ro.product.device=$n2
ro.product.system.device=$n2
ro.product.vendor.device=$n2
ro.product.product.device=$n2
ro.product.odm.device=$n2
ro.product.system_ext.device=$n2
ro.build.version.release=$n4
ro.system.build.version.release=$n4
ro.vendor.build.version.release=$n4
ro.product.build.version.release=$n4
ro.odm.build.version.release=$n4
ro.system_ext.build.version.release=$n4
ro.build.id=$n5
ro.system.build.id=$n5
ro.vendor.build.id=$n5
ro.product.build.id=$n5
ro.odm.build.id=$n5
ro.system_ext.build.id=$n5
ro.build.version.incremental=$n6
ro.system.build.version.incremental=$n6
ro.vendor.build.version.incremental=$n6
ro.product.build.version.incremental=$n6
ro.odm.build.version.incremental=$n6
ro.system_ext.build.version.incremental=$n6
ro.build.version.release_or_codename=$n4
ro.build.display.id=$n2-user $n4 $n5 $n6 release-keys
ro.build.version.sdk=$SDK
ro.system.build.version.sdk=$SDK
ro.vendor.build.version.sdk=$SDK
ro.product.build.version.sdk=$SDK
ro.odm.build.version.sdk=$SDK
ro.system_ext.build.version.sdk=$SDK
ro.product.manufacturer=$n1
ro.product.system.manufacturer=$n1
ro.product.vendor.manufacturer=$n1
ro.product.product.manufacturer=$n1
ro.product.odm.manufacturer=$n1
ro.product.system_ext.manufacturer=$n1
ro.product.model=$modelok
ro.product.system.model=$modelok
ro.product.vendor.model=$modelok
ro.product.product.model=$modelok
ro.product.odm.model=$modelok
ro.product.system_ext.model=$modelok
ro.product.board=$BOARD
ro.hardware=$BOARD
ro.boot.verifiedbootstate=green
ro.boot.veritymode=enforcing
vendor.boot.vbmeta.device_state=locked
ro.build.type=user
ro.build.user=$RANDOM_USER
ro.build.host=$host
ro.build.tags=release-keys
ro.build.flavor=$n2-user
ro.debuggable=0
ro.secure=1
ro.product.brand=$n1
ro.product.system.brand=$n1
ro.product.vendor.brand=$n1
ro.product.product.brand=$n1
ro.product.odm.brand=$n1
ro.product.system_ext.brand=$n1
EOF

    cp -f $dir $diral 2>/dev/null
    cp -f $dir $dirsym 2>/dev/null

    resetprop -n ro.product.model "$modelok"
    resetprop -n ro.product.system.model "$modelok"
    resetprop -n ro.product.vendor.model "$modelok"
    resetprop -n ro.product.odm.model "$modelok"
    resetprop -n ro.product.system_ext.model "$modelok"
    resetprop -n ro.build.version.sdk "$SDK"
    resetprop -n ro.product.board "$BOARD"

    setprop persist.sys.device_name "$n3"
    setprop net.hostname "$n3"

    echo -e "  ${G}✅ SDK: $SDK | board: $BOARD | fingerprint: $fpp${N}"
}

update_identity() {
    echo -e "${Y}📝 กำลังอัปเดตชื่อเครื่องและเปลี่ยน ID แอปพลิเคชัน...${N}"
    for db in "/data/system/users/0/settings_global.xml" "/data/system/users/0/settings_secure.xml"; do
        if [ -f "$db" ]; then
            sed -i 's/\(name="device_name" value="\)[^"]*/\1'"$n71"'/g' "$db"
            sed -i 's/\(name="bluetooth_name" value="\)[^"]*/\1'"$n71"'/g' "$db"
        fi
    done
    rm -f /data/system/users/0/*.fallback 2>/dev/null

    local new_serial=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 12)
    local props_late="/data/adb/mhpc/propsconf_late"
    if [ -f "$props_late" ]; then
        local old_serial=$(grep -i "ro.serialno=" "$props_late" 2>/dev/null | cut -d '=' -f2 | head -n 1)
        [ -n "$old_serial" ] && sed -i "s/$old_serial/$new_serial/g" "$props_late"
    fi

    local ssaid_file="/data/system/users/0/settings_ssaid.xml"
    if [ -f "$ssaid_file" ]; then
        for pkg_name in "com.ss.android.ugc.trill" "com.zhiliaoapp.musically" "com.google.android.gms" "com.android.vending"; do
            local rand_val=$(cat /dev/urandom | tr -dc '0-9a-f' | head -c 16)
            local old_val=$(grep "$pkg_name" "$ssaid_file" 2>/dev/null | grep -o 'value="[^"]*"' | cut -d'"' -f2)
            [ -n "$old_val" ] && sed -i "s/$old_val/$rand_val/g" "$ssaid_file"
        done
    fi
    echo -e "  ${G}✅ SSAID randomized, device name updated${N}"
}

# [ใหม่ v2] อัปเดต PlayIntegrityFix ให้ตรงกับรุ่นที่ spoof
configure_pif() {
    local PIF_PATH="/data/adb/modules/playintegrityfix/custom.pif.prop"
    [ ! -f "$PIF_PATH" ] && echo -e "  ${Y}⚠️ ไม่พบ PlayIntegrityFix module${N}" && return

    echo -e "${Y}🔐 กำลังอัปเดต PlayIntegrityFix ให้ตรงกับรุ่น $n3...${N}"

    local INIT_SDK=$(map_initial_sdk "$n4")
    local fpp="$n1/$n2/$n2:$n4/$n5/$n6:user/release-keys"

    cat <<EOF > "$PIF_PATH"
# Build Fields - Auto-generated by BOYSER SPOOFING v2
MANUFACTURER=$n1
MODEL=$modelok
FINGERPRINT=$fpp
BRAND=$n1
PRODUCT=$n2
DEVICE=$n2
RELEASE=$n4
ID=$n5
INCREMENTAL=$n6
TYPE=user
TAGS=release-keys
SECURITY_PATCH=$sec1
DEVICE_INITIAL_SDK_INT=$INIT_SDK

# System Properties
*.build.id=$n5
*.security_patch=$sec1

# Advanced Settings
spoofBuild=1
spoofProps=1
spoofProvider=0
spoofSignature=0
spoofVendingFinger=0
spoofVendingSdk=0
verboseLogs=0
EOF

    echo -e "  ${G}✅ PIF อัปเดตแล้ว: $n1 $modelok (Android $n4 / SDK $INIT_SDK)${N}"
}

# [ใหม่ v2] ล้าง TikTok fingerprint cache เพื่อบังคับ re-enroll identity ใหม่
clear_tiktok_cache() {
    echo -e "${Y}🧹 กำลังล้าง TikTok fingerprint cache...${N}"
    local BASE="/data/data/com.ss.android.ugc.trill"
    local BASE2="/data/data/com.zhiliaoapp.musically"

    for pkg_base in "$BASE" "$BASE2"; do
        [ ! -d "$pkg_base" ] && continue

        # ล้าง integrity state machine → บังคับ BuildingState ใหม่
        rm -f "$pkg_base/files/machine/machine.json" 2>/dev/null

        # ล้าง hardware-bound cert → สร้างใหม่กับ identity ปัจจุบัน
        rm -f "$pkg_base/files/cert.info" 2>/dev/null

        # ล้าง dsign fingerprint cache ที่ cached ไว้ใน shared_prefs
        if [ -d "$pkg_base/shared_prefs" ]; then
            for xml in "$pkg_base/shared_prefs/"*.xml; do
                [ -f "$xml" ] && sed -i '/dsign_upload_params/d' "$xml" 2>/dev/null
            done
        fi

        # ล้าง keva store (key-value store ที่เก็บ device fingerprint)
        rm -f "$pkg_base/files/keva/"*dsign* 2>/dev/null
        rm -f "$pkg_base/files/keva/"*device_id* 2>/dev/null

        echo -e "  ${G}✅ $(basename $pkg_base): ล้าง machine.json, cert.info, dsign cache${N}"
    done
}

# [ใหม่ v2] Randomize MAC address ของ WiFi interface
randomize_mac() {
    echo -e "${Y}📡 กำลัง randomize WiFi MAC address...${N}"
    local done=0
    for iface in wlan0 wlan1 wlp0s20f3; do
        ip link show "$iface" >/dev/null 2>&1 || continue
        # Locally Administered Address (bit1=1, bit0=0) เพื่อหลีกเลี่ยงการชนกับ hardware MAC จริง
        local b1=$(( ( (RANDOM % 64) * 4 ) | 0x02 ))
        local new_mac=$(printf '%02x:%02x:%02x:%02x:%02x:%02x' \
            $b1 $((RANDOM%256)) $((RANDOM%256)) \
            $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
        ip link set "$iface" down 2>/dev/null
        ip link set "$iface" address "$new_mac" 2>/dev/null
        ip link set "$iface" up 2>/dev/null
        echo -e "  ${G}✅ $iface → $new_mac${N}"
        done=1
        break
    done
    [ $done -eq 0 ] && echo -e "  ${Y}⚠️ ไม่พบ WiFi interface (ข้ามขั้นตอนนี้)${N}"
}

# ==========================================
# 🧠 ระบบความจำ: จดจำรุ่นที่ใช้งานไปแล้วใน 24 ชม.
# ==========================================
manage_model_history() {
    local MAX_MODELS=141
    local BOYSER_DIR="/storage/emulated/0/BOYSER"
    mkdir -p "$BOYSER_DIR" 2>/dev/null

    local HISTORY_FILE="$BOYSER_DIR/boyser_used_models.txt"
    local temp_file="$BOYSER_DIR/boyser_temp_hist.txt"

    local now=$(date +%s)
    local expiry=86400

    touch "$HISTORY_FILE"
    > "$temp_file"

    while read -r ts model; do
        if [ -n "$ts" ] && [ -n "$model" ]; then
            local diff=$((now - ts))
            if [ "$diff" -lt "$expiry" ]; then
                echo "$ts $model" >> "$temp_file"
            fi
        fi
    done < "$HISTORY_FILE"
    mv -f "$temp_file" "$HISTORY_FILE"

    local used_models_str="$(cat "$HISTORY_FILE" | cut -d' ' -f2 | tr '\n' ' ')"
    local used_count="$(wc -l < "$HISTORY_FILE")"

    if [ "$used_count" -ge "$MAX_MODELS" ]; then
        echo -e "  ${Y}♻️ ประวัติเต็ม! ล้างและเริ่มรอบใหม่...${N}"
        > "$HISTORY_FILE"
        used_models_str=""
        used_count=0
    fi

    local available_models=""
    local avail_count=0
    local i=1
    while [ $i -le $MAX_MODELS ]; do
        if ! echo "$used_models_str" | grep -qw "$i"; then
            available_models="$available_models $i"
            avail_count=$((avail_count + 1))
        fi
        i=$((i + 1))
    done

    echo -e "  ${C}🔸 รุ่นที่ยังไม่ถูกใช้ใน 24 ชม.: ${G}${avail_count}/${MAX_MODELS} รุ่น${N}"

    local rand_idx=$(( (RANDOM % avail_count) + 1 ))
    local j=1
    for model_id in $available_models; do
        if [ $j -eq $rand_idx ]; then
            CHOSEN_BUILD_IDX=$model_id
            break
        fi
        j=$((j + 1))
    done

    echo "$now $CHOSEN_BUILD_IDX" >> "$HISTORY_FILE"
}

# ==============================================================================
# Main
# ==============================================================================
show_banner

manage_model_history
build_choice=$CHOSEN_BUILD_IDX
choose_device_model "$build_choice"

if [ $? -eq 0 ]; then
    build_system_prop
    update_identity
    configure_pif       # [v2] sync PIF กับรุ่นที่สุ่ม
    clear_tiktok_cache  # [v2] ล้าง fingerprint cache ของ TikTok
    randomize_mac       # [v2] เปลี่ยน MAC address

    echo -e "\n${C}======================================${N}"
    echo -e " 📱 ${Y}ข้อมูลเครื่องฟาร์มใหม่ของคุณ${N}"
    echo -e "${C}======================================${N}"
    echo -e " Model        : ${G}$modelok${N}"
    echo -e " Device Name  : ${G}$n3${N}"
    echo -e " Android Ver  : ${G}$n4 (SDK $(map_sdk $n4))${N}"
    echo -e " Build Number : ${G}$n5${N}"
    echo -e " Security Date: ${G}$sec1${N}"
    echo -e " Board        : ${G}$(get_board)${N}"
    echo -e " Fingerprint  : ${G}$n1/$n2/$n2:$n4/${N}"
    echo -e "${C}======================================${N}\n"

    echo -e "${G}🎉 SPOOF เสร็จสมบูรณ์!${N}"
    echo -e "${C}PIF, TikTok cache, MAC — ทุกอย่าง sync แล้ว${N}"
else
    echo -e "${R}❌ เกิดข้อผิดพลาดในการเลือกรุ่นอุปกรณ์${N}"
    exit 1
fi

echo -e "${Y}🔄 ระบบจะทำการรีสตาร์ทใน 5 วินาที...${N}"
sleep 5
reboot
