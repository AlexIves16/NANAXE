# 🚀 Быстрый старт - NANAHUI CRM

## ✅ Что уже создано

### Структура проекта
```
lib/
├── core/                      # Ядро приложения
│   ├── ai_service.dart        # AI сервис (OpenAI, Anthropic)
│   ├── firebase_config.dart   # Firebase конфигурация
│   ├── firestore_service.dart # Firestore сервис (CRUD операции)
│   ├── local_storage_service.dart # Локальное хранилище (Hive)
│   ├── router.dart            # Маршрутизация (GoRouter)
│   └── theme.dart             # Темы оформления
├── features/                  # Функциональные модули (будущие)
├── models/                    # Модели данных
│   ├── user_model.dart        # Пользователь
│   ├── task_model.dart        # Задача
│   ├── project_model.dart     # Проект
│   ├── mind_map_model.dart    # Mind-карта
│   ├── calendar_event_model.dart # Событие календаря
│   └── alarm_model.dart       # Будильник
├── providers/                 # State management (Riverpod)
│   └── auth_provider.dart     # Аутентификация
├── screens/                   # Экраны
│   ├── auth_screen.dart       # Вход
│   ├── home_screen.dart       # Главная навигация
│   ├── dashboard_screen.dart  # Дашборд
│   ├── tasks_screen.dart      # Задачи
│   ├── mind_map_screen.dart   # Mind-карта
│   ├── calendar_screen.dart   # Календарь
│   └── alarms_screen.dart     # Будильники
└── widgets/                   # Виджеты (будущие)
```

## 🔧 Настройка Firebase

### 1. Создайте проект в Firebase Console

1. Перейдите на https://console.firebase.google.com
2. Нажмите "Add project"
3. Введите имя: "NANAHUI CRM"
4. Отключите Google Analytics (не нужно для начала)
5. Создайте проект

### 2. Включите Authentication

1. В меню слева: **Build** → **Authentication**
2. Нажмите **Get started**
3. Включите **Google** провайдер:
   - Click **Google** → **Enable**
   - Enter support email: ваш email
   - **Save**

### 3. Создайте Firestore базу

1. В меню: **Build** → **Firestore Database**
2. Нажмите **Create database**
3. Выберите **Start in test mode** (потом настроим правила)
4. Выберите локацию (например, us-central)
5. **Enable**

### 4. Добавьте Android приложение

1. В Firebase Console: **Project Settings** (шестерёнка)
2. **Your apps** → **Add app** → **Android**
3. Введите package name: `com.nanahui.nanahui_crm`
4. Скачайте `google-services.json`
5. Положите файл в: `android/app/google-services.json`

### 5. Добавьте iOS приложение (если нужно)

1. **Add app** → **iOS**
2. Bundle ID: `com.nanahui.nanahuiCrm`
3. Скачайте `GoogleService-Info.plist`
4. Положите в: `ios/Runner/GoogleService-Info.plist`

### 6. Настройте android/app/build.gradle

В файле `android/app/build.gradle` добавьте:

```gradle
dependencies {
  // ... другие зависимости
  
  // Firebase
  implementation platform('com.google.firebase:firebase-bom:32.7.0')
  implementation 'com.google.firebase:firebase-analytics'
  implementation 'com.google.firebase:firebase-auth'
  implementation 'com.google.firebase:firebase-firestore'
  implementation 'com.google.firebase:firebase-messaging'
}

// В конце файла:
apply plugin: 'com.google.gms.google-services'
```

## 🔑 Настройка API ключей

### OpenAI API (для AI функций)

1. Перейдите на https://platform.openai.com/api-keys
2. Создайте новый API ключ
3. Скопируйте ключ

### Google Calendar API

1. Перейдите на https://console.cloud.google.com
2. Создайте новый проект или выберите существующий
3. Включите **Google Calendar API**
4. Создайте OAuth 2.0 credentials
5. Получите Client ID и Client Secret

## 📝 Настройка окружения

1. Скопируйте `.env.example` в `.env`:
```bash
cp .env.example .env
```

2. Заполните `.env` своими ключами:
```
OPENAI_API_KEY=sk-your-actual-openai-key
FIREBASE_API_KEY=your-firebase-key
# и т.д.
```

## 🏃 Запуск приложения

### 1. Установите зависимости
```bash
flutter pub get
```

### 2. Запуск на эмуляторе/устройстве
```bash
flutter run
```

### 3. Сборка APK (Android)
```bash
flutter build apk --release
```

