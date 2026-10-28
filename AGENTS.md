# AGENTS.md - WordBoBo

## 项目信息
- **名称**: 单词背背 (WordBoBo)
- **功能**: 拍照识别英语单词 + 三阶段科学记忆
- **技术栈**: SwiftUI + XcodeGen + Vision OCR + AVSpeechSynthesizer

## 关键规则
- 工程用 XcodeGen 生成，不要手动编辑 .xcodeproj
- 修改 project.yml 后运行 `xcodegen generate` 重新生成
- 不要引入外部依赖，所有功能用系统框架实现
- OCR 用 Vision 框架（本地免费），发音用 AVSpeechSynthesizer
- 词典数据存在 LocalDictionary.swift，新增词汇直接往字典里加

## 目录结构
- `WordBoBo/` - 主 App 源码
- `WordBoBo/Models/` - 数据模型
- `WordBoBo/Services/` - OCR、词典、存储服务
- `WordBoBo/Views/` - SwiftUI 视图
- `WordBoBo/Resources/` - Info.plist、entitlements
- `Tests/` - 单元测试

## CI
- Build & Test: `.github/workflows/build-test.yml`
- 未签名 IPA: `.github/workflows/build-unsigned-ipa.yml`
- 配置: `.ios-ci.yml`
