# NANAHUI CRM - CRM-ассистент для команд

CRM-система с AI-планированием, mind-картами задач и интеграцией с Google Calendar.

## 🚀 Возможности

### Для команд и фрилансеров:
- ✅ **Управление задачами** - создание, назначение, приоритеты, статусы
- ✅ **Mind-карты проектов** - визуальное дерево задач (drag-drop для админов)
- ✅ **Календарь** - синхронизация с Google Calendar
- ✅ **Будильники/Напоминания** - локальные уведомления
- ✅ **AI-ассистент** - умное планирование и генерация подзадач
- ✅ **Ролевая модель** - admin, member, viewer
- ✅ **Офлайн-режим** - кэширование данных на устройстве

## 📦 Технологический стек

| Компонент | Технология |
|-----------|------------|
| Framework | Flutter |
| State Management | Riverpod |
| Backend | Firebase (Firestore, Auth, FCM) |
| Local Storage | Hive |
| Navigation | GoRouter |
| Mind Maps | flutter_mind_map, graphview |
| AI | OpenAI API, Anthropic API (планируется) |

## 🏗 Структура проекта

```
lib/
├── core/
│   ├── firebase_config.dart
│   ├── local_storage_service.dart
│   ├── router.dart
│   └── theme.dart
├── features/
│   ├── tasks/
│   ├── mindmap/
│   ├── calendar/
│   └── alarms/
├── models/
│   ├── user_model.dart
│   ├── task_model.dart
│   ├── project_model.dart
│   ├── mind_map_model.dart
│   ├── calendar_event_model.dart
│   └── alarm_model.dart
├── providers/
│   └── auth_provider.dart
├── screens/
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   ├── tasks_screen.dart
│   ├── mind_map_screen.dart
│   ├── calendar_screen.dart
│   └── alarms_screen.dart
└── widgets/
```

## 🔧 Настройка

### 1. Firebase Console

1. Создайте проект в [Firebase Console](https://console.firebase.google.com)
2. Включите Authentication (Google Sign-In)
3. Создайте Firestore базу данных
4. Скачайте конфиги:
   - `google-services.json` для Android
   - `GoogleService-Info.plist` для iOS

### 2. Установка зависимостей

```bash
flutter pub get
```

### 3. Запуск

```bash
flutter run
```

## 📱 Роли пользователей

| Роль | Права |
|------|-------|
| **Admin** | Создание/редактирование mind-карт, управление командой, все CRUD операции |
| **Member** | Создание задач, редактирование своих задач, просмотр общих |
| **Viewer** | Только просмотр |

## 🗄 Структура Firestore

```
users/{userId}
  - email, displayName, photoUrl
  - role: admin|member|viewer
  - teamIds: []
  - settings: {}

teams/{teamId}
  - name, description
  - memberIds: []
  - projects: subcollection

projects/{projectId}
  - name, description, color
  - ownerId, memberIds
  - startDate, endDate

tasks/{taskId}
  - title, description
  - projectId, parentTaskId
  - status, priority
  - assigneeId, creatorId
  - dueDate, estimatedHours
  - aiMetadata: {}

mindmaps/{mindMapId}
  - projectId, title
  - rootNodeId
  - nodes: subcollection

events/{eventId}
  - title, description
  - startTime, endTime
  - googleEventId
  - attendeeIds: []

alarms/{alarmId}
  - title, dateTime
  - taskId, eventId
  - isRepeating, repeatPattern
```

## 🤖 AI Функции (планируется)

- **Генерация подзадач** - разбивка больших задач на подзадачи
- **Приоритизация** - AI анализ важности задач
- **Планирование** - оптимальное распределение задач по времени
- **Саммари** - краткое описание проекта/задач
- **Анализ тональности** - анализ переписки с клиентами

## 📝 Следующие шаги

- [ ] Настроить Firebase проект
- [ ] Добавить реальную интеграцию с Firestore
- [ ] Реализовать AI сервисы (OpenAI, Anthropic)
- [ ] Добавить Google Calendar API
- [ ] Реализовать mind-map виджет с drag-drop
- [ ] Добавить локальные уведомления
- [ ] Реализовать синхронизацию офлайн-данных

## 📄 Лицензия

Internal use only (для команды NANAHUI)
