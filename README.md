# 漫元 MetaManga

**Version:** 1.6.30
**Author:** RelUnrelated (<dan@relunrelated.com>)  
**License:** GNU General Public License v3.0 (GPLv3) — See the `LICENSE.md` file for details.  
**Changelog:** See the `CHANGELOG.md` file for release history and updates.  

---

## Overview
This customized calibre plugin extracts manga metadata from `#original_filename`. It never uploads or analyzes cover images.

An explicit Chinese title in the filename always wins. If no Chinese title exists, the configured AI may translate the Japanese title into Simplified Chinese. The default action analyzes selected books sequentially and writes supported nonempty metadata automatically. An optional Review Each action remains available for manual editing.

The AI now distinguishes title, personal authors, circle, and annotations by meaning, returning verbatim source quotes in the same request as its translation. Rules provide candidates rather than forcing the first bracket to be the author. The plugin verifies that quotes occur in the selected input and preserves clear Chinese title wording and explicit Circle(Author) evidence. Uncertain classifications, role confidence below 0.8, and invalid assignments are skipped automatically; inspect **Last Run Results** or choose **Review Each** to resolve them. If a provider omits the new role object, the previous parsing behavior remains available for compatibility. This instruction is appended even to saved prompts; upgrading does not require another request per book or a prompt reset.

For reliable analysis of existing books, create a calibre custom text column with lookup name `#original_filename` and place the source filename there. New import-hook capture is planned for a later phase; a renamed calibre path is treated only as an uncertain fallback.

Use **Analyze Selected Books (Auto Apply)** or the toolbar button to process one or many selected books without confirmation dialogs. Books are analyzed and written one at a time; failures and conflicts are skipped automatically. Use **Last Run Results** to inspect the outcome. Choose **Analyze Selected Books (Review Each)** explicitly if you want per-book editing. Filename-derived title, author, supported series/volume, language, and original-filename Comments remain available. Circle, translation group, event, and edition evidence are preserved in analysis records and the optional review dialog. AI suggestions for tags, publisher, publication dates, and identifiers remain empty and unchecked. You can enter these fields manually and check them for writing.

The review dialog can display the local calibre cover for manual comparison; it is never included in any provider request.

Han/kanji characters alone do not identify Chinese. For a title without kana, the parser records `han_ambiguous` and asks the AI for the quoted source title's language (`filename_roles.title_language`: `zh`, `ja`, or `unknown`) in the same request. A validated Japanese classification permits translation, e.g. `放課後2` becomes `放学后 2`; Chinese classifications preserve source wording. A separate Chinese title paired with a kana-bearing Japanese original remains protected. Unknown Han-title language is skipped automatically. The instruction is appended to saved prompts without requiring a prompt reset. Older responses that omit the language field retain conservative source wording. Review and analysis records show the source-language hint. Halfwidth kana is also recognized as Japanese evidence.

Japanese titles that mix simplified-looking Han characters with kana must still be translated in full. Kana-bearing translation candidates are rejected, and a valid Chinese `title` can replace a source echo in `translated_title`. Normally analysis uses one request. If a Japanese title remains untranslated or its filename roles are uncertain, the plugin makes at most one corrective metadata request with the same provider/model (which may incur an additional provider charge). All quote and confidence checks still apply; continued uncertainty or a missing translation skips automatic writes. Last Run Results → Show Details now includes source/provider/final titles, translation status, verified role confidence, warnings, and correction request metrics.

