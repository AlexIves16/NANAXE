import 'dart:convert';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../models/calendar_event_model.dart';

class GoogleCalendarService {
  static const List<String> _scopes = [
    gcal.CalendarApi.calendarEventsScope,
    gcal.CalendarApi.calendarReadonlyScope,
  ];

  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  gcal.CalendarApi? _calendarApi;

  // Авторизация через OAuth2
  Future<void> authorize(String clientId, String clientSecret, String refreshToken) async {
    _refreshToken = refreshToken;

    final credentials = ServiceAccountCredentials(
      jsonDecode(jsonEncode({
        'client_id': clientId,
        'client_secret': clientSecret,
        'refresh_token': refreshToken,
        'type': 'authorized_user',
      })),
    );

    final client = await clientViaServiceAccount(credentials, _scopes);
    _calendarApi = gcal.CalendarApi(client);
  }

  // Получение списка событий
  Future<List<CalendarEventModel>> getEvents({
    required DateTime timeMin,
    required DateTime timeMax,
    String calendarId = 'primary',
  }) async {
    if (_calendarApi == null) {
      throw Exception('Not authorized');
    }

    try {
      final events = await _calendarApi!.events.list(
        calendarId,
        timeMin: timeMin.toUtc(),
        timeMax: timeMax.toUtc(),
        orderBy: 'startTime',
        singleEvents: true,
      );

      return events.items?.map((event) => _convertToEventModel(event)).toList() ?? [];
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  // Создание события
  Future<CalendarEventModel> createEvent({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
    String? location,
    List<String>? attendeeEmails,
    String calendarId = 'primary',
  }) async {
    if (_calendarApi == null) {
      throw Exception('Not authorized');
    }

    final event = gcal.Event((e) {
      e.summary = title;
      e.description = description;
      e.location = location;
      e.start = gcal.EventDateTime((dt) {
        dt.dateTime = startTime.toUtc();
      });
      e.end = gcal.EventDateTime((dt) {
        dt.dateTime = endTime.toUtc();
      });

      if (attendeeEmails != null && attendeeEmails.isNotEmpty) {
        e.attendees = attendeeEmails
            .map((email) => gcal.EventAttendee((a) => a.email = email))
            .toList();
      }
    });

    final createdEvent = await _calendarApi!.events.insert(event, calendarId);
    return _convertToEventModel(createdEvent);
  }

  // Обновление события
  Future<CalendarEventModel> updateEvent(
    String eventId, {
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    String? location,
    String calendarId = 'primary',
  }) async {
    if (_calendarApi == null) {
      throw Exception('Not authorized');
    }

    // Сначала получаем текущее событие
    final existingEvent = await _calendarApi!.events.get(calendarId, eventId);

    final updatedEvent = gcal.Event((e) {
      e.summary = title ?? existingEvent.summary;
      e.description = description ?? existingEvent.description;
      e.location = location ?? existingEvent.location;
      
      if (startTime != null) {
        e.start = gcal.EventDateTime((dt) {
          dt.dateTime = startTime.toUtc();
        });
      } else {
        e.start = existingEvent.start;
      }
      
      if (endTime != null) {
        e.end = gcal.EventDateTime((dt) {
          dt.dateTime = endTime.toUtc();
        });
      } else {
        e.end = existingEvent.end;
      }
    });

    final result = await _calendarApi!.events.update(updatedEvent, calendarId, eventId);
    return _convertToEventModel(result);
  }

  // Удаление события
  Future<void> deleteEvent(String eventId, String calendarId = 'primary') async {
    if (_calendarApi == null) {
      throw Exception('Not authorized');
    }

    await _calendarApi!.events.delete(calendarId, eventId);
  }

  // Конвертация Google Event в нашу модель
  CalendarEventModel _convertToEventModel(gcal.Event event) {
    final startTime = event.start?.dateTime ?? event.start?.date ?? DateTime.now();
    final endTime = event.end?.dateTime ?? event.end?.date ?? DateTime.now();

    return CalendarEventModel(
      id: event.id ?? '',
      title: event.summary ?? 'Без названия',
      description: event.description,
      location: event.location ?? '',
      startTime: startTime.toLocal(),
      endTime: endTime.toLocal(),
      isAllDay: event.start?.date != null,
      googleEventId: event.id,
      attendeeEmails: event.attendees?.map((a) => a.email ?? '').toList() ?? [],
      color: _getColorFromEvent(event),
      status: event.status ?? 'confirmed',
      createdBy: event.creator?.email ?? '',
      createdAt: event.created ?? DateTime.now(),
      updatedAt: event.updated ?? DateTime.now(),
    );
  }

  String _getColorFromEvent(gcal.Event event) {
    // Google Calendar использует colorId для цветов
    switch (event.colorId) {
      case '1': return '#a4bdfc'; // lavender
      case '2': return '#7ae7bf'; // sage
      case '3': return '#dbadff'; // grape
      case '4': return '#ff887c'; // flamo
      case '5': return '#fbd75b'; // banana
      case '6': return '#ffef8f'; // tangerine
      case '7': return '#dc2127'; // tomato
      case '8': return '#b9e4e0'; // peacock
      case '9': return '#e1e1e1'; // graphite
      case '10': return '#5484ed'; // blueberry
      case '11': return '#51b749'; // basil
      default: return '#2196F3'; // default blue
    }
  }

  // Получение URL для OAuth авторизации
  static String getAuthUrl(String clientId, String redirectUri) {
    final scopesEncoded = _scopes.join('%20');
    return 'https://accounts.google.com/o/oauth2/auth'
        '?client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&scope=$scopesEncoded'
        '&response_type=code'
        '&access_type=offline'
        '&prompt=consent';
  }

  // Обмен кода на токен
  Future<Map<String, dynamic>> exchangeCodeForToken({
    required String code,
    required String clientId,
    required String clientSecret,
    required String redirectUri,
  }) async {
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      body: {
        'code': code,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'accessToken': data['access_token'],
        'refreshToken': data['refresh_token'],
        'expiry': DateTime.now().add(Duration(seconds: data['expires_in'])),
      };
    } else {
      throw Exception('Failed to exchange code: ${response.body}');
    }
  }

  // Проверка авторизации
  bool get isAuthorized => _calendarApi != null;

  // Выход
  void logout() {
    _calendarApi = null;
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
  }
}

final googleCalendarService = GoogleCalendarService();
