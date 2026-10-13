# Changelog / 更新记录

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
