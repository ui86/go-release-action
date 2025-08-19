# Go Release GitHub Action

## Features
- Build `Go` binaries for release and publish to Github Release Assets.
- Customizable `Go` versions. `latest` by default.
- Support different `Go` project path in repository.
- Support multiple binaries in same repository.
- Customizable binary name.
- Support multiple `GOOS`/`GOARCH` build in parallel by [Github Action Matrix Strategy](https://help.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstrategymatrix) gracefully.
- Publish `.zip` for `windows` and `.tar.gz` for Unix-like OS by default, optionally to disable the compression.
- No `musl` library dependency issue on `linux`.
- Support extra command that will be executed before `go build`. You may want to use it to solve dependency if you're NOT using [Go Modules](https://github.com/golang/go/wiki/Modules).
- Rich parameters support for `go build`(e.g. `-ldflags`, etc.).
- Support package extra files into artifacts (e.g., `LICENSE`, `README.md`, etc).
- Support customize build command, e.g., use [packr2](https://github.com/gobuffalo/packr/tree/master/v2)(`packr2 build`) instead of `go build`. Another important usage is to use `make`(`Makefile`) for building on Unix-like systems.
- Support optional `.md5` along with artifacts.
- Support optional `.sha256` along with artifacts.
- Customizable release tag to support publish binaries per `push` or `workflow_dispatch`(manually trigger).
- Support overwrite assets if it's already exist.
- Support customizable asset names.
- Support private repositories.
- Support executable compression by [upx](https://github.com/upx/upx).
- Support retry if upload phase fails.    
- Support build multiple binaries and include them in one package(`.zip/.tar.gz`).       

## Usage

### Basic Example

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
    name: release linux/amd64
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: ui86/go-release-action@v1
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        goos: linux
        goarch: amd64
```