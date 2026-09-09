# Rockchip Ubuntu 构建

## 构建拓扑

Ubuntu 仓库的主要开发目录位于 ARM64 构建主机。手动修改代码后，可以
ARM64 主机完成 rootfs 构建和最小 QA，再提交到 Forgejo。

1. x86 主机编译内核模块、DT overlay 和其他依赖 SDK 的板级二进制；
2. 将二进制及其校验信息同步到 ARM64 主机上的 Ubuntu 开发目录；
3. ARM64 主机原生构建 Ubuntu rootfs，避免 x86 QEMU 构建经常崩溃；
4. 将 rootfs 构建结果同步回 x86 主机，使用仅支持 x86 的 Rockchip 工具合成
   可烧录镜像。

## 产品矩阵

| 变体 | 桌面 | 发行版 | 架构 |
| --- | --- | --- | --- |
| `server` | 无 | Ubuntu | arm64 |
| `desktop` | GNOME | Ubuntu | arm64 |
| `desktop-xfce` | XFCE | Ubuntu | arm64 |

Ubuntu rootfs 在非容器化 Debian/Ubuntu 主机上构建，原生 ARM64 为首选。
在 x86 上，构建产出目录默认是仓库的 `build/`；在 ARM64 上，手动 native 构建
与 Forgejo CI 必须通过 `BUILD_OUTPUT_DIR` 使用同一个构建产出目录。
构建主机和 Forgejo 环境搭建见
[ARM64-BUILD-HOST.md](docs/ARM64-BUILD-HOST.md)。

## Ubuntu Server rootfs


```bash
cp .env.example .env       # 按构建主机修改；不要提交 .env
./build.sh server --check  # 只检查配置和本机依赖
./build.sh server          # 构建 rootfs
```

ARM64 主机默认写入 `/var/lib/ubuntu-ci/build`，x86 主机默认写入仓库内的
`build/`。两者都可用 `.env` 的 `BUILD_OUTPUT_DIR` 覆盖。详细说明和产物定义见
[ubuntu-build.md](docs/ubuntu-build.md)。

## SDK 板级输入

内核 Image、DTB、DT overlay 和 modules 不进入 Git。先在 SDK 主机暂存并生成
SHA256 清单，再同步到 ARM64 手工构建和 Forgejo CI 共用的构建输出目录：

```bash
./scripts/stage-sdk-assets.sh
```

目录布局、同步和验收方法见 [SDK-ASSETS.md](docs/SDK-ASSETS.md)。

## x86 交叉编译 ARM64

在 x86_64 主机使用 GNU AArch64 交叉工具链。宿主机可以是 Debian 或 Ubuntu，
目标 Ubuntu 基础版本由
`.env` 的 `CROSS_BASE_TAG` 选择，不固化在脚本中。

```bash
CROSS_BASE_TAG="<ubuntu-base-tag>" ./scripts/cross-build-env.sh --prepare
CROSS_BASE_TAG="<ubuntu-base-tag>" ./scripts/cross-build-env.sh --check
```

完整配置、使用方式和版本迁移步骤见
[CROSS-COMPILE.md](docs/CROSS-COMPILE.md)。

