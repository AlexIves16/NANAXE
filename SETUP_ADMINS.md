# 📝 Настройка админов в Firestore

## Админы NANAXE CRM

### Email админов:
1. `almalexyz@gmail.com`
2. `ormix16@gmail.com`

## Как назначить админа:

### Способ 1: Через Firebase Console

1. Открой https://console.firebase.google.com/project/nanax26-1f33b/firestore
2. Найди коллекцию `users`
3. Найди документ пользователя по email
4. Измени поле `role` на `"admin"`

### Способ 2: Через Firestore запрос

```javascript
// В Firebase Console → Firestore → Start collection
db.collection('users').where('email', '==', 'almalexyz@gmail.com').get()
  .then(snapshot => {
    snapshot.docs.forEach(doc => {
      doc.ref.update({ role: 'admin' });
    });
  });

db.collection('users').where('email', '==', 'ormix16@gmail.com').get()
  .then(snapshot => {
    snapshot.docs.forEach(doc => {
      doc.ref.update({ role: 'admin' });
    });
  });
```

### Способ 3: Через Cloud Functions (автоматически)

```javascript
exports.setOnAdminLogin = functions.auth.user().onCreate(async (user) => {
  const adminEmails = ['almalexyz@gmail.com', 'ormix16@gmail.com'];
  
  if (adminEmails.includes(user.email)) {
    await admin.firestore().collection('users').doc(user.uid).update({
      role: 'admin'
    });
  }
});
```

## Проверка роли:

В коде приложения:
```dart
final user = ref.watch(currentUserProvider);
if (user?.isAdmin ?? false) {
  // Показать админку
}
```

## Роли:

- `admin` - полный доступ ко всем функциям
- `member` - создание задач, редактирование своих
- `viewer` - только просмотр
