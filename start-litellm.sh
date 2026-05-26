#!/bin/bash

if [ -z "$LLAMA_API_BASE" ]; then
    echo "Error: กรุณาตั้งค่า LLAMA_API_BASE ก่อน"
    echo "ตัวอย่าง: export LLAMA_API_BASE=http://192.168.1.100:8080/v1"
    exit 1
fi

litellm --config "$HOME/.claude/litellm_config.yaml" --port 4000
