# WordBoBo - 单词背背

拍照识别英语单词，三阶段科学记忆法。

## 功能

- **拍照识别**: 用相机拍摄单词表，苹果 Vision 框架本地 OCR 识别，完全免费
- **手动输入**: 直接粘贴或输入单词列表
- **三阶段学习**:
  1. 认词阶段：显示中文+音标+词性，点击听发音
  2. 判断阶段：显示英文，点"会"/"不会"
  3. 拼写阶段：显示中文+音标，输入英文拼写
- **智能复习**: 不会的单词自动进入下一轮，直到全部掌握
- **学习记录**: 查看历史学习统计

## 技术栈

- SwiftUI + iOS 17+
- Vision 框架（本地 OCR，免费）
- AVSpeechSynthesizer（本地发音）
- XcodeGen 生成工程
- 内置词典数据，无需 API

## 打包

push 代码到 GitHub 后，GitHub Actions 会自动编译生成未签名 IPA，在 Actions 页面下载即可。

## 签名安装

下载未签名 IPA 后，用你本地的证书和描述文件签名安装：
```bash
# 示例：用 xcodebuild 签名
xcodebuild -exportArchive -archivePath YourApp.xcarchive -exportPath ./output -exportOptionsPlist ExportOptions.plist
```

或使用 Apple Configurator / Xcode 直接安装。
