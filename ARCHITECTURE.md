# 🏗 Архитектура NANAHUI CRM

## Общая схема

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter Application                       │
├─────────────────────────────────────────────────────────────────┤
│  Presentation Layer (UI)                                         │
│  ┌─────────────┬─────────────┬─────────────┬─────────────┐     │
│  │   Screens   │   Widgets   │   Themes    │  Navigation │     │
│  │             │             │             │  (GoRouter) │     │
│  └─────────────┴─────────────┴─────────────┴─────────────┘     │
├─────────────────────────────────────────────────────────────────┤
│  State Management Layer (Riverpod)                               │
│  ┌─────────────┬─────────────┬─────────────┬─────────────┐     │
│  │   Providers │  Notifiers  │   Streams   │    State    │     │
│  └─────────────┴─────────────┴─────────────┴─────────────┘     │
├─────────────────────────────────────────────────────────────────┤
│  Domain Layer (Business Logic)                                   │
│  ┌─────────────┬─────────────┬─────────────┬─────────────┐     │
│  │    Models   │  Repositories │  Services  │   Use Cases │     │
│  └─────────────┴─────────────┴─────────────┴─────────────┘     │
├─────────────────────────────────────────────────────────────────┤
│  Data Layer                                                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Local Storage (Hive)                        │   │
│  │  ┌──────────┬──────────┬──────────┬──────────┐          │   │
│  │  │  Tasks   │  Alarms  │ MindMaps │  Events  │          │   │
│  │  └──────────┴──────────┴──────────┴──────────┘          │   │
│  └─────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           Remote Storage (Firebase Firestore)            │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  Firebase Auth  │ │  AI Services    │ │ Google Calendar │
│  (Google Sign-  │ │  (OpenAI,       │ │      API        │
│   In, Email)    │ │   Anthropic)    │ │                 │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

## Поток данных

### 1. Аутентификация
```
User → AuthScreen → AuthNotifier (Riverpod) → Firebase Auth
                                           ↓
                                      UserModel → Firestore
                                           ↓
                                      HomeScreen
```

### 2. Управление задачами
```
User → TasksScreen → TaskNotifier → FirestoreService → Firestore
                                      ↓
                              LocalStorageService (Hive)
                                      ↓
                                 Offline Cache
```

### 3. AI генерация
```
User → TaskScreen → AIService → OpenAI API
                                   ↓
                            Generate Subtasks
                                   ↓
                              TaskModel → Firestore
```

### 4. Mind-карта
```
User → MindMapScreen → MindMapNotifier → FirestoreService
                                              ↓
                                    MindMap Nodes (Tree)
                                              ↓
                                    GraphView Widget (Render)
```

### 5. Синхронизация
```
┌──────────────┐    Compare    ┌──────────────┐
│  Local Hive  │ ←───────────→ │   Firestore  │
│   (Offline)  │               │   (Remote)   │
└──────────────┘               └──────────────┘
       ↓                              ↓
  Merge Conflicts              Real-time Sync
       ↓                              ↓
  Local Priority               Remote Priority
       └──────────────┬──────────────┘
                      ↓
              Merged Data → UI
```

## Модульная структура

### Core Module
```
core/
├── firebase_config.dart    # Инициализация Firebase
├── firestore_service.dart  # CRUD операции Firestore
├── local_storage_service.dart  # Hive кэш
├── ai_service.dart         # AI интеграции
├── router.dart             # GoRouter маршруты
└── theme.dart              # Material темы
```

### Features Modules
```
features/
├── auth/
│   ├── auth_screen.dart
│   ├── auth_provider.dart
│   └── auth_service.dart
├── tasks/
│   ├── task_list_screen.dart
│   ├── task_detail_screen.dart
│   ├── task_provider.dart
│   └── task_service.dart
├── mindmap/
│   ├── mindmap_screen.dart
│   ├── mindmap_widget.dart
│   ├── mindmap_provider.dart
│   └── mindmap_service.dart
├── calendar/
│   ├── calendar_screen.dart
│   ├── event_provider.dart
│   └── google_calendar_service.dart
└── alarms/
    ├── alarms_screen.dart
    ├── alarm_provider.dart
    └── notification_service.dart
```

