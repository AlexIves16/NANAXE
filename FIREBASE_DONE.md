# ✅ Настройка Firebase завершена!

## 📦 Что сделано:

### 1. Gradle настроен правильно ✅
- **Kotlin DSL** (`build.gradle.kts`) — современный подход
- **Google Services Plugin** версии 4.4.4 добавлен
- **Firebase BoM** версии 34.11.0 подключён
- Все Firebase зависимости добавлены:
  - `firebase-analytics`
  - `firebase-auth`
  - `firebase-firestore`
  - `firebase-messaging`

### 2. Package name ✅
- Application ID: `com.nanaxe.nanaxe_crm`
- Соответствует `google-services.json`

### 3. AndroidManifest обновлён ✅
- Добавлены разрешения для Firebase и уведомлений
- Название приложения: "NANAHUI CRM"

### 4. Правила безопасности Firestore ✅
- Файл `firestore.rules` создан
- Доступ только для аутентифицированных пользователей
- Поддержка ролей (admin, member, viewer)

---

## 🚀 СЛЕДУЮЩИЙ ШАГ: Загрузить правила безопасности

### Открой Firebase Console:
1. Перейди в https://console.firebase.google.com
2. Выбери проект `nanax26-1f33b`
3. Слева: **Build** → **Firestore Database**
4. Вверху выбери вкладку **Rules**
5. Скопируй содержимое файла `firestore.rules` и вставь в редактор
6. Нажми **Publish**

**Или используй Firebase CLI:**
```bash
npm install -g firebase-tools
firebase login
firebase use nanax26-1f33b
firebase deploy --only firestore:rules
```

---

## 📱 Запуск приложения

### 1. Подключи устройство или запусти эмулятор
```bash
# Проверка подключенных устройств
flutter devices
```

### 2. Запусти приложение
```bash
flutter run
```

### 3. Если ошибка с SHA-1 ключом
Для Google Sign-In нужен SHA-1 fingerprint:

```bash
# Для debug ключа (Windows)
cd android
gradlew app:signingReport
```

Скопируй SHA-1 из отчёта и добавь в Firebase Console:
1. Project Settings → Your apps → Android app
2. Add fingerprint
3. Вставь SHA-1
4. Save

---

## 🔧 Проверка работы

### Чек-лист:
- [ ] Firebase проект создан
- [ ] Authentication включён (Google provider)
- [ ] Firestore база создана (region: eur3)
- [ ] Android приложение зарегистрировано
- [ ] `google-services.json` лежит в `android/app/`
- [ ] Gradle файлы обновлены
- [ ] Правила безопасности загружены в Firebase
- [ ] SHA-1 fingerprint добавлен (для Google Sign-In)

### Тест аутентификации:
1. Запусти приложение
2. Нажми "Войти через Google"
3. Выбери аккаунт
4. Если успешно — переход на главный экран ✅

---

## 📊 Структура Firestore (автоматически создаётся)

```
users/
  └─ {userId}/
      ├─ email
      ├─ displayName
      ├─ role: "member"
      ├─ teamIds: []
      └─ settings: {}

teams/
  └─ {teamId}/
      ├─ name
      ├─ memberIds: []
      └─ projects: subcollection

projects/
  └─ {projectId}/
      ├─ name
      ├─ ownerId
      └─ tasks: subcollection

tasks/
  └─ {taskId}/
      ├─ title
      ├─ status: "todo"
      ├─ priority: "medium"
      └─ assigneeId

mindmaps/
  └─ {projectId}/
      └─ nodes/
          └─ {nodeId}/
              ├─ title
              ├─ level
              └─ parentId

events/
  └─ {eventId}/
      ├─ title
      ├─ startTime
      └─ attendeeIds

alarms/
  └─ {alarmId}/
      ├─ title
      ├─ dateTime
      └─ isRepeating
```

---

## 🆘 Возможные ошибки

### "No Firebase App"
```
Проверь что google-services.json лежит в android/app/
```

### "Sign-in failed"
```
1. Добавь SHA-1 fingerprint в Firebase Console
2. Перескачай google-services.json
3. Пересобери приложение: flutter clean && flutter run
```

### "Permission denied"
```
1. Проверь что правила безопасности загружены
2. Убедись что пользователь аутентифицирован
```

### "App not found"
```
1. Проверь что package name совпадает:
   - В google-services.json: "com.nanaxe.nanaxe_crm"
   - В build.gradle.kts: applicationId = "com.nanaxe.nanaxe_crm"
```

---

## 📚 Документация

- [Firebase Flutter Setup](https://firebase.flutter.dev/docs/overview)
- [Firestore Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)

---

**Готово! Запускай `flutter run`** 🚀
