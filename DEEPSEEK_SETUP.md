# 🤖 DeepSeek AI - Настройка

## Что такое DeepSeek?

**DeepSeek** - это мощная китайская нейросеть с открытым API, которая:
- 🚀 По качеству на уровне GPT-4
- 💰 В 10-20 раз дешевле OpenAI
- 🌐 Поддерживает русский язык
- 🔑 Даёт бесплатные токены при регистрации

---

## 📝 Как получить API ключ

### Шаг 1: Регистрация

1. Перейди на https://platform.deepseek.com
2. Нажми **Sign Up** или **Login**
3. Зарегистрируйся через email или Google

### Шаг 2: Получение API ключа

1. После входа перейди в **API Keys**: https://platform.deepseek.com/api_keys
2. Нажми **Create API Key**
3. Скопируй ключ (начинается с `sk-`)

**Важно:** Сохрани ключ в надёжном месте! Показать его можно только один раз.

### Шаг 3: Пополнение баланса (опционально)

DeepSeek даёт **бесплатные токены** новым пользователям (~$2-5).

Для пополнения:
1. Перейди в **Billing**: https://platform.deepseek.com/billing
2. Выбери способ оплаты
3. Минимальное пополнение: ~$10

---

## 💰 Тарифы

| Модель | Цена (за 1M токенов) |
|--------|---------------------|
| **DeepSeek Chat** | ~$0.14 (input) / ~$0.28 (output) |
| **DeepSeek Coder** | ~$0.14 (input) / ~$0.28 (output) |

**Для сравнения:**
- GPT-4: ~$30 / $60 за 1M токенов
- DeepSeek: ~$0.14 / $0.28 за 1M токенов

**Экономия: в 200+ раз!** 💰

---

## 🔧 Настройка в проекте

### 1. Создай файл `.env`

Скопируй `.env.example` в `.env`:
```bash
cp .env.example .env
```

### 2. Добавь API ключ

Открой `.env` и вставь ключ:
```
DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxx
```

### 3. Обновите `lib/core/deepseek_service.dart`

```dart
final deepSeekService = DeepSeekService(
  apiKey: 'sk-xxxxxxxxxxxxxxxxxxxxxxxx', // Твой ключ
);
```

Или используй пакет `flutter_dotenv`:

```dart
// В main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  
  final deepSeekService = DeepSeekService(
    apiKey: dotenv.env['DEEPSEEK_API_KEY'],
  );
  
  runApp(...);
}
```

---

## 📱 Примеры использования

### Генерация подзадач

```dart
import 'package:nanaxe_crm/core/deepseek_service.dart';

final subtasks = await deepSeekService.generateSubtasks(
  title: 'Создать CRM систему',
  description: 'Разработка CRM для управления задачами команды с AI',
);

print(subtasks);
// [
//   {"title": "Анализ требований", "estimatedHours": 2, "description": "..."},
//   {"title": "Проектирование", "estimatedHours": 3, "description": "..."},
//   ...
// ]
```

### Приоритизация задачи

```dart
final priority = await deepSeekService.prioritizeTask(
  title: 'Срочный баг',
  description: 'Пользователи не могут войти',
  dueDate: DateTime.now().add(Duration(hours: 2)),
);

print(priority); // TaskPriority.urgent
```

### Умное планирование

```dart
final schedule = await deepSeekService.smartSchedule(
  tasks: myTasks,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 7)),
  availableHoursPerDay: 6,
);

print(schedule);
// [
//   {"taskId": 0, "date": "2026-03-27", "hours": 3},
//   {"taskId": 1, "date": "2026-03-27", "hours": 3},
//   ...
// ]
```

### Генерация mind-карты проекта

```dart
final mindMapNodes = await deepSeekService.generateMindMap(
  projectName: 'CRM App',
  description: 'Мобильное CRM приложение с AI планированием',
);

print(mindMapNodes);
// [
//   {"level": 0, "title": "CRM App", "parentId": null},
//   {"level": 1, "title": "Планирование", "parentId": 0},
//   {"level": 1, "title": "Разработка", "parentId": 0},
//   ...
// ]
```

---

## 🆘 Troubleshooting

### Ошибка: "Invalid API key"

```
1. Проверь что ключ начинается с 'sk-'
2. Убедись что нет лишних пробелов
3. Проверь что ключ активен в Dashboard
```

### Ошибка: "Insufficient balance"

```
1. Проверь баланс в Billing: https://platform.deepseek.com/billing
2. Пополни счёт
3. Или используй mock данные (по умолчанию)
```

### Ошибка: "Rate limit exceeded"

```
DeepSeek ограничивает запросы. Подожди немного или увеличь лимиты в настройках.
```

---

## 📊 Статистика использования

Для отслеживания расходов:

1. Перейди в **Usage**: https://platform.deepseek.com/usage
2. Просматривай статистику по дням/моделям
3. Настрой алерты при достижении лимита

---

## 🔒 Безопасность

**Никогда не публикуй API ключ в GitHub!**

✅ Правильно:
```bash
# Добавить .env в .gitignore
echo ".env" >> .gitignore
```

✅ Использовать в коде:
```dart
// Загружать из .env файла
final apiKey = dotenv.env['DEEPSEEK_API_KEY'];
```

❌ Неправильно:
```dart
// Хардкод ключа в коде
final apiKey = 'sk-xxxxx'; // НЕ ДЕЛАЙ ТАК!
```

---

## 📚 Ресурсы

- **Официальная документация**: https://platform.deepseek.com/docs
- **API Reference**: https://platform.deepseek.com/api-docs
- **Цены**: https://platform.deepseek.com/pricing
- **Dashboard**: https://platform.deepseek.com

---

## 🎯 Следующие шаги

1. ✅ Получить API ключ
2. ✅ Добавить в `.env`
3. ✅ Протестировать генерацию подзадач
4. ✅ Интегрировать в UI приложения
5. ✅ Настроить отслеживание расходов

---

**DeepSeek готов к работе! 🚀**
