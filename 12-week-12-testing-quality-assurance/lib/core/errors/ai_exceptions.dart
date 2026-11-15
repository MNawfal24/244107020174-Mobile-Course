class GeminiException implements Exception {
  const GeminiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'GeminiException: $message (code: $statusCode)';
}

class ApiKeyMissingException implements Exception {
  const ApiKeyMissingException();

  @override
  String toString() => 'API Key Gemini belum disetel. Buka pengaturan untuk menyetel key.';
}

class NetworkAiException implements Exception {
  const NetworkAiException(this.message);
  final String message;

  @override
  String toString() => 'NetworkAiException: Gagal terhubung ke Gemini API ($message)';
}
