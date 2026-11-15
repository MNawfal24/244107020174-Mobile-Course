# Risk Mitigation Table - NoteMind AI

| Risk | Description | Mitigation Strategy | Status |
|------|-------------|---------------------|--------|
| **API Key Exposure** | API key bisa diakses oleh pihak tidak berwenang | - Gunakan flutter_secure_storage dengan OS-level encryption<br>- Tidak menyimpan key di source code<br>- Tidak menampilkan key di UI setelah disimpan | ✅ Implemented |
| **API Rate Limiting** | Quota Gemini API habis karena penggunaan berlebihan | - Tampilkan error message jelas saat quota exceeded<br>- Gunakan model hemat (gemini-2.0-flash-lite)<br>- Disable input saat request pending | ✅ Implemented |
| **Network Failure** | Koneksi internet tidak stabil saat API call | - Try-catch dengan NetworkAiException<br>- User-friendly error message<br>- Loading state indicator | ✅ Implemented |
| **Invalid API Key** | User memasukkan key yang salah atau expired | - Validasi format key minimal<br>- Tampilkan error dari API response<br>- Opsi untuk update key | ✅ Implemented |
| **Chat History Loss** | Data chat hilang saat app di-close | - Saat ini chat tidak dipersist (disclaimer di README)<br>- Future: implementasi SQLite untuk persistence | ⚠️ Partial |
| **Malicious Input** | User memasukkan prompt berbahaya | - System prompt membatasi scope respons<br>- AI model memiliki built-in safety filters<br>- Input tidak di-execute sebagai code | ✅ Implemented |
| **Data Privacy** | Chat data diakses pihak ketiga | - Tidak ada tracking/analytics<br>- Semua data lokal di device<br>- Tidak ada account/login requirement | ✅ Implemented |
| **Dependency Vulnerability** | Package pihak ketiga memiliki security hole | - Gunakan package populer dengan maintenance aktif<br>- Flutter pub outdated secara berkala<br>- flutter_secure_storage dari trusted publisher | ✅ Implemented |
| **UI Unresponsiveness** | App freeze saat menunggu AI response | - Async/await pattern<br>- Loading indicator<br>- Error handling dengan try-catch | ✅ Implemented |
| **BuildContext Errors** | Using context after async gap | - Capture context reference sebelum async<br>- Use mounted check (StatefulWidget)<br>- Avoid context in async callbacks | ✅ Implemented |

## Privacy Compliance

### Data Collection
- ❌ No personal data collection
- ❌ No analytics or tracking
- ❌ No account registration
- ✅ User-provided API key only

### Data Storage
- ✅ API key stored in secure storage (encrypted)
- ✅ Chat history in memory only (not persisted)
- ❌ No data sent to external servers (except Gemini API)

### User Rights
- ✅ Delete API key anytime via UI
- ✅ Clear chat history via delete button
- ✅ No lock-in or account required

## Error Handling Matrix

| Error Type | User Message | Recovery Action |
|------------|--------------|-----------------|
| `ApiKeyMissingException` | "API Key Gemini belum disetel" | Redirect to API key setup |
| `GeminiException (401)` | "API key tidak valid" | Prompt to check/update key |
| `GeminiException (429)` | "Quota API habis" | Suggest waiting or upgrading plan |
| `GeminiException (500)` | "Server Gemini sedang bermasalah" | Suggest retry later |
| `NetworkAiException` | "Gagal terhubung ke Gemini API" | Check internet connection |
| `Unknown Exception` | "Terjadi kesalahan: [error]" | Generic error with details |

---

**Document Version**: 1.0  
**Last Updated**: November 2024  
**Author**: Muhammad Nawfal Mawla Azhar (244107020174)
