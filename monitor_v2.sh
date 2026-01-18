#!/bin/bash
# LIANLI CLUSTER MONITOR v2 - PROFESSIONAL TELEMETRY
# Features: WideFrame, Min/Max Tracking, Color Latency, Raw Power, Link-Fixer

if [ "$EUID" -ne 0 ]; then exec sudo "$0" "$@"; fi

# 1. MAPOWANIE SIŁOWE (Metoda iflink)
declare -A VETH_MAP IP_MAP MAX_IN MAX_OUT MIN_IN MIN_OUT
map_veth() {
    unset VETH_MAP; declare -gA VETH_MAP
    for name in $(docker ps --format '{{.Names}}'); do
        iflink=$(docker exec $name cat /sys/class/net/eth0/iflink 2>/dev/null)
        if [ ! -z "$iflink" ]; then
            veth=$(ip ad | grep "^$iflink:" | awk -F': ' '{print $2}' | cut -d'@' -f1)
            VETH_MAP["$name"]=$veth
            IP_MAP["$name"]=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$name")
            MAX_IN[$veth]=${MAX_IN[$veth]:-0}; MAX_OUT[$veth]=${MAX_OUT[$veth]:-0}
            MIN_IN[$veth]=${MIN_IN[$veth]:-999.00}; MIN_OUT[$veth]=${MIN_OUT[$veth]:-999.00}
        fi
    done
}

map_veth
tput civis; clear
COUNTER=0; declare -A LIVE_LATENCY

