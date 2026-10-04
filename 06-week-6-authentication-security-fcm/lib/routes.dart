// Mendefinisikan konstanta rute (Refactoring 1)
class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String announcement = '/pengumuman/:id';
}

// Ekstrak fungsi murni untuk testing (Refactoring 2)
String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route']?.toString() ?? '/';
  // Memastikan rute selalu diawali dengan '/'
  return route.startsWith('/') ? route : '/$route';
}