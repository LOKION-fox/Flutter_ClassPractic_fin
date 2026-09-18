# PocketBase backend files

Эти `pb_migrations` и `pb_hooks` соответствуют backend-схеме зоомагазина.

Если ваш `C:\PocketBase` уже подготовлен и миграции применены, повторно ничего копировать не нужно.

Для нового чистого PocketBase эти две папки кладутся рядом с `pocketbase.exe`:

```text
C:\PocketBase\
├── pocketbase.exe
├── pb_data\
├── pb_migrations\
└── pb_hooks\
```

Затем:

```powershell
.\pocketbase.exe migrate up
.\pocketbase.exe serve
```

`pb_data` содержит реальные данные и учётные записи и не должен попадать в Git.