while true; do
    if [ $((COUNTER % 60)) -eq 0 ]; then map_veth; fi
    T1=$(date +%s.%N); ST1=$(cat /proc/net/dev); E1=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
    
    # Ping co 10s (Kolory: <0.1 Green, <0.5 Orange, >0.5 Red)
    if [ $((COUNTER % 20)) -eq 0 ]; then
        for name in "${!IP_MAP[@]}"; do
            LAT=$(ping -c 1 -W 1 "${IP_MAP[$name]}" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
            if [ ! -z "$LAT" ]; then
                if [ "$(echo "$LAT < 0.100" | bc -l)" -eq 1 ]; then COL="\033[1;32m";
                elif [ "$(echo "$LAT < 0.500" | bc -l)" -eq 1 ]; then COL="\033[1;33m";
                else COL="\033[1;31m"; fi
                LIVE_LATENCY[$name]="${COL}${LAT}ms\033[0m"
            else LIVE_LATENCY[$name]="\033[1;31mOFF\033[0m"; fi
        done
    fi

    sleep 0.5
    T2=$(date +%s.%N); ST2=$(cat /proc/net/dev); E2=$(cat /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null); DT=$(echo "$T2 - $T1" | bc -l)

    tput cup 0 0
    echo "================================================================================================="
    echo "               PROFESJONALNY MONITOR RPC v2.0 - LIANLI COMPILE MACHINE                          "
    echo "================================================================================================="
    printf "%-19s | %-8s | %-8s | %-17s | %-17s | %-8s\n" "KONTENER" "IN MB/s" "OUT MB/s" "MIN/MAX IN" "MIN/MAX OUT" "LATENCY"
    echo "-------------------------------------------------------------------------------------------------"

    T_IN=0; T_OUT=0
    for name in $(echo "${!VETH_MAP[@]}" | tr ' ' '\n' | sort); do
        veth=${VETH_MAP[$name]}
        R1=$(echo "$ST1" | grep "$veth" | awk '{print $2}' || echo 0); T1_V=$(echo "$ST1" | grep "$veth" | awk '{print $10}' || echo 0)
        R2=$(echo "$ST2" | grep "$veth" | awk '{print $2}' || echo 0); T2_V=$(echo "$ST2" | grep "$veth" | awk '{print $10}' || echo 0)
        S_IN=$(echo "scale=2; ($R2 - $R1) / $DT / 1048576" | bc -l); S_OUT=$(echo "scale=2; ($T2_V - $T1_V) / $DT / 1048576" | bc -l)
        
        if [ "$(echo "$S_IN > ${MAX_IN[$veth]}" | bc)" -eq 1 ]; then MAX_IN[$veth]=$S_IN; fi
        if [ "$(echo "$S_OUT > ${MAX_OUT[$veth]}" | bc)" -eq 1 ]; then MAX_OUT[$veth]=$S_OUT; fi
        if [ "$(echo "$S_IN < ${MIN_IN[$veth]}" | bc)" -eq 1 ] && [ "$(echo "$S_IN > 0.01" | bc)" -eq 1 ]; then MIN_IN[$veth]=$S_IN; fi
        if [ "$(echo "$S_OUT < ${MIN_OUT[$veth]}" | bc)" -eq 1 ] && [ "$(echo "$S_OUT > 0.01" | bc)" -eq 1 ]; then MIN_OUT[$veth]=$S_OUT; fi

        M_IN="${MIN_IN[$veth]}"; [ "$M_IN" == "999.00" ] && M_IN="0.00"
        M_OUT="${MIN_OUT[$veth]}"; [ "$M_OUT" == "999.00" ] && M_OUT="0.00"
        printf "%-19s | %8s | %8s | %7s/%-7s | %7s/%-7s | %b\n" "$name" "$S_IN" "$S_OUT" "$M_IN" "${MAX_IN[$veth]}" "$M_OUT" "${MAX_OUT[$veth]}" "${LIVE_LATENCY[$name]}"
        T_IN=$(echo "$T_IN + $S_IN" | bc -l); T_OUT=$(echo "$T_OUT + $S_OUT" | bc -l)
    done

    # HARDWARE STATS
    CPU_T=$(sensors coretemp-isa-0000 2>/dev/null | grep 'Package id 0' | awk '{print $4}' || echo "+0.0°C")
    CPU_W=$(echo "scale=2; ($E2 - $E1) / ($DT * 1000000)" | bc -l || echo 0)
    RAM_U=$(free -m | grep -iE '^mem|^pami' | awk '{print $3}' || echo 0); RAM_T=$(free -m | grep -iE '^mem|^pami' | awk '{print $2}' || echo 1); RAM_P=$(echo "scale=2; $RAM_U / $RAM_T * 100" | bc -l || echo 0)
    NV_D=$(nvidia-smi --query-gpu=power.draw,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null || echo "0, 0, 0, 1")
    NV_W=$(echo $NV_D | awk -F', ' '{print $1}'); NV_T=$(echo $NV_D | awk -F', ' '{print $2}'); NV_U=$(echo $NV_D | awk -F', ' '{print $3}'); NV_TOT=$(echo $NV_D | awk -F', ' '{print $4}'); NV_P=$(echo "scale=2; $NV_U / $NV_TOT * 100" | bc -l || echo 0)
    AMD_S=$(sensors amdgpu-pci-0600 2>/dev/null); A_JN=$(echo "$AMD_S" | grep 'junction:' | awk '{print $2}' || echo "+0.0°C"); A_ED=$(echo "$AMD_S" | grep 'edge:' | awk '{print $2}' || echo "+0.0°C"); A_ME=$(echo "$AMD_S" | grep 'mem:' | awk '{print $2}' || echo "+0.0°C"); A_W=$(echo "$AMD_S" | grep 'PPT:' | awk '{print $2}' | tr -d 'W' || echo 0); A_U=$(echo "$(cat /sys/class/drm/card1/device/mem_info_vram_used 2>/dev/null || echo 0) / 1024 / 1024" | bc || echo 0); A_P=$(echo "scale=2; $A_U / 32752 * 100" | bc -l || echo 0)

    echo "-------------------------------------------------------------------------------------------------"
    printf "CPU: %-12s | %8s W | RAM: %s/%s MiB (%s%%)\n" "$CPU_T" "$CPU_W" "$RAM_U" "$RAM_T" "$RAM_P"
    printf "NV:  %-12s | %8s W | VRAM: %s/%s MiB (%s%%)\n" "$NV_T°C" "$NV_W" "$NV_U" "$NV_TOT" "$NV_P"
    printf "AMD: %-12s | %8s W | VRAM: %s/32752 MiB (%s%%)\n" "$A_JN" "$A_W" "$A_U" "$A_P"
    printf "AMD EDGE/MEM:   %-12s / %-12s | FAN: %s RPM\n" "$A_ED" "$A_ME" "$(sensors nct6687-isa-0a20 2>/dev/null | grep 'System Fan #4:' | awk '{print $4}' || echo 0)"
    echo "-------------------------------------------------------------------------------------------------"
    AVG_M=$(echo "scale=2; ($RAM_P + $NV_P + $A_P) / 3" | bc -l || echo 0)
    printf "\033[1;36mSUMA RPC: %6s MB/s\033[0m | \033[1;32mPOBÓR: %6s W\033[0m | ŚREDNIA PAMIĘCI: %s%%\n" "$(echo "$T_IN + $T_OUT" | bc -l)" "$(echo "$CPU_W + $NV_W + $A_W" | bc -l)" "$AVG_M"
    echo "================================================================================================="
    COUNTER=$((COUNTER + 1))
done
trap 'tput cnorm; exit' INT TERM EXIT