## Ролевая модель

```
┌────────────────────────────────────────────┐
│                 User Roles                 │
├──────────────┬──────────────┬──────────────┤
│    Admin     │    Member    │   Viewer     │
├──────────────┼──────────────┼──────────────┤
│ ✓ Все права  │ ✓ Создание   │ ✓ Просмотр   │
│ ✓ Редактиро- │   задач      │   задач      │
│   вание mind-│ ✓ Редактиро- │ ✓ Просмотр   │
│   карт       │   вание      │   mind-карт  │
│ ✓ Управление │   своих задач│ ✗ Редактиро- │
│   командой   │ ✓ Просмотр   │   вание      │
│ ✓ Удаление   │   общих задач│ ✗ Удаление   │
│   любых задач│ ✗ Редактиро- │              │
│              │   вание mind-│              │
│              │   карт       │              │
└──────────────┴──────────────┴──────────────┘
```

## Модель данных

### Task Model
```dart
TaskModel {
  String id;
  String title;
  String? description;
  String projectId;
  String? parentTaskId;  // Для иерархии
  TaskStatus status;     // todo, inProgress, review, done
  TaskPriority priority; // low, medium, high, urgent
  String? assigneeId;
  String? creatorId;
  List<String> tags;
  DateTime? dueDate;
  int estimatedHours;
  Map<String, dynamic> aiMetadata;  // AI данные
  DateTime createdAt;
  DateTime updatedAt;
}
```

### MindMapNode Model
```dart
MindMapNode {
  String id;
  String projectId;
  String? parentId;      // Для дерева
  int level;             // Уровень вложенности
  String title;
  String? taskId;        // Связь с задачей
  String color;
  double x, y;           // Координаты
  DateTime createdAt;
  DateTime updatedAt;
}
```

## Синхронизация

### Стратегия
1. **Offline-first**: Все данные сначала сохраняются локально
2. **Background sync**: Периодическая синхронизация с Firestore
3. **Conflict resolution**: 
   - Last write wins для простых полей
   - Merge для коллекций
   - User prompt для критических конфликтов

### Flow
```
┌─────────┐     ┌─────────────┐     ┌──────────┐
│   UI    │────→│  Repository │────→│ Firestore│
└─────────┘     └─────────────┘     └──────────┘
     ↓                ↓
┌─────────┐     ┌─────────────┐
│  Cache  │←────│    Hive     │
└─────────┘     └─────────────┘
```

## Безопасность

### Firebase Security Rules
```javascript
// Проверка прав доступа
function hasRole(allowedRoles) {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in allowedRoles;
}

// Проверка владения
function isOwner(resource) {
  return resource.ownerId == request.auth.uid;
}

// Проверка членства в команде
function isTeamMember(teamId) {
  let team = get(/databases/$(database)/documents/teams/$(teamId)).data;
  return team.memberIds.hasAny([request.auth.uid]);
}
```

## Производительность

### Оптимизация
1. **Pagination**: Загрузка задач порциями по 50
2. **Lazy loading**: Mind-карта загружается по частям
3. **Caching**: Hive для офлайн-доступа
4. **Indexes**: Firestore индексы для частых запросов
5. **Batching**: Пакетная запись в Firestore

### Firestore Indexes
```
tasks: [projectId, createdAt] [assigneeId, status] [dueDate]
events: [startTime, endTime] [attendeeIds]
mindmaps: [projectId, level]
```

## Масштабирование

### Этапы роста

**Phase 1: MVP (сейчас)**
- Базовые CRUD операции
- Простая аутентификация
- Локальный кэш

**Phase 2: Team Features**
- Командная работа
- Роли и разрешения
- Real-time collaboration

**Phase 3: AI Integration**
- Умное планирование
- Авто-приоритизация
- Генерация отчётов

**Phase 4: Enterprise**
- SSO интеграция
- Audit logs
- Advanced analytics

---

**Документ создан для команды NANAHUI** 🚀
