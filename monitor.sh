#!/bin/bash
# PROFESJONALNY MONITOR LIANLI - FULL DIAGNOSTIC (SUDO AUTO-RELAUNCH)

# Automatyczne podniesienie uprawnień do sudo
if [ "$EUID" -ne 0 ]; then exec sudo "$0" "$@"; fi

watch -n 1 "
# --- POBIERANIE DANYCH ---
# RAM Systemowy (Naprawiony filtr dla polskiej i angielskiej wersji)
RAM_DATA=\$(free -h | grep -iE '^mem|^pami' | awk '{print \$3 \" / \" \$2}')

# CPU Power & Temp (intel-rapl przez powercap)
CPU_R1=\$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
sleep 0.1
CPU_R2=\$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
CPU_POW_VAL=\$(echo \"scale=2; (\$CPU_R2 - \$CPU_R1) / 100000\" | bc -l)
CPU_TEMP=\$(sensors coretemp-isa-0000 2>/dev/null | grep 'Package id 0' | awk '{print \$4}')

# NVIDIA RTX 4070 (Master) - VRAM i Power
NV_DATA=\$(nvidia-smi --query-gpu=temperature.gpu,power.draw,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)
NV_TEMP=\$(echo \$NV_DATA | awk -F', ' '{print \$1 \"°C\"}')
NV_POW=\$(echo \$NV_DATA | awk -F', ' '{print \$2}')
NV_VRAM=\$(echo \$NV_DATA | awk -F', ' '{print \$3 \" / \" \$4 \" MiB\"}')

# AMD MI50 (Worker) - VRAM i Power (PPT + 75W PCIe)
AMD_JUNC=\$(sensors amdgpu-pci-0600 2>/dev/null | grep 'junction:' | awk '{print \$2}')
AMD_PPT=\$(sensors amdgpu-pci-0600 2>/dev/null | grep 'PPT:' | awk '{print \$2}' | tr -d 'W')
AMD_TOTAL=\$(echo \"\$AMD_PPT + 75.00\" | bc -l)
# Pobór VRAM dla AMD przez sysfs (card1 to MI50)
AMD_VRAM_U=\$(cat /sys/class/drm/card1/device/mem_info_vram_used 2>/dev/null || echo 0)
AMD_VRAM_T=\$(cat /sys/class/drm/card1/device/mem_info_vram_total 2>/dev/null || echo 1)
AMD_VRAM_MB=\$(echo \"\$AMD_VRAM_U / 1024 / 1024\" | bc)
AMD_VRAM_TOT=\$(echo \"\$AMD_VRAM_T / 1024 / 1024\" | bc)

# --- WYŚWIETLANIE ---
echo '========================================================================'
echo '          PROFESJONALNY MONITOR KLASTRA HYBRYDOWEGO - LIANLI          '
echo '========================================================================'
echo ''
printf '%-28s %-20s | %-15s\n' 'PROCESOR (i5-12400F):' \"\$CPU_TEMP\" \"\$CPU_POW_VAL W\"
printf '%-28s %-20s\n' 'PAMIĘĆ RAM (Usage):'    \"\$RAM_DATA\"
echo ''
echo '------------------------------------------------------------------------'
printf '%-28s %-20s | %-15s\n' 'GPU 0 (RTX 4070):'      \"\$NV_TEMP\" \"\$NV_POW W\"
printf '%-28s %-20s\n' 'VRAM NVIDIA:'           \"\$NV_VRAM\"
echo ''
printf '%-28s %-20s | %-15s\n' 'GPU 1 (AMD MI50):'      \"\$AMD_JUNC (Hotspot)\" \"\$AMD_TOTAL W\"
printf '%-28s %-20s\n' 'VRAM AMD MI50:'         \"\$AMD_VRAM_MB / \$AMD_VRAM_TOT MiB\"
echo ''
echo '------------------------------------------------------------------------'
printf '%-28s \033[1;32m%s W\033[0m\n' 'ŁĄCZNY POBÓR KLASTRA:' \"\$(echo \"\$CPU_POW_VAL + \$NV_POW + \$AMD_TOTAL\" | bc -l)\"
echo '------------------------------------------------------------------------'
echo ''
printf '%-28s %-20s\n' 'RPC FLOW (Docker):'    \"\$(cat /proc/net/dev | grep 'br-' | awk '{rx+=\$2} END {printf \"%.2f MB/s\", rx/1024/1024}')\"
printf '%-28s %-20s\n' 'WENT. AMD (FAN #4):'   \"\$(sensors nct6687-isa-0a20 2>/dev/null | grep 'System Fan #4:' | awk '{print \$4}') RPM\"
echo '========================================================================'
"
