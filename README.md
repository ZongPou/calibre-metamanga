# 漫元 MetaManga

**版本：** 1.0.0
**原项目作者：** RelUnrelated（<dan@relunrelated.com>）
**许可证：** GNU General Public License v3.0（GPLv3），详见 `LICENSE.md`。
**更新记录：** 详见 `CHANGELOG.md`。

## 项目简介

漫元是一个用于 Calibre 的 AI 元数据插件，直接读取文件名，并结合现有书籍元数据提取漫画标题、作者、丛书、卷号、语言和备注，在需要时翻译标题。

插件只发送文件名和元数据文本，不上传或分析封面图片。中文标题优先保留；日语、英语、韩语以及混合语言标题可以交给配置的 AI 翻译为简体中文。

项目基于 [calibre-ai-vision-metadata](https://github.com/RelUnrelated/calibre-ai-vision-metadata) 修改，并保留原项目的 GPL-3.0 许可证和内部配置兼容性。

## 主要功能

- 支持 Google Gemini、OpenAI、DeepSeek、Anthropic、OpenRouter，以及 Ollama / LM Studio 本地模型。
- 支持日语、英语、韩语和多语言混合标题识别与中文翻译。
- 从文件名和 Calibre 元数据中识别标题、作者、社团、翻译组、丛书、卷号、章节和备注。
- 支持批量分析、后台逐本处理、自动应用和逐本审核。
- 逐本审核窗口可以编辑标题、作者、丛书、序号、标签、语言、出版社、出版日期、标识符和备注。
- 兼具元数据编辑器功能：不依赖 AI 分析，可以直接在审核窗口手动编辑漫画元数据，逐字段选择覆盖或追加。
- 标签下拉列表读取当前 Calibre 书库正在使用的标签。
- 保留原始标题、原始文件名和分析记录，方便复核和恢复。
- 内置基于 Kavita 命名规则的卷号、章节号和范围识别逻辑。

## 使用演示

![审核 AI 元数据窗口](images/review-dialog.png)

插件分析完成后会打开“审核 AI 元数据”窗口，一次分析的全部结果集中呈现：

- **识别依据透明：** 左侧为封面预览；顶部显示所用 AI 模型、耗时、置信度和 tokens 消耗；正文列出原文标题、社团、汉化组、展会、标题来源和原文语言，方便快速核对 AI 判断依据。
- **全字段可编辑：** 标题、作者、丛书、序号、标签、语言、出版社、出版日期和标识符均可直接修改。
- **字段级合并控制：** 每个字段可单独选择“覆盖”或“追加”，避免误删已有元数据；标识符支持 `isbn:123, custom:value` 形式。
- **标签智能下拉：** 标签从当前 Calibre 书库已有标签中选择，选中后以逗号追加并自动去重，也可以直接输入新标签。
- **安全保存：** 底部提示 AI 结果可能存在错误，逐项审核后点击“确定”写入选定字段，“取消”则放弃本次修改。
- **元数据编辑器：** 该窗口也可脱离 AI 单独作为漫画元数据编辑器使用，手动整理标题、作者、丛书、序号、标签、出版社等字段。

## 安装

1. 下载 `MetaManga_v1.0.0.zip`，不要解压。
2. 打开 Calibre，进入“首选项 → 插件”。
3. 点击右下角“从文件加载插件”，选择该 ZIP 文件。
4. 确认安全提示并重启 Calibre。

## 文件名和元数据来源

插件直接读取文件名进行识别，无需创建自定义文件名列或手动复制文件名。

对于已经编辑过元数据的书籍，插件会同时读取现有元数据，方便在逐本审核窗口中检查、补充和修改。

插件会尽量保留已有的 Comments。空 Comments 会补充原始文件名或历史输入；已有内容不会被无故清空。分析历史中会保存标题来源、原始标题、AI 返回值、置信度和警告。

## 命名解析规则

支持卷号 `v02`、`Volume 02`、`vol_002`、`t02`、`第2册`、`2巻`、`Vol. 7.5` 和 `v1-v5`，也支持章节号 `ch015`、`Chapter 15.5`、`第15话`、`15話` 和 `ch1-ch6`。

出版物名称中的卷号不会误认为作品卷号，例如 `(COMIC magazine Vol.18)` 不会自动写入作品序号。章节号和范围不会写入 Calibre 的丛书序号。

## 配置

进入“首选项 → 插件”，找到“漫元 (MetaManga)”，双击打开配置窗口。

1. **AI 提供商：** 选择 Google Gemini、OpenAI、DeepSeek、Anthropic、OpenRouter 或本地模型。
2. **API 密钥 / 本地地址：** 云端服务填写 API 密钥；本地模型填写地址，例如 `http://localhost:11434`。
3. **模型：** 点击“获取可用模型”读取模型列表。
4. **提示词：** 可以为每个 AI 提供商单独编辑系统提示词。
5. **点击插件时直接应用 AI 元数据：** 勾选后直接写入结果；不勾选时进入审核流程。
6. 点击“应用”或“确定”保存。

API 密钥保存在 Calibre 用户配置目录中，不会写入插件 ZIP 或 GitHub 源码。Windows 默认位置通常是：

```text
%APPDATA%\calibre\plugins\metamanga.json
```

首次使用新版插件时，会自动将旧配置 `ai_vision_metadata.json` 中的 API 密钥、模型、提示词和设置复制到新配置中。已有的非空新配置不会被覆盖，旧文件保留作为备份。

不要把新旧配置文件、`.env` 文件或任何真实 API 密钥提交到远程仓库。

## 使用方法

1. 在 Calibre 书库中选择一本或多本书。
2. 点击工具栏中的“漫元 MetaManga”，或从右键菜单启动插件。
3. 插件会在后台逐本分析文件名和元数据文本。
4. 自动模式会在验证通过后写入支持的字段。
5. 逐本审核模式会显示 AI 建议和现有元数据，可以直接编辑后保存。窗口布局和各字段说明见上方“使用演示”。

## AI 服务

- [Google AI Studio](https://aistudio.google.com/app/apikey)：创建 Gemini API 密钥。
- [OpenAI Platform](https://platform.openai.com/api-keys)：创建 OpenAI API 密钥。
- [DeepSeek API Keys](https://platform.deepseek.com/api_keys)：创建 DeepSeek API 密钥。默认关闭思考模式以降低处理时间。
- [Anthropic Console](https://console.anthropic.com/settings/keys)：创建 Claude API 密钥。
- [OpenRouter](https://openrouter.ai/settings/keys)：创建 OpenRouter API 密钥并访问多个模型提供商。
- [Ollama](https://ollama.com/) / [LM Studio](https://lmstudio.ai/)：在本机运行模型，插件只发送文本。

## 运行结果和审核

“最近运行结果”会记录处理状态、请求次数、重试等待时间、响应长度、耗时、翻译状态、文件名角色置信度和警告。

如果 AI 无法可靠区分标题、作者或社团，自动模式会跳过写入，避免错误覆盖元数据。可以使用逐本审核窗口检查并手动修正。

## 开发和打包

运行单元测试：

```powershell
python -m unittest discover -s tests -v
```

构建安装包：

```powershell
powershell -ExecutionPolicy Bypass -File .\build_plugin.ps1
```

生成的安装包位于 `dist\MetaManga_v1.0.0.zip`。

## 许可证和致谢

本项目基于 [RelUnrelated/calibre-ai-vision-metadata](https://github.com/RelUnrelated/calibre-ai-vision-metadata) 修改，遵循 GPL-3.0。

卷号、章节号和范围识别规则参考了 [Kavita](https://github.com/Kareadita/Kavita)（一款开源的漫画/图书阅读器），并根据本项目的漫画文件命名习惯进行了适配。本项目使用的是选择性的规则适配，不包含完整的 Kavita 扫描器；具体说明见 `THIRD_PARTY_NOTICES.md`。
