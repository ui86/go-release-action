#!/bin/bash -eux

# 设置交叉编译器脚本
# 根据目标架构安装对应的GCC交叉编译器，支持CGO编译

setup_cross_compiler() {
    # 检查是否启用CGO，默认情况下CGO_ENABLED=1
    if [ "${CGO_ENABLED:-1}" = "0" ]; then
        echo "CGO已禁用，跳过交叉编译器安装"
        return 0
    fi

    # 检查是否为Linux目标系统，只有Linux需要交叉编译器
    if [ "${INPUT_GOOS}" != "linux" ]; then
        echo "目标系统不是Linux (${INPUT_GOOS})，跳过交叉编译器安装"
        return 0
    fi

    echo "检测目标架构: ${INPUT_GOARCH}"
    
    # 根据不同架构安装对应的交叉编译器
    case "${INPUT_GOARCH}" in
        "arm64"|"aarch64")
            echo "安装ARM64交叉编译器..."
            apt-get update -qq
            apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
            export CC=aarch64-linux-gnu-gcc
            export CXX=aarch64-linux-gnu-g++
            echo "ARM64交叉编译器安装完成: $(${CC} --version | head -n1)"
            ;;
        "arm")
            echo "安装ARM交叉编译器..."
            apt-get update -qq
            apt-get install -y gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
            export CC=arm-linux-gnueabihf-gcc
            export CXX=arm-linux-gnueabihf-g++
            echo "ARM交叉编译器安装完成: $(${CC} --version | head -n1)"
            ;;
        "386")
            echo "安装i386交叉编译器..."
            apt-get update -qq
            apt-get install -y gcc-multilib g++-multilib
            export CC="gcc -m32"
            export CXX="g++ -m32"
            echo "i386交叉编译器安装完成"
            ;;
        "mips")
            echo "安装MIPS交叉编译器..."
            apt-get update -qq
            apt-get install -y gcc-mips-linux-gnu g++-mips-linux-gnu
            export CC=mips-linux-gnu-gcc
            export CXX=mips-linux-gnu-g++
            echo "MIPS交叉编译器安装完成: $(${CC} --version | head -n1)"
            ;;
        "mipsle")
            echo "安装MIPS Little Endian交叉编译器..."
            apt-get update -qq
            apt-get install -y gcc-mipsel-linux-gnu g++-mipsel-linux-gnu
            export CC=mipsel-linux-gnu-gcc
            export CXX=mipsel-linux-gnu-g++
            echo "MIPS Little Endian交叉编译器安装完成: $(${CC} --version | head -n1)"
            ;;
        "mips64")
            echo "安装MIPS64交叉编译器..."
            apt-get update -qq
            apt-get install -y gcc-mips64-linux-gnuabi64 g++-mips64-linux-gnuabi64
            export CC=mips64-linux-gnuabi64-gcc
            export CXX=mips64-linux-gnuabi64-g++
            echo "MIPS64交叉编译器安装完成: $(${CC} --version | head -n1)"
            ;;
        "mips64le")
            echo "安装MIPS64 Little Endian交叉编译器..."
            apt-get update -qq
            apt-get install -y gcc-mips64el-linux-gnuabi64 g++-mips64el-linux-gnuabi64
            export CC=mips64el-linux-gnuabi64-gcc
            export CXX=mips64el-linux-gnuabi64-g++
            echo "MIPS64 Little Endian交叉编译器安装完成: $(${CC} --version | head -n1)"
            ;;
        "s390x")
            echo "安装S390X交叉编译器..."
            apt-get update -qq
            apt-get install -y gcc-s390x-linux-gnu g++-s390x-linux-gnu
            export CC=s390x-linux-gnu-gcc
            export CXX=s390x-linux-gnu-g++
            echo "S390X交叉编译器安装完成: $(${CC} --version | head -n1)"
            ;;
        "ppc64le")
            echo "安装PowerPC64 Little Endian交叉编译器..."
            apt-get update -qq
            apt-get install -y gcc-powerpc64le-linux-gnu g++-powerpc64le-linux-gnu
            export CC=powerpc64le-linux-gnu-gcc
            export CXX=powerpc64le-linux-gnu-g++
            echo "PowerPC64 Little Endian交叉编译器安装完成: $(${CC} --version | head -n1)"
            ;;
        "amd64"|"x86_64")
            echo "使用默认的AMD64编译器"
            # 默认编译器已经支持amd64，无需额外安装
            export CC=gcc
            export CXX=g++
            echo "AMD64编译器: $(${CC} --version | head -n1)"
            ;;
        *)
            echo "警告: 未知架构 ${INPUT_GOARCH}，使用默认编译器"
            export CC=gcc
            export CXX=g++
            ;;
    esac

    # 显示编译器信息
    echo "当前编译器设置:"
    echo "  CC=${CC}"
    echo "  CXX=${CXX}"
    echo "  目标架构: ${INPUT_GOOS}/${INPUT_GOARCH}"
}

# 执行交叉编译器设置
setup_cross_compiler
