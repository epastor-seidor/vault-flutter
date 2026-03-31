@echo off
echo ============================================
echo   DevVault - Actualizar Documentacion
echo ============================================
echo.

cd /d "%~dp0"

echo [1/5] Verificando Flutter...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter no esta instalado
    pause
    exit /b 1
)
echo OK
echo.

echo [2/5] Instalando dependencias...
flutter pub get
echo.

echo [3/5] Analizando codigo...
flutter analyze --no-fatal-infos --no-fatal-warnings
echo.

echo [4/5] Verificando documentacion existente...
set DOCS_OK=true
for %%f in (README.md docs\arquitectura.md docs\guia-desarrollo.md docs\guia-usuario.md) do (
    if exist "%%f" (
        echo   [OK] %%f
    ) else (
        echo   [FALTA] %%f
        set DOCS_OK=false
    )
)
echo.

echo [5/5] Actualizando fechas en documentacion...
for %%f in (docs\arquitectura.md docs\guia-desarrollo.md docs\guia-usuario.md) do (
    if exist "%%f" (
        powershell -Command "(Get-Content '%%f') -replace 'Ultima actualizacion:.*', 'Ultima actualizacion: %date:~6,4%-%date:~3,2%-%date:~0,2%' | Set-Content '%%f'"
        echo   Actualizado: %%f
    )
)
echo.

echo ============================================
echo   Documentacion actualizada correctamente
echo ============================================
echo.
echo Para commitear los cambios:
echo   git add README.md docs/
echo   git commit -m "docs: actualizar documentacion"
echo.
pause
