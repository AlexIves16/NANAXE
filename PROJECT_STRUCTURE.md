# 📁 Структура проекта NANAHUI CRM

```
NANAHUI/
│
├── 📄 README.md                    # Общая информация о проекте
├── 📄 QUICKSTART.md                # Быстрый старт и настройка
├── 📄 ARCHITECTURE.md              # Архитектурное описание
├── 📄 FIREBASE_SETUP.md            # Инструкция по настройке Firebase
├── 📄 .env.example                 # Шаблон переменных окружения
├── 📄 .gitignore                   # Git ignore файл
├── 📄 pubspec.yaml                 # Зависимости Flutter
│
├── 📂 lib/                         # Исходный код приложения
│   │
│   ├── 📄 main.dart                # Точка входа
│   │
│   ├── 📂 core/                    # Ядро приложения
│   │   ├── firebase_config.dart    # Конфигурация Firebase
│   │   ├── firestore_service.dart  # Сервис для работы с Firestore
│   │   ├── local_storage_service.dart  # Локальное хранилище (Hive)
│   │   ├── ai_service.dart         # AI сервис (OpenAI, Anthropic)
│   │   ├── router.dart             # Маршрутизация (GoRouter)
│   │   └── theme.dart              # Темы оформления
│   │
│   ├── 📂 models/                  # Модели данных
│   │   ├── user_model.dart         # Пользователь
│   │   ├── task_model.dart         # Задача
│   │   ├── project_model.dart      # Проект
│   │   ├── mind_map_model.dart     # Mind-карта
│   │   ├── calendar_event_model.dart  # Событие календаря
│   │   └── alarm_model.dart        # Будильник/Напоминание
│   │
│   ├── 📂 providers/               # State Management (Riverpod)
│   │   └── auth_provider.dart      # Провайдер аутентификации
│   │
│   ├── 📂 screens/                 # Экраны приложения
│   │   ├── auth_screen.dart        # Экран входа
│   │   ├── home_screen.dart        # Главная навигация
│   │   ├── dashboard_screen.dart   # Дашборд
│   │   ├── tasks_screen.dart       # Задачи
│   │   ├── mind_map_screen.dart    # Mind-карта
│   │   ├── calendar_screen.dart    # Календарь
│   │   └── alarms_screen.dart      # Будильники
│   │
│   ├── 📂 widgets/                 # Переиспользуемые виджеты
│   │   └── (создаётся по мере необходимости)
│   │
│   └── 📂 features/                # Функциональные модули
│       └── (для будущего расширения)
│
├── 📂 assets/                      # Ресурсы приложения
│   ├── 📂 images/                  # Изображения
│   │   └── .gitkeep
│   └── 📂 icons/                   # Иконки
│       └── .gitkeep
│
├── 📂 test/                        # Тесты
│   └── widget_test.dart            # Widget тесты
│
├── 📂 android/                     # Android платформа
│   ├── 📂 app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   ├── kotlin/             # Kotlin код
│   │   │   ├── res/                # Ресурсы Android
│   │   │   └── ...
│   │   └── build.gradle            # Android build config
│   └── google-services.json        # ⚠️ Firebase config (нужно добавить)
│
├── 📂 ios/                         # iOS платформа
│   ├── 📂 Runner/
│   │   ├── AppDelegate.swift
│   │   ├── Info.plist
│   │   └── ...
│   └── GoogleService-Info.plist    # ⚠️ Firebase config (нужно добавить)
│
├── 📂 web/                         # Web платформа
│   ├── index.html
│   └── manifest.json
│
├── 📂 windows/                     # Windows платформа
│   └── ...
│
├── 📂 linux/                       # Linux платформа
│   └── ...
│
├── 📂 macos/                       # macOS платформа
│   └── ...
│
└── 📂 build/                       # ⚠️ Build artifacts (не в git)
    └── (генерируется при сборке)
```

## 🔑 Ключевые файлы

