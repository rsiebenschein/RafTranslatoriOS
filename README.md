# RafTranslator (iOS)

A native SwiftUI/SwiftData iOS port of [SwissGermanTranscriber](https://github.com/rsiebenschein/SwissGermanTranscriber) ("Raf's Babel Translator"), an Android app that translates typed or dictated text into an authentic target language or dialect using the Gemini API.

This is **Phase 1** of the port: the core translator app (language catalog, translate, dictate, settings, usage tracking). The Android app's signature feature — a floating bubble that translates in place inside WhatsApp via an `AccessibilityService` — has **no public iOS equivalent** (no cross-app UI introspection, no global overlay window, no writing into another app's text field from the background) and is deliberately out of scope here. The closest iOS analogue would be a custom keyboard extension (`UIInputViewController`), manually switched to inside the target app; that's a separate, later design effort.

## How this differs from the Android app

| Area | Android | iOS |
| --- | --- | --- |
| UI framework | Jetpack Compose | SwiftUI |
| Local persistence | Room | SwiftData |
| Settings storage | SharedPreferences (plaintext, including the API key) | `UserDefaults` for settings; **API key in the Keychain** — a deliberate security improvement over the Android app's known limitation |
| Dictation | Android `RecognizerIntent` (system dictation activity) | Apple `Speech` framework (`SFSpeechRecognizer`), in-app record button + live transcript, since iOS has no equivalent fire-and-forget system dictation intent |
| WhatsApp floating-bubble / accessibility-service translation | ✅ core feature | ❌ out of scope for this phase (no iOS API supports it) |
| Text-selection "Translate" system menu | ✅ (`TranslateSelectionActivity`) | ❌ deferred |
| Localized in-app strings/toasts per target language | ✅ | ❌ English-only UI for v1 |

Everything else — the Gemini REST client (auth, retry/backoff on 429/500/503, safety settings, per-model-generation thinking config, output token capping, model list filtering), the cost/usage tracking math, and the language/dialect catalog structure — is a close logic port of the Android app, adapted to Swift idioms.

## What the app does

Type or dictate a sentence, pick a target language/dialect, tap translate, and copy the result. The target language catalog covers regional and dialect variants (originally built around the 21 Swiss-German-speaking cantons) alongside a broad set of world languages.

Settings lets you:
- Enter and store your Gemini API key (Keychain-backed)
- Pick a Gemini model (pulls the currently active Flash models from the API)
- Choose/add/edit/delete target languages and dialects
- Edit the instructions template (system prompt) sent to Gemini
- View a running token-usage and estimated-cost summary, with a reset action

## Project layout

| Path | What lives there |
| --- | --- |
| `RafTranslator/Data/Models/` | SwiftData `@Model` entities: `LanguageDialect`, `GeminiModelRate`, `TranslationUsageRecord` |
| `RafTranslator/Data/Networking/` | `GeminiService` REST client, retry/backoff, model filtering, thinking config |
| `RafTranslator/Data/Persistence/` | Catalog seeding (`DialectSeeder`, `CatalogSeeding`), Swiss canton registry, language groups, usage repository, cost calculator |
| `RafTranslator/Dictation/` | `Speech`-framework-based dictation service |
| `RafTranslator/Settings/` | `AppSettings`, Keychain wrapper, language-editing draft model |
| `RafTranslator/UI/` | Main translate screen and its component cards |
| `RafTranslator/UI/Settings/` | Settings screen sections: API key, model picker, target language, instructions, usage summary, language add/edit |

## Building

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`project.yml`) rather than a checked-in, hand-edited `.xcodeproj`. After cloning:

```sh
brew install xcodegen   # if not already installed
xcodegen generate
open RafTranslator.xcodeproj
```

Requires iOS 17+ (SwiftData). Build and run on a simulator or device from Xcode; enter a Gemini API key in Settings before translating.

## Reference

The original Android app, its language-catalog design notes, and its own TODO/audit history live at `SwissGermanTranscriber` — useful for logic parity questions, but its Android-specific bugs, WhatsApp-integration issues, and build/signing TODOs do **not** apply to this port.
