# NoteMind AI - Tutor Belajar

**NoteMind AI** adalah asisten belajar berbasis AI untuk mahasiswa yang membantu merangkum materi, membuat kuis, dan membimbing pemahaman konsep secara interaktif.

## Fitur Utama

### 1. Ringkas Cepat
- Ringkasan padat maksimal 4 poin utama
- Format poin terstruktur
- Bahasa Indonesia baku

### 2. Pembuat Kuis
- 3 pertanyaan evaluasi konsep
- Kunci jawaban tersembunyi (collapsible)
- Format bernomor rapi

### 3. Tutor Sokratik
- Bimbingan berpikir kritis
- Pertanyaan reflektif penuntun
- Tidak langsung memberi jawaban lengkap

## Instalasi

### Prasyarat
- Flutter SDK ≥ 3.13.5
- Dart SDK ≥ 3.13.5

### Langkah Instalasi

1. Clone repository ini:
```bash
git clone <repository-url>
cd 10-week-10-ai-feature-integration/week10_ai_assistant
```

2. Install dependencies:
```bash
flutter pub get
```

3. Dapatkan API Key dari [Google Gemini](https://aistudio.google.com)

4. Jalankan aplikasi:
```bash
flutter run
```

## Struktur Folder

```
lib/
├── core/
│   ├── errors/
│   │   └── ai_exceptions.dart      # Custom exceptions
│   └── security/
│       └── secure_storage_service.dart  # Secure storage abstraction
├── features/
│   └── study_ai/
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── chat_message.dart     # Domain model
│       │   │   └── study_persona.dart    # Study personas enum
│       ├── data/
│       │   └── repositories/
│       │       └── gemini_repository.dart  # API integration
│       └── presentation/
│           ├── pages/
│           │   └── study_ai_page.dart    # Main UI
│           └── providers/
│               └── chat_provider.dart    # State management
└── main.dart
```

## Teknologi yang Digunakan

- **Flutter** - Framework UI
- **Riverpod** - State management (NotifierProvider pattern)
- **Google Gemini API** - LLM untuk AI response
- **flutter_secure_storage** - Secure API key storage
- **http** - HTTP client untuk API calls

## Keamanan

- API key disimpan secara lokal di device (tidak di server)
- API key tidak pernah di-hardcode di source code
- Secure storage menggunakan OS-level encryption

## Privacy

- Chat history disimpan di device (offline)
- Data tidak dikirim ke server eksternal
- API key hanya digunakan untuk Gemini API call

## Penggunaan

1. Buka aplikasi
2. Klik icon settings (⚙️) di AppBar
3. Masukkan Google Gemini API key
4. Pilih study persona (Ringkas Cepat / Pembuat Kuis / Tutor Sokratik)
5. Ketik pertanyaan dan kirim

## Error Handling

- **ApiKeyMissingException** - Prompt user untuk set API key
- **GeminiException** - API response error (with status code)
- **NetworkAiException** - Network connectivity issues

## Testing

```bash
flutter test
```

Test coverage:
- StudyPersona domain logic
- ChatMessage entity operations
- Custom exception messages

## Referensi

- [Google Gemini API Docs](https://ai.google.dev/gemini-api/docs)
- [Flutter Riverpod](https://riverpod.dev/)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

---

**Developer**: Muhammad Nawfal Mawla Azhar (244107020174)  
**Kelas**: TI-3G  
**Mata Kuliah**: Pemrograman Mobile
