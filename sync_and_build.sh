#!/bin/bash
set -e

UPSTREAM_REPO="fs185085781/webos"
TARGET_REPO="nebstudio/webos"

# 获取上游latest tag的更新时间
UPSTREAM_LATEST_INFO=$(curl -s "https://hub.docker.com/v2/repositories/${UPSTREAM_REPO}/tags/latest")
UPSTREAM_LATEST_UPDATED=$(echo "$UPSTREAM_LATEST_INFO" | grep -oP '"last_updated":\s*"\K[^"]+')
echo "Upstream latest updated: $UPSTREAM_LATEST_UPDATED"

# 获取本地latest tag的更新时间
MY_LATEST_INFO=$(curl -s "https://hub.docker.com/v2/repositories/${TARGET_REPO}/tags/latest")
MY_LATEST_UPDATED=$(echo "$MY_LATEST_INFO" | grep -oP '"last_updated":\s*"\K[^"]+')
echo "My latest updated: $MY_LATEST_UPDATED"

# 如果本地latest不存在，MY_LATEST_UPDATED为空，直接构建
if [[ -z "$MY_LATEST_UPDATED" ]]; then
    echo "My repo has no latest, will build."
    NEED_BUILD=1
else
    # 比较更新时间（都为ISO时间，直接比较字符串即可）
    if [[ "$UPSTREAM_LATEST_UPDATED" > "$MY_LATEST_UPDATED" ]]; then
        echo "Upstream latest is newer, will build."
        NEED_BUILD=1
    else
        echo "No new update, exit."
        exit 0
    fi
fi

# 获取上游最新的非latest标签（即最新的正式版号）
UPSTREAM_TAGS=$(curl -s "https://hub.docker.com/v2/repositories/${UPSTREAM_REPO}/tags?page_size=10")
# 取第一个不是latest的tag
NEWEST_TAG=$(echo "$UPSTREAM_TAGS" | grep -oP '"name":\s*"\K[^"]+' | grep -v '^latest$' | head -1)
echo "Latest non-latest tag: $NEWEST_TAG"

# 多平台构建并推送
docker buildx create --use || true
docker buildx build \
    --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64,linux/ppc64le,linux/s390x \
    -t ${TARGET_REPO}:latest \
    -t ${TARGET_REPO}:${NEWEST_TAG} \
    --push .

echo "Build and push complete."
