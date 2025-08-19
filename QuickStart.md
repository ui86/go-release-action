# Go Release Action 快速开始指南

## 🚀 5分钟上手

### 1. 基础设置

在你的 Go 项目根目录创建 `.github/workflows/release.yml` 文件：

```yaml
name: 发布

on:
  release:
    types: [created]

permissions:
  contents: write
  packages: write

jobs:
  release:
    name: 发布二进制文件
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: ui86/go-release-action@v1.0.1
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        goos: linux
        goarch: amd64
```

### 2. 多架构发布

```yaml
name: 多架构发布

on:
  release:
    types: [created]

permissions:
  contents: write
  packages: write

jobs:
  release:
    name: 发布 ${{ matrix.goos }}/${{ matrix.goarch }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - goos: linux
            goarch: amd64
          - goos: linux
            goarch: arm64
          - goos: windows
            goarch: amd64
          - goos: darwin
            goarch: amd64
          - goos: darwin
            goarch: arm64

    steps:
    - uses: actions/checkout@v4
    - uses: ui86/go-release-action@v1.0.1
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        goos: ${{ matrix.goos }}
        goarch: ${{ matrix.goarch }}
```

### 3. CGO 项目支持

如果你的项目使用了 CGO（包含 C 代码），启用交叉编译器：

```yaml
- uses: ui86/go-release-action@v1.0.1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    goos: linux
    goarch: arm64
    cgo_enabled: '1'  # 启用 CGO，自动安装 ARM64 交叉编译器
```

### 4. 高级配置

```yaml
- uses: ui86/go-release-action@v1.0.1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    goos: linux
    goarch: amd64
    # 自定义二进制文件名
    binary_name: 'my-app'
    # 构建标志
    build_flags: '-v'
    # 链接标志
    ldflags: '-s -w -X main.version=${{ github.ref_name }}'
    # 压缩可执行文件
    executable_compression: 'upx --best'
    # 包含额外文件
    extra_files: 'LICENSE README.md config.yaml'
    # 生成校验文件
    md5sum: 'TRUE'
    sha256sum: 'TRUE'
```

## 📋 常用配置模板

### 纯 Go 项目（推荐）

```yaml
name: 发布

on:
  release:
    types: [created]
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  release:
    name: 发布 ${{ matrix.goos }}/${{ matrix.goarch }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - goos: linux
            goarch: amd64
          - goos: linux
            goarch: arm64
          - goos: linux
            goarch: arm
            goarm: '7'
          - goos: windows
            goarch: amd64
          - goos: windows
            goarch: 386
          - goos: darwin
            goarch: amd64
          - goos: darwin
            goarch: arm64

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
        cgo_enabled: '0'  # 纯 Go 项目禁用 CGO
        build_flags: '-v'
        ldflags: '-s -w'
        extra_files: 'LICENSE README.md'
```

### CGO 项目

```yaml
name: CGO 项目发布

on:
  release:
    types: [created]

permissions:
  contents: write

jobs:
  release:
    name: 发布 ${{ matrix.goos }}/${{ matrix.goarch }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
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
          # Windows 和 macOS 通常禁用 CGO
          - goos: windows
            goarch: amd64
            cgo_enabled: '0'
          - goos: darwin
            goarch: amd64
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
        ldflags: '-s -w'
        # 如果需要额外的 C 库
        pre_command: 'apt-get update && apt-get install -y libssl-dev'
```

## 🔧 故障排除

### 常见问题

1. **构建失败：找不到 C 编译器**
   - 确保设置了 `cgo_enabled: '1'`
   - 检查目标架构是否支持

2. **二进制文件太大**
   - 使用 `ldflags: '-s -w'` 去除调试信息
   - 启用 `executable_compression: 'upx --best'`

3. **依赖问题**
   - 使用 `pre_command` 安装依赖
   - 确保使用 Go Modules

### 调试技巧

1. **查看构建日志**
   - 在 GitHub Actions 页面查看详细日志

2. **本地测试**
   ```bash
   # 测试不同架构的构建
   GOOS=linux GOARCH=arm64 go build .
   ```

3. **验证二进制文件**
   ```bash
   # 检查二进制文件架构
   file your-binary
   ```

## 📚 更多资源

- [完整文档](README.md)
- [示例工作流](example-cross-compile.yml)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Go 交叉编译指南](https://golang.org/doc/install/source#environment)

## 💡 最佳实践

1. **版本标签**：使用语义化版本标签（如 `v1.0.0`）
2. **测试**：在发布前先测试构建流程
3. **文档**：在 README 中说明支持的平台
4. **安全**：不要在日志中暴露敏感信息
5. **性能**：对于纯 Go 项目，禁用 CGO 以获得更好的性能
