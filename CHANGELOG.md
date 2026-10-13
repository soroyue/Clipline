# Changelog / 更新记录

## Unreleased

- Shared toolchain helpers in `scripts/toolchain.sh`, used by the build, test and install scripts.
- Installers now build against the newest installed macOS 26 SDK when the default SDK's SwiftUI needs a macro plugin the toolchain lacks, so Command Line Tools on macOS 27 can build the app.
- The test step is skipped with an actionable message instead of aborting the install when the toolchain has no XCTest; CI still runs the tests on every push.
- 抽取公共工具链探测逻辑，供编译、测试与安装脚本共用。
- 默认 SDK 的 SwiftUI 缺少宏插件时，自动改用已安装的最新版 macOS 26 SDK，macOS 27 上的 Command Line Tools 也能完成安装。
- 工具链不含 XCTest 时给出明确提示并跳过测试，不再中断安装；CI 仍在每次推送时运行测试。

## 0.2.0 — History, pause and timing / 历史管理、暂停与交互设置

- Unified All / Text / Images history, full-text and filename search.
- Persistent recording pause with menu-bar status and fresh-clipboard resume.
- Adjustable reveal, hide, return and new-content preview timing, with reset.
- Three display modes: original single-type layout or split text/image lanes.
- Universal, locally signed DMG with upstream license and notice included; not notarized.
- Redesigned original app icon in warm ivory and mist blue.
- Fifteen automated tests, including pause/resume and timing bounds.
- 统一历史分类与搜索；暂停记录与状态提示；交互时间设置及恢复默认；15 项测试。
- Includes the unreleased 0.1.1 changes below. / 包含以下尚未单独发布的 0.1.1 改动。

## 0.1.1 — Installation guide and compatibility / 安装指南与兼容性

- Remove the in-app update link; upgrades are manual through GitHub Releases.
- Remove local folder paths from screenshot watcher error logging.
- 移除应用内更新入口，改为手动下载；截图监听错误日志不再输出本机路径。

- Explicit main-actor isolation fixes compilation on the macOS 14 CI toolchain.
- Expanded bilingual requirements, source ZIP installation, troubleshooting, upgrade and removal instructions.
- 明确主线程隔离标注，修复 macOS 14 CI 工具链编译错误。
- 补充中英文系统要求、源码安装、排错、升级及卸载说明。

## 0.1.0 — Initial public source release / 首次公开源码发布

### Added / 新增
- Text clipboard capture alongside the upstream screenshot/image workflow.
- Local UTF-8 history, full-text hover previews, text search, deduplication and deletion.
- 文字与图片双模式；本地历史、全文预览、搜索、去重与删除。

### Improved / 改进
- Left text lane and right image lane, with the newest items at the centre.
- Independent lane scrolling, gentle return, and shorter ordinary dismissal.
- Pale oatmeal/mist-blue frames, larger text heading and multi-paragraph thumbnails.
- Uniform frame dimensions with proportional image fitting.
- 左右分组、中央最新、独立滚动与缓慢归中；统一边框、淡色夹子和更充分的文字摘要。

### Engineering / 工程
- Twelve automated tests; localization checks; universal macOS builds.
- Install script verifies signing and backs up existing Clipline installations.
- Independent app identity and icon; update link points to Clipline releases.
- 12 项测试、翻译检查、双架构构建与带备份的安装脚本。

### Known limitations / 已知限制
- No notarized installer; history is local but not encrypted.
- Visual, full-screen, multi-monitor and Intel runtime checks remain incomplete.
- 暂无公证安装包；历史未加密；视觉、多屏、全屏和 Intel 实机验收仍待完善。
