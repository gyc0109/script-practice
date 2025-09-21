#!/bin/bash
set -euo pipefail

##############################################
# 脚本名称: ping_check.sh
# 版本: 1.1
# 作者: 系统管理员
# 创建日期: 2025-09-21
# 描述: 用于检测指定网段内IP地址的可达性，使用多线程并行ping检测
# 适用系统: Linux
# 使用方法: ./ping_check.sh [网段前缀] [线程数] [ping包数量] [超时时间(秒)]
# 示例: ./ping_check.sh 156.238.236 50 3 2
##############################################

# 定义颜色常量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # 无颜色

# 显示帮助信息
show_help() {
    cat << EOF
用法: $(basename "$0") [选项] [网段前缀] [线程数] [ping包数量] [超时时间(秒)]

选项:
    -h, --help      显示此帮助信息并退出
    -v, --version   显示版本信息并退出
    -q, --quiet     安静模式，只输出最终结果
    -s, --sort      对结果文件进行排序

参数说明:
    网段前缀        要检测的网段（如192.168.1），默认: 156.238.236
    线程数          并行检测的线程数量，默认: 50，建议范围10-100
    ping包数量      每个IP发送的ping包数量，默认: 3，建议范围1-10
    超时时间        每个ping包的超时时间(秒)，默认: 2，建议范围1-5

示例:
    $(basename "$0") 192.168.1 30 2 1    # 检测192.168.1网段，30线程，每个IP发2个包，超时1秒
    $(basename "$0") -s                 # 使用默认参数检测并对结果排序
    $(basename "$0") -q 10.0.0          # 安静模式检测10.0.0网段
EOF
}

# 显示版本信息
show_version() {
    echo "$(basename "$0") 版本 1.1"
    echo "适用于Linux系统的网段Ping检测工具"
}

# 初始化变量
SUBNET="156.238.236"        # 网段前缀默认值
THREADS=50                  # 线程数默认值
PING_COUNT=3                # ping包数量默认值
PING_TIMEOUT=2              # 超时时间默认值
QUIET_MODE=0                # 安静模式标记
SORT_RESULTS=0              # 排序结果标记

# 处理选项参数
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        -q|--quiet)
            QUIET_MODE=1
            shift
            ;;
        -s|--sort)
            SORT_RESULTS=1
            shift
            ;;
        *)
            break  # 非选项参数，开始处理位置参数
            ;;
    esac
done

# 配置参数（支持用户输入，不输入时使用默认值）
SUBNET="${1:-$SUBNET}"
THREADS="${2:-$THREADS}"
PING_COUNT="${3:-$PING_COUNT}"
PING_TIMEOUT="${4:-$PING_TIMEOUT}"

# 结果输出文件
OK_FILE="./ping_ok.txt"
FALSE_FILE="./ping_false.txt"

