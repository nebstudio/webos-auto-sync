#!/bin/bash
set -e

UPSTREAM_REPO="fs185085781/webos"
TARGET_REPO="nebstudio/webos"

# 获取上游最新tag
TAG=$(curl -s "https://hub.docker.com/v2/repositories/${UPSTREAM_REPO}/tags?page_size=1" | grep -Po '"name":.*?[^\\]",' | head -1 | awk -F'"' '{print $4}')

echo "Latest upstream tag: $TAG"

# 获取上次同步的tag
LAST_TAG=""
if [ -f last_tag.txt ]; then
    LAST_TAG=$(cat last_tag.txt)
fi

echo "Last synced tag: $LAST_TAG"

if [ "$TAG" == "$LAST_TAG" ]; then
    echo "No new tag. Exiting."
    exit 0
fi

echo "New tag detected: $TAG. Building and pushing..."

# 多平台构建并推送
docker buildx create --use || true
docker buildx build \
    --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64,linux/ppc64le,linux/s390x \
    -t ${TARGET_REPO}:${TAG} \
    -t ${TARGET_REPO}:latest \
    --push .

# 更新记录
echo "$TAG" > last_tag.txt

echo "Build and push complete."
