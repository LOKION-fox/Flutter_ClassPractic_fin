@echo off
setlocal

echo === Flutter PetShop + local PocketBase ===
echo PocketBase should already be running at http://127.0.0.1:8090

echo.
echo Installing dependencies...
call flutter pub get
if errorlevel 1 exit /b %errorlevel%

echo.
echo Starting Flutter Web...
call flutter run -d chrome --dart-define=POCKETBASE_URL=http://127.0.0.1:8090