# 参数验证函数
validate_parameters() {
    # 验证网段格式
    if ! [[ "$SUBNET" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}错误：网段格式不正确（应为xxx.xxx.xxx）${NC}" >&2
        exit 1
    fi

    # 验证线程数为合理范围的正整数
    if ! [[ "$THREADS" =~ ^[1-9][0-9]*$ ]] || [ "$THREADS" -lt 1 ] || [ "$THREADS" -gt 200 ]; then
        echo -e "${RED}错误：线程数必须是1-200之间的正整数${NC}" >&2
        exit 1
    fi

    # 验证ping包数量为合理范围的正整数
    if ! [[ "$PING_COUNT" =~ ^[1-9][0-9]*$ ]] || [ "$PING_COUNT" -lt 1 ] || [ "$PING_COUNT" -gt 20 ]; then
        echo -e "${RED}错误：ping包数量必须是1-20之间的正整数${NC}" >&2
        exit 1
    fi

    # 验证超时时间为合理范围的正数
    if ! [[ "$PING_TIMEOUT" =~ ^[0-9]+(\.[0-9]+)?$ ]] || (( $(echo "$PING_TIMEOUT <= 0" | bc -l) )) || (( $(echo "$PING_TIMEOUT > 10" | bc -l) )); then
        echo -e "${RED}错误：超时时间必须是0-10之间的正数${NC}" >&2
        exit 1
    fi
}

# 定义 ping 检测函数
ping_ip() {
    local ip=$1
    # 使用Linux专用ping参数，增加不分片选项
    if ping -c "$PING_COUNT" -W "$PING_TIMEOUT" -M do "$ip" >/dev/null 2>&1; then
        echo "$ip" >> "$OK_FILE"
        if [ $QUIET_MODE -eq 0 ]; then
            echo -e "${GREEN}✅ $ip 可达${NC}"
        fi
    else
        echo "$ip" >> "$FALSE_FILE"
        if [ $QUIET_MODE -eq 0 ]; then
            echo -e "${RED}❌ $ip 不可达${NC}"
        fi
    fi
}

# 信号捕获和清理函数
cleanup() {
    if [ $QUIET_MODE -eq 0 ]; then
        echo -e "\n${YELLOW}脚本被中断，清理后台进程...${NC}"
    fi
    # 杀死所有子进程
    pkill -P $$ >/dev/null 2>&1 || true
    exit 1
}

##############################################
# 主程序开始
##############################################

# 记录开始时间
START_TIME=$(date +%s)

# 验证参数
validate_parameters

# 清空结果文件
> "$OK_FILE"
> "$FALSE_FILE"

# 设置信号捕获
trap cleanup INT TERM

# 输出开始信息（非安静模式）
if [ $QUIET_MODE -eq 0 ]; then
    echo -e "${BLUE}$(date +"%Y-%m-%d %H:%M:%S") - 开始检测网段 $SUBNET.1-254 ...${NC}"
    echo -e "${YELLOW}使用参数: 线程数=$THREADS, ping包数量=$PING_COUNT, 超时时间=${PING_TIMEOUT}s${NC}"
    echo -e "${YELLOW}结果将分别保存到 $OK_FILE 和 $FALSE_FILE${NC}"
    echo -e "${YELLOW}按 Ctrl+C 可中断检测...${NC}"
    echo -e "${CYAN}------------------------------${NC}"
fi

# 循环检测所有IP（1-254）
for i in {1..254}; do
    IP="$SUBNET.$i"
    # 后台执行ping检测
    ping_ip "$IP" &
    
    # 控制并行进程数
    while (( $(jobs -r | wc -l) >= THREADS )); do
        wait -n  # 等待任一后台进程结束
    done
done

# 等待所有后台进程完成
wait

# 对结果进行排序（如果启用）
if [ $SORT_RESULTS -eq 1 ]; then
    sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n "$OK_FILE" -o "$OK_FILE"
    sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n "$FALSE_FILE" -o "$FALSE_FILE"
fi

##############################################
# 检测完成，输出统计结果
##############################################

# 计算执行时间
END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED_TIME / 60))
SECONDS=$((ELAPSED_TIME % 60))

# 统计数量
OK_COUNT=$(wc -l < "$OK_FILE")
FALSE_COUNT=$(wc -l < "$FALSE_FILE")

# 输出结果（始终显示，即使在安静模式）
echo -e "\n${BLUE}====================================${NC}"
echo -e "${BLUE}$(date +"%Y-%m-%d %H:%M:%S") - 检测完成！${NC}"
echo -e "${GREEN}可达 IP 数量: $OK_COUNT${NC}"
echo -e "${RED}不可达 IP 数量: $FALSE_COUNT${NC}"
echo -e "${YELLOW}总执行时间: ${MINUTES}分${SECONDS}秒${NC}"
echo -e "${BLUE}====================================${NC}"

# 输出结果文件路径
echo -e "${YELLOW}可达IP列表: $(realpath "$OK_FILE")${NC}"
echo -e "${YELLOW}不可达IP列表: $(realpath "$FALSE_FILE")${NC}"

exit 0