DeepSeek requests now disable thinking by default and limit completion output to 2048 tokens. Enable **DeepSeek: enable thinking (slower)** in settings if desired (8192-token cap). See [DeepSeek's thinking-mode documentation](https://api-docs.deepseek.com/guides/thinking_mode/) for the API control. Requests ask for compact JSON and avoid duplicate parser evidence. Results show `reasoning_tokens` when the provider reports them; unavailable counts remain null. These changes target provider generation time, not a guaranteed per-book time limit.

Roles now include a separate `title_confidence`. If overall roles are uncertain but title confidence is at least 0.85, the quoted title exactly matches the deterministic unbracketed title, language is classified, and all quote/conflict checks pass, the plugin can apply only title and supported filename Comments. Authors, series/index, and language remain untouched. This `title_only` status avoids an unnecessary correction request for an already translated, confidently identified title. Uncertain title identification still skips writing, and legacy responses without separate title confidence retain their previous checks. All normal library/snapshot/Comments-preservation checks still apply.

AI title numbering is checked locally before writing. If the source work has no volume/chapter/range evidence, unsupported explicit markers and added numeric suffixes are removed from the proposed translation. For example, `好きな子はいじめたくなるモノ (COMIC 阿吽 改 Vol.18)` cannot become a translated title ending in `18`; the `Vol.18` belongs to the publication. Internal source-title digits and possible written-numeral conversions remain intact. Raw provider titles, original filename/Comments, and a correction warning remain in the analysis record. This local check adds no API request and targets numbering rather than validating every semantic number inside a translation.

## Key Features

* **Multi-Provider Routing:** Seamlessly switch between cloud-based AI models (Google Gemini, OpenAI, DeepSeek, Anthropic, OpenRouter) or route requests to your own local, offline models using Ollama or LM Studio.
* **Sequential Batch Processing:** Select multiple publications at once. The plugin intelligently queues the requests in the background, preventing rate-limit bans and UI lockups.
* **Filename-only analysis:** Extract titles and related manga metadata without sending the cover image to an AI provider.
* **Isolated Memory Banks:** The configuration menu securely remembers your distinct API keys, model selections, and custom system prompts for every individual provider.
* **Advanced Prompt Tuning:** Directly edit the AI's core instructions to fine-tune extraction behavior for the unique quirks of your specific collection.
* **Thread-Safe Architecture:** Background processing ensures your main Calibre window never freezes, while gracefully catching and reporting network or API errors.

## Installation
Since this is a custom plugin, it must be installed manually through Calibre's interface.

1. Download the `MetaManga_v1.6.30.zip` plugin file. *(Do not unzip this plugin file)*.
2. Open Calibre and click on **Preferences** (the gear icon) in the top toolbar.
3. Under the "Advanced" section, click on **Plugins**.
4. Click the **Load plugin from file** button in the bottom right corner.
5. Navigate to and select the `MetaManga_v1.6.30.zip` file.
6. Click **Yes** to accept the security warning and install the plugin.
7. Restart Calibre for the changes to take effect.

## Source filenames and upgrades

After installation, restart calibre, select DeepSeek in the plugin settings, click **Restore Default** once, and save. Existing API keys remain in calibre's plugin configuration; the ZIP does not contain them.

Populate the custom text column `#original_filename` with the complete original source filename. When this field is empty, the plugin explicitly labels the calibre directory fallback as unreliable, removes only its matching book-ID suffix (for example `(2)` for book ID 2), and marks the source as uncertain. The directory is never written into `#original_filename` or automatically copied into Comments.

Comments uses the complete `#original_filename` text when available. Otherwise, the plugin first tries to recover filename/input text from this book's analysis history, including the title saved before older releases renamed it. If no backup exists, it captures the complete current title before replacing it. These backups fill empty Comments and preserve existing nonempty Comments; their source is shown in optional review and stored for subsequent runs. AI summaries are ignored. A current-title snapshot is not a verified original filename: if the original text has already been lost from both metadata and history, supply it in `#original_filename` to restore it accurately. Re-run selected books to fill empty Comments after upgrading.

For filenames such as `[悠木ヒロ]僕は谁と付き合えばいいのだろうか[中国翻译][禁漫去码]`, the middle text `僕は谁と付き合えばいいのだろうか` is the original title, `悠木ヒロ` is the author, and the trailing brackets are annotations. A Japanese original can still be translated into Simplified Chinese. Rules prefer unbracketed title text; validated AI roles can correct ambiguous bracket positions in other layouts. AI output that simply repeats an annotation as its title is rejected. Recovered historical input also takes precedence over an incorrectly renamed current title when the source column is missing.

If the source contains only author/group/event metadata and no title, the plugin cannot recover the book name from that source. It parses the current title as a second source, removing author/circle/translation groups. Explicit Chinese titles are preserved, and Japanese title evidence can be translated by the AI. Every nonempty title is checked by default in the optional review dialog, including titles recovered from this secondary source. If neither input contains a title, automatic mode skips that book and preserves its metadata. Use the local cover to enter the title manually or supply the complete source filename. A parenthesized numeric suffix alone is never used as volume evidence; real title numbers such as `直到紫藤花开2` still produce volume 2.

Series suggestions require a volume marker or terminal title number in the source text. Standalone works do not populate series/index, even if the AI repeats the title in its series field. Existing library series values are preserved when no supported replacement exists; previously written values are not cleared automatically.

The explicit numbering rules adapt Kavita's scanner conventions to Python (see `THIRD_PARTY_NOTICES.md`). Supported examples include `v02`, `Volume 02`, `vol_002`, `t02`, `tome 2`, `第2册`, `2巻`, decimal volumes such as `Vol. 7.5`, and ranges such as `v1-v5`. Explicit chapters include `ch015`, `Chapter 15.5`, `第15话`, `15話`, and `ch1-ch6`. Standalone `[Vol. 2]` / `(Ch.15)` groups are recognized; a publication name such as `(COMIC magazine Vol.18)` cannot supply the work's volume. The first explicit marker of each kind wins; repeated labels inside a true range remain a range.

Local rules take precedence: C/c followed by 2-4 digits is an event code, Circle(Author) retains its creator meaning, and bare terminal title numbers remain volumes. Chapter numbers/ranges stay separate from `issue_number` and calibre's numeric series index. For example, `作品 v02 ch015` becomes title `作品 2 第15话`, series `作品`, index `2`; `作品 ch015` becomes `作品 第15话` without replacing the existing series/index. A volume range such as `作品 Vol. 1-5` stays in the title and analysis record, without suggesting a single series/index. Optional review displays chapter and range evidence. Original filename/Comments, Chinese wording, AI quote validation, and Japanese translation behavior remain in place. This is a selective naming-rule adaptation, not the full Kavita scanner.

For numbered works, title uses the base name followed by one space and the source volume number. For example, `直到紫藤花盛开2` becomes title `直到紫藤花盛开 2`, series `直到紫藤花盛开`, and index `2`. Series always follows the final title's base wording, including AI translations; a different AI series name is ignored. Compact numbers and explicit markers such as `第2卷` are formatted consistently. The original filename and its Comments suggestion remain unchanged. This rule is enforced by the plugin even with a previously saved prompt.

**Last Run Results** includes total analysis time, request attempts, retry wait, response length, and per-attempt header/body timings. These timings include network and provider waiting; they do not identify the provider's internal processing stages. HTTP 429/503 retries use 2-second and 4-second backoff. Output token counts are included when returned by the provider.

## Configuration
Before using the tool, you must configure it with an API key or a local server address.

1. Go to **Preferences > Plugins** and locate **漫元 (MetaManga)** under the *User interface action* category. Double-click to open the configuration window.
2. **AI Provider:** Select your preferred AI engine from the dropdown (Google Gemini, OpenAI, DeepSeek, Anthropic, OpenRouter, or Local). The UI will dynamically update to show the settings for that specific provider. OpenRouter will populate its model list without an API key.
3. **API Key / Local URL:** Paste your API key for the selected cloud provider. If using a local model, ensure your Local Base URL is correct (e.g., `http://localhost:11434` for Ollama).
4. **Model Name:** Click **Fetch Available Models** to populate the dropdown menu directly from your chosen provider, then select the specific model you wish to use.
5. **System Prompt (Advanced):** You can safely tweak the AI's core instructions here. Every provider remembers its own prompt.
6. Click **Apply** or **OK** to save.

## Usage
Once configured, the plugin integrates seamlessly into your standard Calibre workflow.

1. **Select Publications:** Highlight one or more entries in your calibre library. A cover is not required.
2. **Trigger the Plugin:** Click the 漫元 MetaManga button in your main toolbar, or right-click the highlighted books and select it from the context menu. The click behavior follows the “点击插件时直接应用AI元数据” setting.
3. **Wait for Processing:** The plugin sends filename/title text only and runs in a background thread.
4. **Automatic Updates:** Each valid result is written before the next request starts. Missing books, unsupported titles, AI errors, library changes, and metadata conflicts do not trigger confirmation dialogs. The status bar shows progress and the final counts; **Last Run Results** provides details.
5. **Optional Manual Review:** Select **Analyze Selected Books (Review Each)** to edit each result. The dialog shows the original filename plus filename-derived title, author, series/volume, language, and Comments. Tags, publisher, publication date, and identifiers are available for manual input, initially empty and unchecked. Enter a value and check its box to write it; use YYYY-MM-DD for publication dates and comma-separated type:value pairs for identifiers. Leaving these fields unchecked or blank preserves existing metadata.
6. **Manual Apply & Auto-Advance:** In review mode, click **OK** to save the checked metadata directly to Calibre. If you selected multiple books, the plugin will seamlessly analyze the next book in your queue and begin processing it immediately.

## Provider Setup Guide

To use the cloud features of this plugin, you will need to generate an API key from your preferred provider. Treat these keys like passwords. 

**Google Gemini (Recommended for Free Tier)**
* Navigate to [Google AI Studio](https://aistudio.google.com/app/apikey) to generate a free API key.
* Gemini receives filename/title text only; Google Search tools are not enabled.

**OpenAI (ChatGPT)**
* Navigate to the [OpenAI Platform](https://platform.openai.com/api-keys) to generate a key.
* *Requirements:* OpenAI no longer offers free API grants. You must add prepaid credits (minimum $5) to your developer dashboard for the API to process requests.

**DeepSeek**
* Navigate to [DeepSeek API Keys](https://platform.deepseek.com/api_keys) to create an API key.
* Use `deepseek-flash` as the default model, or fetch the available models from the plugin settings.
* All DeepSeek requests contain filename/title text only. No model receives a cover image.

**Anthropic (Claude)**
* Navigate to the [Anthropic Console](https://console.anthropic.com/settings/keys) to generate a key.
* *Requirements:* Like OpenAI, Anthropic requires you to load prepaid credits to your account before API requests will be authorized (otherwise you will receive an immediate HTTP 400 error).

**OpenRouter**
* Navigate to the [OpenRouter Workspace](https://openrouter.ai/settings/keys) to generate a key.
* *Requirements:* OpenRouter provides access to a large variety of models from over sixty providers. OpenRouter requires you to load prepaid credits to your account before executing API requests. The model list can be refreshed from the configuration window. The model list is available even without an API key.

**Local Models (Ollama / LM Studio)**
* You can run a local model on your own hardware; requests contain text only.
* Download [Ollama](https://ollama.com/) or [LM Studio](https://lmstudio.ai/). Make sure your local server is running, verify the Base URL in the plugin settings, and fetch the models you have downloaded.

## Development checks

Run `python -m unittest discover -s tests -v` for the parser, result schema, and writer checks.
With calibre installed, run `powershell -ExecutionPolicy Bypass -File .\tests\run_calibre_smoke.ps1` for real Qt review dialogs, all six providers with mocked HTTP, and disposable calibre API library writes. The runner isolates calibre settings and removes only its own temporary test directory. It does not open the user's library or call a live provider.

Build the installable archive with `powershell -ExecutionPolicy Bypass -File .\build_plugin.ps1`.
