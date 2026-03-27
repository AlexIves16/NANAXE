# 🚀 NANAHUI CRM

CRM-ассистент для команд с AI-планированием, mind-картами и интеграцией с Google Calendar.

## 📱 Возможности

- ✅ **Управление задачами** - создание, назначение, приоритеты, статусы
- ✅ **Mind-карты проектов** - визуальное дерево задач
- ✅ **Календарь** - синхронизация с Google Calendar
- ✅ **Будильники/Напоминания** - локальные уведомления
- ✅ **AI-ассистент** - умное планирование и генерация подзадач
- ✅ **Ролевая модель** - admin, member, viewer
- ✅ **Офлайн-режим** - кэширование данных на устройстве

## 🛠 Технологический стек

| Компонент | Технология |
|-----------|------------|
| Framework | Flutter |
| State Management | Riverpod |
| Backend | Firebase (Firestore, Auth, FCM) |
| Local Storage | Hive |
| Navigation | GoRouter |
| AI | OpenAI API (планируется) |

## 🚀 Быстрый старт

### 1. Клонирование
```bash
git clone <repository-url>
cd NANAHUI
```

### 2. Установка зависимостей
```bash
flutter pub get
```

### 3. Настройка Firebase
1. Создай проект в [Firebase Console](https://console.firebase.google.com)
2. Включи Authentication (Google Sign-In)
3. Создай Firestore базу данных
4. Скачай `google-services.json` и положи в `android/app/`
5. Загрузи правила безопасности из `firestore.rules`

### 4. Запуск
```bash
flutter run
```

## 📚 Документация

- [README.md](README.md) - Общая информация
- [QUICKSTART.md](QUICKSTART.md) - Подробный быстрый старт
- [ARCHITECTURE.md](ARCHITECTURE.md) - Архитектура проекта
- [SETUP_COMPLETE.md](SETUP_COMPLETE.md) - Итоги настройки

## 📁 Структура проекта

```
lib/
├── core/           # Сервисы (Firebase, AI, Storage)
├── models/         # Модели данных
├── providers/      # State management (Riverpod)
├── screens/        # Экраны приложения
└── widgets/        # Переиспользуемые виджеты
```

## 🔧 Настройка окружения

1. Скопируй `.env.example` в `.env`
2. Заполни API ключами (OpenAI, Firebase, etc.)

## 🤝 Вклад

Этот проект создан для внутренней команды NANAHUI.

## 📄 Лицензия

Internal use only

---

**Создано для команды NANAHUI** 🚀
