# 🔑 Как добавить SHA-1 fingerprint

## Способ 1: Через Android Studio (проще)

1. Открой проект в Android Studio
2. Справа открой **Gradle** панель
3. Разверни `:android` → `Tasks` → `android`
4. Дважды кликни на **signingReport**
5. В консоли найди строку `SHA1:`
6. Скопируй значение

## Способ 2: Через командную строку

```bash
cd c:\Users\ormix\NANAHUI\android
.\gradlew app:signingReport
```

Ищи строку вида:
```
SHA1: A1:B2:C3:D4:E5:F6:...
```

## Способ 3: Через keytool (если есть Java)

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

---

## ➕ Добавить в Firebase Console

1. Открой https://console.firebase.google.com/project/nanax26-1f33b/settings/general/android:com.nanaxe.nanaxe_crm
2. Прокрути вниз до **SHA certificate fingerprints**
3. Нажми **Add fingerprint**
4. Вставь скопированный SHA-1
5. Сохрани

---

## ✅ Проверка

После добавления SHA-1:
1. Перескачай `google-services.json` из Firebase Console
2. Замени файл в `android/app/google-services.json`
3. Запусти приложение: `flutter run`
4. Попробуй войти через Google

Если работает — всё настроено правильно! 🎉
