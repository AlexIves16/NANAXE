// Заглушка для Google Calendar Service
// Полная реализация будет позже через OAuth2 flow

class GoogleCalendarService {
  bool _isAuthorized = false;

  // Проверка авторизации
  bool get isAuthorized => _isAuthorized;

  // Выход
  void logout() {
    _isAuthorized = false;
  }
}

final googleCalendarService = GoogleCalendarService();
