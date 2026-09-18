# Зоомагазин — Flutter Web + PocketBase

Это версия проекта, переделанная с локального `mock-server.js` на PocketBase.

## Что изменено

- `mock-server.js` и Dio больше не используются.
- Авторизация работает через Auth Collection `users` в PocketBase.
- CRUD товаров, животных, категорий, поставщиков и покупателей работает напрямую через PocketBase Dart SDK.
- ID сущностей переведены с `int` на строковые PocketBase ID.
- Карта лояльности покупателя хранится в отдельной коллекции `loyalty_cards`.
- Сессия PocketBase сохраняется в `SharedPreferences`, поэтому вход не теряется после F5.
- В проект добавлен GitHub Actions workflow для проверки, сборки Flutter Web и публикации в GitHub Pages.
- В папке `pocketbase/` лежат миграции и hook для той же схемы PocketBase, которую можно хранить в Git.

## 1. Локальный запуск

Сначала запустите ваш уже подготовленный PocketBase:

```powershell
cd C:\PocketBase
.\pocketbase.exe serve
```

По умолчанию Flutter ожидает PocketBase здесь:

```text
http://127.0.0.1:8090
```

Затем в папке Flutter-проекта:

```powershell
flutter pub get
flutter run -d chrome --dart-define=POCKETBASE_URL=http://127.0.0.1:8090
```

Так как `http://127.0.0.1:8090` является значением по умолчанию, локально можно также запустить просто:

```powershell
flutter run -d chrome
```

## 2. Тестовые пользователи приложения

После применения seed-миграции доступны:

```text
admin / admin123
manager / manager123
customer / customer123
```

Это пользователи Flutter-приложения, а не superuser админки PocketBase.

## 3. GitHub Pages

Workflow уже находится здесь:

```text
.github/workflows/deploy-pages.yml
```

Создавать YAML-файл Action вручную не нужно.

### Обязательная переменная GitHub

Откройте репозиторий:

```text
Settings
→ Secrets and variables
→ Actions
→ Variables
→ New repository variable
```

Создайте:

```text
Name:  POCKETBASE_URL
Value: https://ВАШ-ПУБЛИЧНЫЙ-POCKETBASE-АДРЕС
```

Например:

```text
https://pb.example.com
```

Для GitHub Pages адрес PocketBase должен быть доступен из интернета по HTTPS.
`http://127.0.0.1:8090` подходит только для локального запуска и не будет доступен посетителям GitHub Pages.

### Включение GitHub Pages

В репозитории откройте:

```text
Settings
→ Pages
→ Build and deployment
→ Source: GitHub Actions
```

После этого push в ветку `main` запустит workflow. Он выполнит:

```text
flutter pub get
→ dart format
→ flutter analyze
→ flutter test
→ flutter build web
→ GitHub Pages deploy
```

Workflow автоматически определяет имя репозитория и передаёт правильный `--base-href`, поэтому проектный GitHub Pages URL вида

```text
https://USERNAME.github.io/REPOSITORY/
```

поддерживается.

## 4. Где должен работать PocketBase после публикации

GitHub Actions и GitHub Pages публикуют только Flutter Web. Они не являются постоянным сервером PocketBase.

Для онлайн-версии PocketBase должен быть отдельно запущен на сервере с постоянным хранилищем `pb_data`, например на VPS или другом сервисе с persistent disk.

После получения публичного HTTPS URL этого PocketBase просто запишите его в GitHub Variable `POCKETBASE_URL` и заново запустите workflow (или сделайте новый push).

## 5. PocketBase в репозитории

Папка:

```text
pocketbase/
├── pb_migrations/
└── pb_hooks/
```

содержит схему и серверную бизнес-логику. Её можно коммитить.

Не коммитьте:

```text
pb_data/
pocketbase.exe
```

Они уже добавлены в `.gitignore`.

## 6. Основные коллекции

Проект использует:

```text
users
categories
suppliers
products
animals
customers
loyalty_cards
orders
order_items
```

Текущий Flutter-интерфейс работает с пользователями, каталогом, справочниками, покупателями и картами лояльности. `orders` и `order_items` уже присутствуют в backend-схеме как дополнительные связанные сущности итогового проекта и могут быть подключены к интерфейсу отдельным следующим этапом.

## 7. Где задаётся адрес PocketBase

Файл:

```text
lib/core/api_config.dart
```

Используется compile-time параметр:

```text
POCKETBASE_URL
```

Локально его можно передать командой `--dart-define`, а на GitHub он автоматически берётся workflow из Repository Variable `POCKETBASE_URL`.