### Конфигурация
| Файл | Описание |
|------|----------|
| `pubspec.yaml` | Зависимости и настройки Flutter |
| `.gitignore` | Исключения для Git |
| `.env.example` | Шаблон переменных окружения |

### Firebase (нужно добавить)
| Файл | Где взять | Куда положить |
|------|-----------|---------------|
| `google-services.json` | Firebase Console → Android | `android/app/` |
| `GoogleService-Info.plist` | Firebase Console → iOS | `ios/Runner/` |

### Основные модули
| Модуль | Файл | Описание |
|--------|------|----------|
| **Entry Point** | `lib/main.dart` | Инициализация и запуск |
| **Firebase** | `lib/core/firebase_config.dart` | Настройка Firebase |
| **Auth** | `lib/providers/auth_provider.dart` | Аутентификация через Google |
| **Firestore** | `lib/core/firestore_service.dart` | CRUD операции с БД |
| **AI** | `lib/core/ai_service.dart` | Интеграция с OpenAI |
| **Storage** | `lib/core/local_storage_service.dart` | Офлайн кэш на Hive |
| **Router** | `lib/core/router.dart` | Навигация между экранами |
| **Theme** | `lib/core/theme.dart` | Светлая/тёмная темы |

## 📦 Основные зависимости

### State Management
- `flutter_riverpod: ^2.5.0` - Реактивное управление состоянием
- `riverpod_annotation: ^2.3.5` - Code generation для Riverpod

### Firebase
- `firebase_core: ^2.32.0` - Ядро Firebase
- `firebase_auth: ^4.19.0` - Аутентификация
- `cloud_firestore: ^4.17.0` - Firestore база данных
- `firebase_messaging: ^14.9.0` - Push уведомления

### Local Storage
- `hive_flutter: ^1.1.0` - Быстрое локальное хранилище
- `hive: ^2.2.3` - Hive ядро

### Navigation
- `go_router: ^13.1.0` - Декларативная маршрутизация

### AI
- `http: ^1.2.0` - HTTP клиент для API запросов
- `dio: ^5.4.0` - Продвинутый HTTP клиент

### UI
- `graphview: ^1.2.0` - Визуализация графов (для mind-карт)
- `flutter_mind_map: ^1.0.23` - Готовый mind-map виджет
- `flutter_staggered_grid_view: ^0.7.0` - Сетка для карточек

### Google Integration
- `google_sign_in: ^6.2.1` - Вход через Google
- `googleapis: ^13.2.0` - Google API (Calendar и др.)

### Notifications
- `flutter_local_notifications: ^17.0.0` - Локальные уведомления
- `workmanager: ^0.5.2` - Фоновые задачи

## 🎯 Точки расширения

### Для добавления новой фичи:

1. **Создать модель** в `lib/models/`
2. **Создать сервис** в `lib/core/` или `lib/features/`
3. **Создать провайдер** в `lib/providers/`
4. **Создать экран** в `lib/screens/`
5. **Добавить маршрут** в `lib/core/router.dart`
6. **Добавить виджеты** в `lib/widgets/`

### Пример: Добавление заметок

```
lib/
├── models/
│   └── note_model.dart          # ✨ Новая модель
├── features/
│   └── notes/
│       ├── note_service.dart    # ✨ Сервис
│       └── note_provider.dart   # ✨ Провайдер
├── screens/
│   └── notes_screen.dart        # ✨ Экран
└── widgets/
    └── note_card.dart           # ✨ Виджет
```

## 📊 Метрики проекта

```
Строки кода: ~2000+
Файлов: ~20
Модулей: 6 (Auth, Tasks, MindMap, Calendar, Alarms, Dashboard)
Моделей данных: 6
Экранов: 6
Сервисов: 4 (Firebase, Firestore, AI, LocalStorage)
```

## 🔄 CI/CD (будущее)

```yaml
.github/workflows/
├── build.yml          # Сборка APK
├── test.yml           # Запуск тестов
└── deploy.yml         # Деплой в Store
```

---

**Структура создана для команды NANAHUI** 🚀
Последнее обновление: Март 2026
