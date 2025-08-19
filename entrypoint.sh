#!/bin/bash -eux

# 准备golang环境
source /setup-go.sh

# 设置交叉编译器（如果需要CGO支持）
source /setup-cross-compiler.sh

# 方便调试，显示环境信息
go version
env

# 构建并发布go二进制文件
/release.sh

