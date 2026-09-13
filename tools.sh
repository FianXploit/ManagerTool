#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#         TERMUX TOOLS MANAGER CLI
#         Developer : FIAN DEV
#         Version   : 3.0  (Rapi + Warna Original)
#         License   : MIT
# ============================================================

# ---------- Warna (TIDAK DIUBAH) ----------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m'

# ---------- Konfigurasi ----------
DEV_NAME="FIAN DEV"
APP_NAME="TERMUX TOOLS MANAGER"

# ---------- Daftar Package ----------
PKG_BASIC="git nano vim wget curl openssl openssh tar gzip unzip zip which tree"
PKG_DEV="python python-pip nodejs npm clang make cmake golang rust ruby php"
PKG_NET="nmap netcat-openbsd whois dnsutils tsu iproute2"
PKG_MEDIA="ffmpeg imagemagick sox"
PKG_EXTRA="figlet toilet cowsay neofetch htop tmux screen ranger mc tree fzf jq bc w3m elinks"
PIP_LIBS="requests beautifulsoup4 colorama rich pyfiglet lolcat termcolor"
NPM_GLOBAL="npm-check-updates"

# ============================================================
#          HELPER: AUTO PADDING BIAR SEJAJAR
# ============================================================

# Hitung panjang visible (buang ANSI escape code)
vlen() {
    local s
    s=$(printf '%b' "$1" | sed 's/\x1b\[[0-9;]*m//g')
    echo "${#s}"
}

# Baris box │ isi │ dengan padding otomatis
boxline() {
    local text="$1"
    local width="${2:-62}"
    local len pad
    len=$(vlen "$text")
    pad=$((width - len))
    (( pad < 0 )) && pad=0
    printf "${WHITE}│${NC}%b%*s${WHITE}│${NC}\n" "$text" "$pad" ""
}

# Border atas
box_top() {
    local width="${1:-62}"
    printf "${WHITE}╭"
    printf '─%.0s' $(seq 1 "$width")
    printf "╮${NC}\n"
}

# Border bawah
box_bot() {
    local width="${1:-62}"
    printf "${WHITE}╰"
    printf '─%.0s' $(seq 1 "$width")
    printf "╯${NC}\n"
}

# Border tengah
box_mid() {
    local width="${1:-62}"
    printf "${WHITE}├"
    printf '─%.0s' $(seq 1 "$width")
    printf "┤${NC}\n"
}

# ============================================================
#                     BANNER
# ============================================================
banner() {
    clear
    box_top 62
    boxline "" 62
    boxline "${RED}      ____________    ______   __________  ____  __ ${NC}" 62
    boxline "${RED}     / ____/  _/ /   / ____/  /_  __/ __ \/ __ \/ / ${NC}" 62
    boxline "${RED}    / /_   / // /   / __/      / / / / / / / / / /  ${NC}" 62
    boxline "${RED}   / __/ _/ // /___/ /___     / / / /_/ / /_/ / /___${NC}" 62
    boxline "${RED}  /_/   /___/_____/_____/    /_/  \____/\____/_____/${NC}" 62
    boxline "" 62
    box_mid 62
    boxline "${WHITE}        ${RED}${APP_NAME}${NC}" 62
    boxline "${WHITE}        ${RED}Developer : ${WHITE}${DEV_NAME}${NC}" 62
    box_bot 62
    echo ""
}

