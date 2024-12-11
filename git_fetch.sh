#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
RED_BOLD='\033[1;31m'
BLUE_BOLD='\033[1;34m'
ORANGE='\033[0;33m'
NC='\033[0m' # 无颜色

# 检查是否提供了 BASE_DIR 参数
if [ -z "$1" ]; then
    echo "Usage: bash $0 <base_directory>"
    exit 1
fi

# 使用传入的参数作为 BASE_DIR
BASE_DIR="$1"

# 初始化一个数组来存储有更新的仓库信息
updated_repos=()

# 遍历每个子目录（假设每个子目录都是一个 Git 仓库）
while IFS= read -r gitdir; do
    repo=$(dirname "$gitdir")
    cd "$repo" || continue
    
    # 获取仓库名称
    repo_name=$(basename "$repo")
    
    # 获取远程 URL
    repo_remote_url=$(git config --get remote.origin.url)
    
    echo -e "${BLUE_BOLD}Repo Name: $repo_name${NC}"
    echo -e "Repo Path: $repo"
    
    if [ -z "$repo_remote_url" ]; then
        echo -e "${ORANGE}No remote repository configured${NC}"
    else
        echo -e "Remote URL: $repo_remote_url"
        
        # 获取最新的远程更新
        git fetch -q
        
        # 检查是否有更新
        UPDATES=$(git log HEAD..origin/$(git rev-parse --abbrev-ref HEAD) --pretty=format:"%h %ad %s" --date=short)
        
        if [ -n "$UPDATES" ]; then
            # 计算总提交数
            TOTAL_COMMITS=$(echo "$UPDATES" | wc -l)
            
            # 显示前10个提交
            DISPLAY_COMMITS=$(echo "$UPDATES" | head -n 10)
            
            echo -e "${RED}Repository $repo_name has updates:${NC}"
            echo "$DISPLAY_COMMITS"
            
            # 如果超过10个提交，显示总数
            if [ "$TOTAL_COMMITS" -gt 10 ]; then
                echo -e "...and $((TOTAL_COMMITS - 10)) more commits."
            fi
            
            # 将有更新的仓库信息添加到数组
            updated_repos+=("$repo_name: $repo")
        else
            echo -e "${GREEN}No updates for $repo_name${NC}"
        fi
    fi
    
    # 添加间隔
    echo "----------------------------------------"
done < <(find "$BASE_DIR" -type d -name ".git")

# 列出所有有更新的仓库
if [ ${#updated_repos[@]} -gt 0 ]; then
    echo -e "${RED_BOLD}Repositories with updates:${NC}"
    for repo_info in "${updated_repos[@]}"; do
        echo "$repo_info"
    done
else
    echo -e "${GREEN}No repositories have updates.${NC}"
fi

