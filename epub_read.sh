#!/usr/bin/env bash
# EPUB 阅读工具 — 使用 pandoc 提取文本
# 用法: ./epub_read.sh <文件.epub> [选项]

set -euo pipefail

EPUB="$1"
shift 2>/dev/null || true

check_tools() {
    if ! command -v pandoc &>/dev/null; then
        echo "错误: 需要安装 pandoc" >&2
        exit 1
    fi
    if [[ ! -f "$EPUB" ]]; then
        echo "错误: 文件不存在 — $EPUB" >&2
        exit 1
    fi
}

# 提取纯文本到标准输出
extract_text() {
    pandoc "$EPUB" -t plain --wrap=none 2>/dev/null
}

# 列出目录
list_toc() {
    echo "============================================================"
    echo "文件: $(basename "$EPUB")"
    echo "============================================================"
    echo ""
    extract_text | awk '
        /^目[录錄]|^目次|^CONTENTS|^Table of Contents|^目录|^目錄/ { in_toc=1; next }
        /^自序|^前言|^序言|^引言|^第一章|^第1章|^第一回|^第1回|^上篇|^上卷|^第一部|^Part |^Chapter |^CH / { in_toc=0 }
        in_toc && /./ { printf "    %s\n", $0 }
    '
    echo ""
    echo "--- 章节列表 ---"
    echo ""
    extract_text | awk '
        /^第[一二三四五六七八九十百千0-9]+[章节回篇卷部]|^[0-9]+\./ { printf "  %s\n", $0 }
        /^Part [0-9]+|^Chapter [0-9]+|^CH[0-9]+/ { printf "  %s\n", $0 }
    '
}

# 读取全部文本，分页显示
read_all() {
    local outfile="/tmp/epub_output_$$.txt"
    extract_text > "$outfile"
    echo "已保存到: $outfile"
    echo "总行数: $(wc -l < "$outfile")"
    echo "总字数: $(wc -m < "$outfile")"
    echo ""
    echo "--- 前 200 行预览 ---"
    head -200 "$outfile"
}

# 搜索关键词上下文
search_text() {
    local keyword="$1"
    extract_text | grep -i -C 5 "$keyword" | head -200 || echo "未找到匹配内容"
}

# 前缀匹配段落（用于标题查找）
find_section() {
    local title="$1"
    extract_text | awk -v t="$title" '
        $0 ~ t { found=1 }
        found { print }
        found && NR > start+500 { exit }
        found && NR==start+1 { start=NR }
    ' | head -500
}

show_help() {
    cat <<'HELP'
用法: ./epub_read.sh <文件.epub> [命令] [参数]

命令:
  (无参数)      输出全部文本
  -l            列出目录
  -s <关键词>   搜索关键词（含上下文）
  -f <标题>     查找并输出指定章节
  -o <文件>     保存到指定文件
  -h            显示帮助

示例:
  ./epub_read.sh 书.epub -l              # 看目录
  ./epub_read.sh 书.epub -s "蛋白质"      # 搜索
  ./epub_read.sh 书.epub -o 输出.txt      # 导出全文
HELP
}

check_tools

case "${1:-}" in
    -l|--list)
        list_toc
        ;;
    -s|--search)
        search_text "${2:-}"
        ;;
    -f|--find)
        find_section "${2:-}"
        ;;
    -o|--output)
        extract_text > "${2:-/dev/stdout}"
        echo "已保存到: ${2}"
        ;;
    -h|--help)
        show_help
        ;;
    *)
        extract_text
        ;;
esac