# ============================================================
#              INFORMASI DEVICE (2 KOLOM)
# ============================================================
device_info() {
    # Ambil data
    local IP_ADDR
    IP_ADDR=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
    [ -z "$IP_ADDR" ] && IP_ADDR=$(ifconfig 2>/dev/null | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $2}' | head -n1)
    [ -z "$IP_ADDR" ] && IP_ADDR="-"

    local TUSER
    TUSER=$(whoami 2>/dev/null)
    [ -z "$TUSER" ] && TUSER="${USER:-unknown}"

    local UID_TERMUX
    UID_TERMUX=$(id -u 2>/dev/null)
    [ -z "$UID_TERMUX" ] && UID_TERMUX="-"

    local TANGGAL WAKTU
    TANGGAL=$(date '+%A, %d %B %Y')
    WAKTU=$(date '+%H:%M:%S %Z')

    local DEVICE_NAME
    DEVICE_NAME=$(getprop ro.product.model 2>/dev/null)
    [ -z "$DEVICE_NAME" ] && DEVICE_NAME="Unknown"

    local ANDROID_VER
    ANDROID_VER=$(getprop ro.build.version.release 2>/dev/null)
    [ -z "$ANDROID_VER" ] && ANDROID_VER="N/A"

    local KERNEL
    KERNEL=$(uname -r | cut -c1-18)

    # Format 2 kolom
    # Setiap kolom: │ LABEL(11) : VALUE(15) │  = 30 char
    echo -e "${WHITE}╭──────────────────────────────╮╭──────────────────────────────╮${NC}"
    printf "${WHITE}│${NC} ${WHITE}%-11s${NC} ${WHITE}:${NC} %-15s ${WHITE}│${NC}${WHITE}│${NC} ${WHITE}%-11s${NC} ${WHITE}:${NC} %-15s ${WHITE}│${NC}\n" \
        "Perangkat" "$DEVICE_NAME" \
        "IP Address" "$IP_ADDR"
    printf "${WHITE}│${NC} ${WHITE}%-11s${NC} ${WHITE}:${NC} %-15s ${WHITE}│${NC}${WHITE}│${NC} ${WHITE}%-11s${NC} ${WHITE}:${NC} %-15s ${WHITE}│${NC}\n" \
        "Android" "$ANDROID_VER" \
        "Termux User" "$TUSER"
    printf "${WHITE}│${NC} ${WHITE}%-11s${NC} ${WHITE}:${NC} %-15s ${WHITE}│${NC}${WHITE}│${NC} ${WHITE}%-11s${NC} ${WHITE}:${NC} %-15s ${WHITE}│${NC}\n" \
        "User ID" "$UID_TERMUX" \
        "Kernel" "$KERNEL"
    printf "${WHITE}│${NC} ${WHITE}%-11s${NC} ${WHITE}:${NC} %-15s ${WHITE}│${NC}${WHITE}│${NC} ${WHITE}%-11s${NC} ${WHITE}:${NC} %-15s ${WHITE}│${NC}\n" \
        "Tanggal" "$(echo $TANGGAL | cut -c1-15)" \
        "Waktu" "$WAKTU"
    echo -e "${WHITE}╰──────────────────────────────╯╰──────────────────────────────╯${NC}"
    echo ""
}

# ============================================================
#                     MENU UTAMA
# ============================================================
menu() {
    local w=62
    box_top "$w"
    boxline "${WHITE}                  [ MENU UTAMA ]${NC}" "$w"
    box_mid "$w"
    boxline " ${RED}[1]${NC}  Update & Upgrade Package" "$w"
    boxline " ${RED}[2]${NC}  Install Tools Wajib (Git, Nano, Wget, Curl)" "$w"
    boxline " ${RED}[3]${NC}  Install Python & Pip" "$w"
    boxline " ${RED}[4]${NC}  Install NodeJS & NPM" "$w"
    boxline " ${RED}[5]${NC}  Install Nmap (Network Scanner)" "$w"
    boxline " ${RED}[6]${NC}  Install Figlet & Toilet (Banner Tools)" "$w"
    boxline " ${RED}[7]${NC}  Install Metasploit (via apt)" "$w"
    boxline " ${RED}[8]${NC}  Lihat Tools Yang Sudah Terinstall" "$w"
    boxline " ${RED}[9]${NC}  Bersihkan Cache Termux" "$w"
    box_mid "$w"
    boxline " ${RED}[10]${NC} ${WHITE}★ INSTALL SEMUA PACKAGE (100% LENGKAP)${NC}" "$w"
    boxline " ${RED}[11]${NC} Install Package Basic (dev essentials)" "$w"
    boxline " ${RED}[12]${NC} Install Package Development (lang & compiler)" "$w"
    boxline " ${RED}[13]${NC} Install Package Network & Security" "$w"
    boxline " ${RED}[14]${NC} Install Package Media (ffmpeg, imagemagick)" "$w"
    boxline " ${RED}[15]${NC} Install Package Extra (terminal tools & UI)" "$w"
    boxline " ${RED}[16]${NC} Install Python Libraries (pip)" "$w"
    boxline " ${RED}[17]${NC} Install NodeJS Global Packages (npm)" "$w"
    box_mid "$w"
    boxline " ${RED}[0]${NC}  Keluar" "$w"
    box_bot "$w"
    echo -ne "${RED}▶ Pilih Menu [0-17] : ${NC}"
}

