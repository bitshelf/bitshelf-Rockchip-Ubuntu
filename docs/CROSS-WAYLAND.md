# Wayland ARM64 交叉编译与打包示例

该示例在 x86_64 Debian/Ubuntu 宿主机中，从所选 Ubuntu 基础版本的软件源获取
`wayland` source package 和对应 Build-Depends，交叉构建发行版原生 `.deb`。

## 构建

先按 [CROSS-COMPILE.md](CROSS-COMPILE.md) 配置 `.env` 的 `CROSS_BASE_TAG`，然后执行：

```bash
./scripts/build-cross-example.sh wayland
```

构建设置 `cross nodoc nocheck` profile，避免在 x86 构建期运行 ARM64 测试程序；目标板运行时 QA 应在 Wayland/SOC 适配功能中单独补充。

## 产物与最小 QA

产物位于 `build/cross/packages/wayland/`，包含 `*.deb`、`build-info` 和 `SHA256SUMS`。
所有 ARM64 包内 ELF 均须通过 `AArch64` 检查，成功标志为：

```text
CROSS_DEB_EXAMPLE_OK=wayland
```

安装前可再次校验：

```bash
cd build/cross/packages/wayland
sha256sum -c SHA256SUMS
dpkg-deb -f ./*.deb Package Version Architecture
```
