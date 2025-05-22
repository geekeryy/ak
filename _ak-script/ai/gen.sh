#!/bin/bash
AK_SUBSCRIPT_DIR=/usr/local/bin/_ak-script
source "$AK_SUBSCRIPT_DIR/lib/util.sh"

# DeepSeek终端智能助手
# 功能：通过Ctrl+G快捷键获取AI建议，直接将命令行中的描述转换成命令并输出到终端
# 使用前请先设置环境变量：export DEEPSEEK_API_KEY="your_api_key"
# TODO 支持多轮对话

# API请求函数
call_deepseek() {
    if [ -z "$DEEPSEEK_API_KEY" ]; then
        echo "[ERROR] 请先设置环境变量 DEEPSEEK_API_KEY"
        echo "示例：export DEEPSEEK_API_KEY=\"your_api_key\""
        return 0
    fi

    local prompt="$1"

    local os_info=$(uname -s)
    local shell_name=$(basename "${SHELL:-unknown}")

    # 转义用户输入中的特殊字符
    local escaped_prompt=$(printf '%s' "$prompt" | jq -Rs . | sed -e "s/^'//" -e "s/'$//")

    curl -s -X POST "https://api.deepseek.com/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${DEEPSEEK_API_KEY}" \
        -d @- <<EOF
{
    "model": "deepseek-chat",
    "messages": [
        {
            "role": "system",
            "content": "作为资深Linux系统管理员，请严格遵循以下规则：\n1. 仅输出可直接执行的命令行，不要添加任何前缀或注释\n2. 不包含任何解释性文字或多余空行\n3. 确保命令兼容${os_info}系统和${shell_name} shell\n4. 优先使用POSIX标准命令\n5. 危险操作需添加安全提示\n6. 输出的命令必须是完整正确的，可以直接复制粘贴作为命令执行的\n7. 不要使用Markdown格式或代码块"
        },
        {
            "role": "user",
            "content": ${escaped_prompt}
        }
    ],
    "temperature": 0.0,
    "max_tokens": 512,
    "stop": ["\n\n"]
}
EOF
}

# 主处理函数
generate_command() {
    # 获取当前输入
    local current_input
    if [ -n "$BASH" ]; then
        current_input="$READLINE_LINE"
    elif [ -n "$ZSH_VERSION" ]; then
        current_input="$BUFFER"
    fi

    # 空输入处理
    if [ -z "$current_input" ]; then
        echo "\n输入命令描述后按Ctrl+G获取AI建议"
        if [ -n "$BASH" ]; then
            READLINE_LINE="$original_input"
            READLINE_POINT=${#original_input}
        elif [ -n "$ZSH_VERSION" ]; then
            BUFFER="$original_input"
            CURSOR=${#original_input}
            # 保留提示符
            zle reset-prompt
        fi
        return 1
    fi

    # 保存原始输入，用于在解析失败时恢复
    local original_input="$current_input"

    # 显示等待指示器
    echo -n "⌛ 思考中..."

    # 调用API并处理结果
    local response=$(call_deepseek "$current_input")

    # 清除等待提示
    if [ -n "$BASH" ]; then
        echo -ne "\r\033[K"
    elif [ -n "$ZSH_VERSION" ]; then
        echo -ne "\r"
        echo -ne "\033[K"
    fi

    # 检查响应格式是否正确
    if ! echo "$response" | jq -e '.choices[0].message.content' &>/dev/null; then
        # 使用awk提取json中的content
        local suggestion=$(echo "$response" | awk -F '"content":' '{print $2}' | awk -F ',"logprobs"' '{print $1}' | tr -d '"' | tr -d "\n")
        if [ -z "$content" ]; then
            echo $response
            # 将原始输入恢复到命令行
            if [ -n "$BASH" ]; then
                READLINE_LINE="$original_input"
                READLINE_POINT=${#original_input}
            elif [ -n "$ZSH_VERSION" ]; then
                BUFFER="$original_input"
                CURSOR=${#original_input}
                # 保留提示符
                zle reset-prompt
            fi
            return 0
        fi
    else
        # 处理转义字符并清理命令
        local suggestion=$(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^```[[:alnum:]]*$//' -e 's/^```$//')
    fi

    # 检查建议是否为空
    if [ -z "$suggestion" ]; then
        echo "未获取到有效建议，请重试"
        # 将原始输入恢复到命令行
        if [ -n "$BASH" ]; then
            READLINE_LINE="$original_input"
            READLINE_POINT=${#original_input}
        elif [ -n "$ZSH_VERSION" ]; then
            BUFFER="$original_input"
            CURSOR=${#original_input}
            # 保留提示符
            zle reset-prompt
        fi
        return 0
    fi

    # 将原始输入添加到历史记录
    if [ -n "$BASH" ]; then
        history -s "$original_input"
        # 更新命令行内容
        READLINE_LINE="$suggestion"
        READLINE_POINT=${#suggestion}
    elif [ -n "$ZSH_VERSION" ]; then
        print -s "$original_input"
        # 更新命令行内容
        BUFFER="$suggestion"
        CURSOR=${#suggestion}
        # 保留提示符
        zle reset-prompt
    fi
}

# 绑定快捷键
if [ -n "$BASH" ]; then
    bind -x '"\C-g": generate_command'
elif [ -n "$ZSH_VERSION" ]; then
    zle -N generate_command
    bindkey '^G' generate_command
fi