# ============================================================
#                 FUNGSI HELPER
# ============================================================
pause_enter() {
    echo ""
    echo -ne "${GREEN}Tekan ENTER untuk kembali ke menu...${NC}"
    read -r
}

progress_bar() {
    local current=$1 total=$2
    local width=40
    local filled=$((current * width / total))
    local empty=$((width - filled))
    printf "\r${CYAN}["
    printf "%${filled}s" "" | tr ' ' '█'
    printf "%${empty}s" "" | tr ' ' '░'
    printf "]${NC} ${WHITE}%3d%%${NC} ${WHITE}(%d/%d)${NC}" $((current*100/total)) "$current" "$total"
}

install_pkg_list() {
    local label="$1"; shift
    local pkgs=("$@")
    local total=${#pkgs[@]}
    local success=0
    local failed=()

    echo -e "${WHITE}╭──────────────────────────────────────────────────────────╮${NC}"
    echo -e "${WHITE}│${NC} ${WHITE}Installing${NC} : ${RED}${label}${NC}"
    echo -e "${WHITE}│${NC} ${WHITE}Total     ${NC} : ${RED}${total}${WHITE} package${NC}"
    echo -e "${WHITE}╰──────────────────────────────────────────────────────────╯${NC}"
    echo ""

    local i=0
    for pkg in "${pkgs[@]}"; do
        i=$((i + 1))
        progress_bar "$i" "$total"
        echo ""
        if pkg install -y "$pkg" >/dev/null 2>&1; then
            echo -e "${RED}  ✓${NC} ${pkg}"
            success=$((success + 1))
        else
            echo -e "${RED}  ✗${NC} ${pkg} ${WHITE}(gagal)${NC}"
            failed+=("$pkg")
        fi
        echo ""
    done

    echo -e "${RED}══════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}  ✓ Berhasil${NC} : ${WHITE}${success}${NC} / ${WHITE}${total}${NC}"
    if [ ${#failed[@]} -gt 0 ]; then
        echo -e "${RED}  ✗ Gagal   ${NC} : ${WHITE}${#failed[@]}${NC}"
        echo -e "${RED}  Paket     ${NC} : ${WHITE}${failed[*]}${NC}"
    fi
    echo -e "${RED}══════════════════════════════════════════════════════════${NC}"
}

# ============================================================
#                     FUNGSI AKSI
# ============================================================
aksi() {
    case $1 in
        1)
            echo -e "${RED}[*] Update & Upgrade package...${NC}"
            pkg update -y && pkg upgrade -y
            echo -e "${RED}[✓] Selesai!${NC}"
            pause_enter ;;
        2)  install_pkg_list "Tools Wajib" git nano vim wget curl; pause_enter ;;
        3)  install_pkg_list "Python & Pip" python python-pip; pause_enter ;;
        4)  install_pkg_list "NodeJS & NPM" nodejs npm; pause_enter ;;
        5)  install_pkg_list "Network Scanner" nmap; pause_enter ;;
        6)  install_pkg_list "Banner Tools" figlet toilet; pause_enter ;;
        7)
            echo -e "${RED}[*] Install Metasploit...${NC}"
            pkg install -y unstable-repo
            pkg install -y metasploit
            echo -e "${RED}[✓] Selesai!${NC}"
            pause_enter ;;
        8)
            echo -e "${RED}[*] Daftar package yang terinstall:${NC}"
            echo ""
            dpkg --list 2>/dev/null | awk 'NR>5 {print $2}' | column -c 80 2>/dev/null | head -60
            pause_enter ;;
        9)
            echo -e "${RED}[*] Bersihkan cache Termux...${NC}"
            pkg clean
            rm -rf $PREFIX/var/cache/apt/archives/*.deb 2>/dev/null
            echo -e "${RED}[✓] Cache dibersihkan!${NC}"
            pause_enter ;;
        10) install_all_packages ;;
        11) install_pkg_list "Basic Dev Essentials" $PKG_BASIC; pause_enter ;;
        12) install_pkg_list "Development Languages" $PKG_DEV; pause_enter ;;
        13) install_pkg_list "Network & Security" $PKG_NET; pause_enter ;;
        14) install_pkg_list "Media Tools" $PKG_MEDIA; pause_enter ;;
        15) install_pkg_list "Extra Terminal Tools" $PKG_EXTRA; pause_enter ;;
        16) install_python_libs; pause_enter ;;
        17) install_npm_globals; pause_enter ;;
        0)
            echo ""
            echo -e "${WHITE}╭──────────────────────────────────────────────────────────╮${NC}"
            echo -e "${WHITE}│${NC}  ${WHITE}Terima kasih telah menggunakan tools ini${NC}"
            echo -e "${WHITE}│${NC}  ${RED}Developer : ${WHITE}${DEV_NAME}${NC}"
            echo -e "${WHITE}╰──────────────────────────────────────────────────────────╯${NC}"
            exit 0 ;;
        *)
            echo -e "${RED}[!] Pilihan tidak valid!${NC}"
            pause_enter ;;
    esac
}

# ============================================================
#                 INSTALL SEMUA
# ============================================================
install_all_packages() {
    clear
    echo -e "${WHITE}╭──────────────────────────────────────────────────────────╮${NC}"
    echo -e "${WHITE}│${NC}     ${RED}★ FULL PACKAGE INSTALLER - 100% LENGKAP ★${NC}"
    echo -e "${WHITE}│${NC}        Total package akan diinstall: ${RED}~60+${NC}"
    echo -e "${WHITE}╰──────────────────────────────────────────────────────────╯${NC}"
    echo ""
    echo -e "${RED}⚠️  Proses ini akan memakan waktu lama dan kuota data.${NC}"
    echo -e "${RED}⚠️  Pastikan koneksi internet stabil.${NC}"
    echo ""
    echo -ne "${WHITE}Lanjutkan install semua? [Y/N] : ${NC}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Dibatalkan.${NC}"; sleep 1; return
    fi

    local start_time; start_time=$(date +%s)

    echo ""; echo -e "${RED}[1/8] Update repository...${NC}"
    pkg update -y >/dev/null 2>&1

    echo ""; echo -e "${RED}[2/8] Basic Dev Essentials${NC}"
    install_pkg_list "Basic" $PKG_BASIC

    echo ""; echo -e "${RED}[3/8] Development Languages${NC}"
    install_pkg_list "Development" $PKG_DEV

    echo ""; echo -e "${RED}[4/8] Network & Security${NC}"
    install_pkg_list "Network" $PKG_NET

    echo ""; echo -e "${RED}[5/8] Media Tools${NC}"
    install_pkg_list "Media" $PKG_MEDIA

    echo ""; echo -e "${RED}[6/8] Extra Terminal Tools${NC}"
    install_pkg_list "Extra" $PKG_EXTRA

    echo ""; echo -e "${RED}[7/8] Python Libraries${NC}"
    install_python_libs

    echo ""; echo -e "${RED}[8/8] NPM Global Packages${NC}"
    install_npm_globals

    local end_time; end_time=$(date +%s)
    local dur=$((end_time - start_time))

    echo ""
    echo -e "${WHITE}╭──────────────────────────────────────────────────────────╮${NC}"
    echo -e "${WHITE}│${NC}        ${RED}★★★ INSTALASI SELESAI ★★★${NC}"
    echo -e "${WHITE}│${NC}   Durasi    : ${RED}${dur} detik${NC}"
    echo -e "${WHITE}│${NC}   Status    : ${RED}Semua package telah diproses${NC}"
    echo -e "${WHITE}│${NC}   Developer : ${RED}${DEV_NAME}${NC}"
    echo -e "${WHITE}╰──────────────────────────────────────────────────────────╯${NC}"
    pause_enter
}

# ============================================================
#                 INSTALL PYTHON LIBS
# ============================================================
install_python_libs() {
    if ! command -v pip >/dev/null 2>&1; then
        echo -e "${RED}[!] pip belum ada, install dulu...${NC}"
        pkg install -y python python-pip >/dev/null 2>&1
    fi

    echo -e "${WHITE}╭──────────────────────────────────────────────────────────╮${NC}"
    echo -e "${WHITE}│${NC} ${WHITE}Installing${NC} : ${RED}Python Libraries${NC}"
    echo -e "${WHITE}╰──────────────────────────────────────────────────────────╯${NC}"
    echo ""

    local libs=($PIP_LIBS)
    local total=${#libs[@]}
    local i=0
    for lib in "${libs[@]}"; do
        i=$((i + 1))
        printf "${WHITE}[%d/%d]${NC} pip install ${WHITE}%s${NC}\n" "$i" "$total" "$lib"
        if pip install --quiet "$lib" >/dev/null 2>&1; then
            echo -e "${RED}  ✓${NC} ${lib}"
        else
            echo -e "${RED}  ✗${NC} ${lib} ${WHITE}(gagal)${NC}"
        fi
    done
    echo ""
    echo -e "${RED}[✓] Python libraries selesai.${NC}"
}

# ============================================================
#                 INSTALL NPM GLOBAL
# ============================================================
install_npm_globals() {
    if ! command -v npm >/dev/null 2>&1; then
        echo -e "${RED}[!] npm belum ada, install dulu...${NC}"
        pkg install -y nodejs npm >/dev/null 2>&1
    fi

    echo -e "${WHITE}╭──────────────────────────────────────────────────────────╮${NC}"
    echo -e "${WHITE}│${NC} ${WHITE}Installing${NC} : ${RED}NodeJS Global Packages${NC}"
    echo -e "${WHITE}╰──────────────────────────────────────────────────────────╯${NC}"
    echo ""

    for pkg in $NPM_GLOBAL; do
        echo -e "${WHITE}npm install -g${NC} ${WHITE}${pkg}${NC}"
        if npm install -g "$pkg" >/dev/null 2>&1; then
            echo -e "${RED}  ✓${NC} ${pkg}"
        else
            echo -e "${RED}  ✗${NC} ${pkg} ${WHITE}(gagal)${NC}"
        fi
    done
    echo ""
    echo -e "${RED}[✓] NPM globals selesai.${NC}"
}

# ============================================================
#                     LOOP UTAMA
# ============================================================
main() {
    while true; do
        banner
        device_info
        menu
        read -r pilihan
        aksi "$pilihan"
    done
}

# ============================================================
#                     CEK TERMUX
# ============================================================
if ! command -v pkg >/dev/null 2>&1; then
    echo -e "${RED}[!] Script ini hanya bisa dijalankan di Termux!${NC}"
    exit 1
fi

main