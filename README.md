# Go 发布 GitHub Action

## 基于 [wangyoucao577/go-release-action](https://github.com/wangyoucao577/go-release-action) 的分支

## 功能特性
- 构建 `Go` 二进制文件并发布到 GitHub Release 资源。
- 可自定义 `Go` 版本，默认使用 `latest`。
- 支持仓库中不同的 `Go` 项目路径。
- 支持同一仓库中的多个二进制文件。
- 可自定义二进制文件名称。
- 通过 [GitHub Action 矩阵策略](https://help.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstrategymatrix) 优雅地支持多个 `GOOS`/`GOARCH` 并行构建。
- **🆕 自动交叉编译器安装**: 根据目标架构自动安装对应的GCC交叉编译器，支持CGO项目的多架构编译
- **🆕 支持多种架构**: ARM64, ARM, i386, MIPS, MIPS64, S390X, PowerPC64LE等架构的交叉编译
- 默认为 `Windows` 发布 `.zip` 文件，为类Unix系统发布 `.tar.gz` 文件，可选择禁用压缩。
- 在 `Linux` 上没有 `musl` 库依赖问题。
- 支持在 `go build` 之前执行额外命令。如果你没有使用 [Go Modules](https://github.com/golang/go/wiki/Modules)，可能需要用它来解决依赖问题。
- 丰富的 `go build` 参数支持（例如 `-ldflags` 等）。
- 支持将额外文件打包到制品中（例如 `LICENSE`、`README.md` 等）。
- 支持自定义构建命令，例如使用 [packr2](https://github.com/gobuffalo/packr/tree/master/v2)（`packr2 build`）代替 `go build`。另一个重要用途是在类Unix系统上使用 `make`（`Makefile`）进行构建。
- 支持可选的 `.md5` 校验文件。
- 支持可选的 `.sha256` 校验文件。
- 可自定义发布标签，支持按 `push` 或 `workflow_dispatch`（手动触发）发布二进制文件。
- 支持覆盖已存在的资源。
- 支持自定义资源名称。
- 支持私有仓库。
- 支持通过 [upx](https://github.com/upx/upx) 压缩可执行文件。
- 支持上传失败时重试。
- 支持构建多个二进制文件并将它们包含在一个包中（`.zip/.tar.gz`）。

## 使用方法

### 基础示例

```yaml
# .github/workflows/release.yaml

on:
  release:
    types: [created]

permissions:
    contents: write
    packages: write

jobs:
  release-linux-amd64:
    name: 发布 linux/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: ui86/go-release-action@v1.0.1
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        goos: linux
        goarch: amd64

## 🆕 交叉编译支持

本 Action 现在支持自动安装交叉编译器，让 CGO 项目也能轻松进行多架构编译。

### 支持的架构

| 架构 | 交叉编译器 | 说明 |
|------|------------|------|
| `amd64` | gcc (默认) | x86_64架构，默认支持 |
| `arm64` | gcc-aarch64-linux-gnu | ARM64架构 |
| `arm` | gcc-arm-linux-gnueabihf | ARM架构 |
| `386` | gcc-multilib | i386架构 |
| `mips` | gcc-mips-linux-gnu | MIPS架构 |
| `mipsle` | gcc-mipsel-linux-gnu | MIPS Little Endian |
| `mips64` | gcc-mips64-linux-gnuabi64 | MIPS64架构 |
| `mips64le` | gcc-mips64el-linux-gnuabi64 | MIPS64 Little Endian |
| `s390x` | gcc-s390x-linux-gnu | IBM S390X架构 |
| `ppc64le` | gcc-powerpc64le-linux-gnu | PowerPC64 Little Endian |

### CGO 控制

使用 `cgo_enabled` 参数控制是否启用 CGO 和交叉编译器安装：

```yaml
- uses: ui86/go-release-action@v1.0.1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    goos: linux
    goarch: arm64
    cgo_enabled: '1'  # 启用CGO，自动安装ARM64交叉编译器
```

- `cgo_enabled: '1'` (默认): 启用 CGO，根据目标架构自动安装交叉编译器
- `cgo_enabled: '0'`: 禁用 CGO，跳过交叉编译器安装，适用于纯 Go 项目

### 多架构并行构建示例

```yaml
strategy:
  matrix:
    include:
      - goos: linux
        goarch: amd64
        cgo_enabled: '1'
      - goos: linux
        goarch: arm64
        cgo_enabled: '1'  # 自动安装ARM64交叉编译器
      - goos: linux
        goarch: arm
        goarm: '7'
        cgo_enabled: '1'  # 自动安装ARM交叉编译器
      - goos: windows
        goarch: amd64
        cgo_enabled: '0'  # Windows通常禁用CGO
```

## 高级用法

### 完整的多架构发布工作流

```yaml
name: 发布多架构二进制文件

on:
  release:
    types: [created]
  push:
    tags:
      - 'v*'

permissions:
  contents: write
  packages: write

jobs:
  build-cross-platform:
    name: 构建 ${{ matrix.goos }}/${{ matrix.goarch }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          # Linux 各架构
          - goos: linux
            goarch: amd64
            cgo_enabled: '1'
          - goos: linux
            goarch: arm64
            cgo_enabled: '1'
          - goos: linux
            goarch: arm
            goarm: '7'
            cgo_enabled: '1'
          - goos: linux
            goarch: 386
            cgo_enabled: '1'

          # Windows 各架构
          - goos: windows
            goarch: amd64
            cgo_enabled: '0'
          - goos: windows
            goarch: 386
            cgo_enabled: '0'
          - goos: windows
            goarch: arm64
            cgo_enabled: '0'

          # macOS 各架构
          - goos: darwin
            goarch: amd64
            cgo_enabled: '0'
          - goos: darwin
            goarch: arm64
            cgo_enabled: '0'

    steps:
    - name: 检出代码
      uses: actions/checkout@v4

    - name: 构建并发布
      uses: ui86/go-release-action@v1.0.1
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        goos: ${{ matrix.goos }}
        goarch: ${{ matrix.goarch }}
        goarm: ${{ matrix.goarm }}
        cgo_enabled: ${{ matrix.cgo_enabled }}
        build_flags: '-v'
        ldflags: '-s -w -X main.version=${{ github.ref_name }}'
        executable_compression: 'upx --best --lzma'
        extra_files: 'LICENSE README.md'
```

### CGO 项目示例

对于需要 C 库依赖的项目：

```yaml
- name: 构建 CGO 项目
  uses: ui86/go-release-action@v1.0.1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    goos: linux
    goarch: arm64
    cgo_enabled: '1'  # 启用CGO，自动安装ARM64交叉编译器
    build_flags: '-v -tags cgo'
    pre_command: 'apt-get update && apt-get install -y libssl-dev'
```

### 纯 Go 项目示例

对于不需要 CGO 的纯 Go 项目：

```yaml
- name: 构建纯 Go 项目
  uses: ui86/go-release-action@v1.0.1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    goos: linux
    goarch: riscv64
    cgo_enabled: '0'  # 禁用CGO，跳过交叉编译器安装
    build_flags: '-v'
    ldflags: '-s -w'
```

## 参数说明

### 输入参数

| 参数名 | 描述 | 必需 | 默认值 |
|--------|------|------|--------|
| `github_token` | 用于上传发布资源到 GitHub 的 GITHUB_TOKEN | 是 | - |
| `goos` | 目标操作系统：darwin、freebsd、linux 等 | 是 | - |
| `goarch` | 目标架构：386、amd64、arm、s390x、loong64 等 | 是 | - |
| `goamd64` | AMD64 微架构级别：v1、v2、v3、v4 | 否 | - |
| `goarm` | ARM 微架构级别：ARMv5、ARMv6、ARMv7 | 否 | - |
| `gomips` | MIPS 微架构级别：hardfloat、softfloat | 否 | - |
| `goversion` | Go 编译器版本 | 否 | latest |
| `cgo_enabled` | 启用 CGO 进行交叉编译。设置为 0 禁用 CGO 并跳过交叉编译器安装 | 否 | '1' |
| `build_flags` | 传递给 go build 命令的额外参数 | 否 | - |
| `ldflags` | 提供给 -ldflags 参数的值 | 否 | - |
| `project_path` | 运行 `go build .` 的位置 | 否 | '.' |
| `binary_name` | 如果不想使用仓库基名，可指定其他二进制文件名 | 否 | - |
| `pre_command` | 在 `go build` 之前执行的额外命令，可用于解决依赖问题 | 否 | - |
| `build_command` | 实际构建二进制文件的命令，通常是 `go build` | 否 | 'go build' |
| `executable_compression` | 通过第三方工具压缩可执行二进制文件。目前仅支持 `upx` | 否 | - |
| `extra_files` | 将被打包到制品中的额外文件 | 否 | - |
| `md5sum` | 与制品一起发布 `.md5` 文件 | 否 | 'TRUE' |
| `sha256sum` | 与制品一起发布 `.sha256` 文件 | 否 | 'FALSE' |
| `release_tag` | 上传二进制文件到由 Git 标签指定的发布页面 | 否 | - |
| `release_name` | 上传二进制文件到由发布名称指定的发布页面 | 否 | - |
| `release_repo` | 上传二进制文件的仓库 | 否 | - |
| `overwrite` | 如果资源已存在则覆盖 | 否 | 'FALSE' |
| `asset_name` | 如果不想使用默认格式，可自定义资源名称 | 否 | - |
| `retry` | 上传失败时重试次数 | 否 | '3' |
| `post_command` | 用于清理工作的额外命令 | 否 | - |
| `compress_assets` | 上传前压缩资源 | 否 | 'TRUE' |
| `upload` | 是否上传发布资源 | 否 | 'TRUE' |
| `multi_binaries` | 一起构建和打包多个二进制文件 | 否 | 'FALSE' |

### 输出参数

| 参数名 | 描述 |
|--------|------|
| `release_asset_dir` | 提供给其他工作流使用的发布文件目录 |

## 常见问题

### Q: 什么时候需要启用 CGO？
A: 当你的 Go 项目使用了 C 库或包含 `import "C"` 语句时，需要启用 CGO。纯 Go 项目可以禁用 CGO 以获得更快的构建速度。

### Q: 为什么只有 Linux 目标支持交叉编译器安装？
A: 因为 Action 运行在 Linux 容器中，只能为 Linux 目标安装交叉编译器。Windows 和 macOS 目标通常使用纯 Go 编译，不需要 C 编译器。

### Q: 如何为特定架构添加自定义依赖？
A: 使用 `pre_command` 参数在构建前安装依赖：
```yaml
pre_command: 'apt-get update && apt-get install -y libssl-dev'
```

### Q: 支持哪些压缩工具？
A: 目前支持 UPX 压缩工具。使用示例：
```yaml
executable_compression: 'upx --best --lzma'
```

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个 Action！

## 许可证

本项目基于原项目的许可证发布。