### 4. Сборка для iOS
```bash
flutter build ios --release
```

## 📱 Тестирование

### Проверка аутентификации
1. Запустите приложение
2. Нажмите "Войти через Google"
3. Выберите аккаунт
4. Должна произойти авторизация и переход на главный экран

### Проверка навигации
1. После входа используйте нижнюю навигационную панель
2. Переключайтесь между: Главная, Задачи, Mind-карта, Календарь, Будильники

## 🔥 Firestore правила безопасности

Создайте в Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
    
    // Projects
    match /projects/{projectId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated();
    }
    
    // Tasks
    match /tasks/{taskId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAuthenticated();
    }
    
    // Events
    match /events/{eventId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAuthenticated();
    }
    
    // Alarms
    match /alarms/{alarmId} {
      allow read: if isAuthenticated();
      allow create, update, delete: if isAuthenticated();
    }
    
    // Mind maps
    match /mindmaps/{projectId}/nodes/{nodeId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated();
    }
  }
}
```

## 📊 Структура Firestore

```
users/
  └─ {userId}/
      ├─ email: string
      ├─ displayName: string
      ├─ photoUrl: string
      ├─ role: "admin" | "member" | "viewer"
      ├─ teamIds: string[]
      └─ settings: map

projects/
  └─ {projectId}/
      ├─ name: string
      ├─ description: string
      ├─ teamId: string
      ├─ ownerId: string
      ├─ memberIds: string[]
      ├─ status: string
      ├─ startDate: timestamp
      ├─ endDate: timestamp
      └─ color: string

tasks/
  └─ {taskId}/
      ├─ title: string
      ├─ description: string
      ├─ projectId: string
      ├─ parentTaskId: string?
      ├─ status: "todo" | "inProgress" | "review" | "done"
      ├─ priority: "low" | "medium" | "high" | "urgent"
      ├─ assigneeId: string?
      ├─ creatorId: string
      ├─ dueDate: timestamp?
      └─ aiMetadata: map

mindmaps/
  └─ {projectId}/
      └─ nodes/
          └─ {nodeId}/
              ├─ parentId: string?
              ├─ level: number
              ├─ title: string
              ├─ taskId: string?
              ├─ x: number
              ├─ y: number
              └─ color: string

events/
  └─ {eventId}/
      ├─ title: string
      ├─ startTime: timestamp
      ├─ endTime: timestamp
      ├─ googleEventId: string?
      └─ attendeeIds: string[]

alarms/
  └─ {alarmId}/
      ├─ title: string
      ├─ dateTime: timestamp
      ├─ isRepeating: boolean
      └─ taskId: string?
```

## 🛠 Следующие шаги

### Первоочередные задачи:

1. ✅ ~~Создать базовую структуру~~
2. ✅ ~~Настроить модели данных~~
3. ✅ ~~Создать экраны навигации~~
4. 🔲 Настроить Firebase проект
5. 🔲 Реализовать реальную аутентификацию
6. 🔲 Добавить CRUD операции с Firestore
7. 🔲 Реализовать синхронизацию офлайн-данных
8. 🔲 Добавить AI функции (OpenAI API)
9. 🔲 Интеграция с Google Calendar
10. 🔲 Создать mind-map виджет с drag-drop

### Для тестирования AI:

1. Добавьте OpenAI API ключ в `lib/core/ai_service.dart`:
```dart
final aiService = AIService(
  openaiApiKey: 'sk-your-api-key-here',
);
```

2. Протестируйте генерацию подзадач:
```dart
final subtasks = await aiService.generateSubtasks(
  title: 'Создать CRM систему',
  description: 'Разработка CRM для управления задачами команды',
);
print(subtasks);
```

## 🆘 Troubleshooting

### Ошибка: "No Firebase App"
- Убедитесь, что `google-services.json` лежит в `android/app/`
- Проверьте, что добавлен `apply plugin: 'com.google.gms.google-services'`

### Ошибка: "Sign-in failed"
- Проверьте SHA-1 fingerprint для Android
- Убедитесь, что Google Sign-In включён в Firebase Console

### Ошибка: "Permission denied"
- Проверьте правила безопасности Firestore
- Убедитесь, что пользователь аутентифицирован

## 📚 Ресурсы

- [Flutter документация](https://docs.flutter.dev)
- [Riverpod документация](https://riverpod.dev)
- [Firebase Flutter](https://firebase.flutter.dev)
- [OpenAI API](https://platform.openai.com/docs)

---

**Создано для команды NANAHUI** 🚀
