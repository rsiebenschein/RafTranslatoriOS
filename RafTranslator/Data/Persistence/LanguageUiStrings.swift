import Foundation

/// Per-language copy for the generic (non-Swiss-German) main screen, keyed by the
/// same stable seedKey used on `LanguageDialect`. This is hand-authored, read-only
/// reference data (not user-editable), so unlike the Android Room table it is kept
/// as a plain static catalog rather than a persisted SwiftData model.
struct LanguageUiStrings {
    let seedKey: String
    let greeting: String
    let translateIntoLabel: String
    let placeholder: String
    let buttonLabel: String

    static let englishDefault = LanguageUiStrings(
        seedKey: "",
        greeting: "We translate it all!",
        translateIntoLabel: "Translate into",
        placeholder: "Type or dictate a sentence in English to translate here...",
        buttonLabel: "Let's go — Translate!"
    )
}

/// Hand-authored generic-main-screen copy for the ~19 most-used non-Swiss,
/// non-English seed keys from `DialectSeeder`. Everything outside this list
/// falls back to `LanguageUiStrings.englishDefault`.
enum LanguageUiStringsCatalog {
    static let all: [LanguageUiStrings] = [
        LanguageUiStrings(seedKey: "de-standard", greeting: "Hallo zusammen!", translateIntoLabel: "Übersetzen ins", placeholder: "Tippe oder diktiere hier einen Satz auf Englisch zum Übersetzen...", buttonLabel: "Los geht's — Übersetzen!"),
        LanguageUiStrings(seedKey: "fr-standard", greeting: "Bonjour à tous !", translateIntoLabel: "Traduire en", placeholder: "Tapez ou dictez ici une phrase en anglais à traduire...", buttonLabel: "C'est parti — Traduire !"),
        LanguageUiStrings(seedKey: "it-standard", greeting: "Ciao a tutti!", translateIntoLabel: "Traduci in", placeholder: "Digita o detta qui una frase in inglese da tradurre...", buttonLabel: "Si parte — Traduci!"),
        LanguageUiStrings(seedKey: "es-standard", greeting: "¡Hola a todos!", translateIntoLabel: "Traducir al", placeholder: "Escribe o dicta aquí una frase en inglés para traducir...", buttonLabel: "¡Vamos — Traducir!"),
        LanguageUiStrings(seedKey: "pt-portuguese", greeting: "Olá a todos!", translateIntoLabel: "Traduzir para", placeholder: "Digite ou dite aqui uma frase em inglês para traduzir...", buttonLabel: "Vamos lá — Traduzir!"),
        LanguageUiStrings(seedKey: "br-portuguese", greeting: "Olá, pessoal!", translateIntoLabel: "Traduzir para", placeholder: "Digite ou dite aqui uma frase em inglês para traduzir...", buttonLabel: "Vamos lá — Traduzir!"),
        LanguageUiStrings(seedKey: "cn-mandarin", greeting: "大家好！", translateIntoLabel: "翻译成", placeholder: "在此输入或口述一句英文句子进行翻译...", buttonLabel: "开始翻译！"),
        LanguageUiStrings(seedKey: "hk-cantonese", greeting: "大家好！", translateIntoLabel: "翻譯成", placeholder: "喺呢度打字或口述一句英文句子嚟翻譯...", buttonLabel: "開始翻譯！"),
        LanguageUiStrings(seedKey: "in-hindi", greeting: "नमस्ते दोस्तों!", translateIntoLabel: "अनुवाद करें", placeholder: "अनुवाद के लिए यहाँ अंग्रेज़ी में एक वाक्य टाइप करें या बोलें...", buttonLabel: "चलिए शुरू करें — अनुवाद करें!"),
        LanguageUiStrings(seedKey: "ar-msa", greeting: "!مرحباً بالجميع", translateIntoLabel: "ترجمة إلى", placeholder: "...اكتب أو أملِ هنا جملة بالإنجليزية لترجمتها", buttonLabel: "!هيا بنا — ترجمة"),
        LanguageUiStrings(seedKey: "jp-japanese", greeting: "こんにちは、皆さん！", translateIntoLabel: "翻訳先", placeholder: "ここに翻訳したい英語の文を入力または音声入力してください...", buttonLabel: "さあ、翻訳しよう！"),
        LanguageUiStrings(seedKey: "kp-korean", greeting: "안녕하세요, 여러분!", translateIntoLabel: "번역할 언어", placeholder: "번역할 영어 문장을 여기에 입력하거나 말해보세요...", buttonLabel: "시작하기 — 번역!"),
        LanguageUiStrings(seedKey: "ru-russian", greeting: "Всем привет!", translateIntoLabel: "Перевести на", placeholder: "Введите или продиктуйте здесь предложение на английском для перевода...", buttonLabel: "Поехали — Перевести!"),
        LanguageUiStrings(seedKey: "tr-turkish", greeting: "Herkese merhaba!", translateIntoLabel: "Şu dile çevir", placeholder: "Çevrilecek İngilizce cümleyi buraya yazın veya söyleyin...", buttonLabel: "Hadi başlayalım — Çevir!"),
        LanguageUiStrings(seedKey: "nl-dutch", greeting: "Hallo allemaal!", translateIntoLabel: "Vertalen naar", placeholder: "Typ of dicteer hier een Engelse zin om te vertalen...", buttonLabel: "Daar gaan we — Vertalen!"),
        LanguageUiStrings(seedKey: "gr-standard", greeting: "Γεια σας όλους!", translateIntoLabel: "Μετάφραση στα", placeholder: "Πληκτρολογήστε ή υπαγορεύστε εδώ μια αγγλική πρόταση για μετάφραση...", buttonLabel: "Πάμε — Μετάφραση!"),
        LanguageUiStrings(seedKey: "id-indonesian", greeting: "Halo semuanya!", translateIntoLabel: "Terjemahkan ke", placeholder: "Ketik atau dikte kalimat bahasa Inggris di sini untuk diterjemahkan...", buttonLabel: "Ayo mulai — Terjemahkan!"),
        LanguageUiStrings(seedKey: "th-thai", greeting: "สวัสดีทุกคน!", translateIntoLabel: "แปลเป็น", placeholder: "พิมพ์หรือพูดประโยคภาษาอังกฤษที่นี่เพื่อแปล...", buttonLabel: "เริ่มกันเลย — แปล!"),
        LanguageUiStrings(seedKey: "vn-vietnamese", greeting: "Xin chào tất cả mọi người!", translateIntoLabel: "Dịch sang", placeholder: "Gõ hoặc đọc một câu tiếng Anh ở đây để dịch...", buttonLabel: "Bắt đầu nào — Dịch!"),
        LanguageUiStrings(seedKey: "ir-persian", greeting: "!سلام به همه", translateIntoLabel: "ترجمه به", placeholder: "...یک جمله انگلیسی برای ترجمه اینجا تایپ یا دیکته کنید", buttonLabel: "!بزن بریم — ترجمه"),
        LanguageUiStrings(seedKey: "il-hebrew", greeting: "!שלום לכולם", translateIntoLabel: "תרגם ל", placeholder: "...הקלד או הכתב כאן משפט באנגלית לתרגום", buttonLabel: "!קדימה — תרגם"),
    ]

    private static let byKey = Dictionary(uniqueKeysWithValues: all.map { ($0.seedKey, $0) })

    static func strings(forSeedKey seedKey: String?) -> LanguageUiStrings {
        guard let seedKey, let match = byKey[seedKey] else { return .englishDefault }
        return match
    }
}
