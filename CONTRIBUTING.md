# Contributing / 参与贡献

Please describe the problem, expected behavior, macOS version and reproduction
steps in an issue. Use synthetic clipboard content and redact screenshots.
请提供问题描述、预期行为、系统版本和复现步骤；使用合成测试内容，遮挡截图中的隐私。

For changes, create a branch and submit a pull request. Keep patches focused,
preserve upstream attribution, and use Clipline branding. Run:

```bash
swift test
swift scripts/check-strings.swift
bash scripts/build-app.sh debug
```

Test clipboard changes with isolated named pasteboards, never real personal
clipboard data. For UI changes, report which interactions and displays you
actually checked. Do not claim manual acceptance from unit tests alone.
提交请保留原作者署名，运行上述检查；剪贴板测试使用独立命名剪贴板，UI 改动说明实际验证范围。

Contributions are submitted under the repository's MIT license.
贡献代码按本仓库 MIT 许可证提交。
