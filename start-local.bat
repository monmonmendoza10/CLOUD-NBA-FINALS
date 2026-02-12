@echo off
REM Local deployment server for testing NBA Oracle (Windows)

setlocal enabledelayedexpansion

set PORT=8000

echo 🏀 NBA Postseason Oracle - Local Development Server
echo ==================================================
echo.
echo Starting local server on http://localhost:%PORT%
echo.
echo 📝 Available pages:
echo    - Home:        http://localhost:%PORT%/
echo    - CSS:         http://localhost:%PORT%/src/styles.css
echo    - JavaScript:  http://localhost:%PORT%/src/script.js
echo.
echo 🧪 Testing predictions:
echo    1. Open http://localhost:%PORT% in your browser
echo    2. Select a team from the dropdown
echo    3. Enter: Wins (50), Losses (32), 3P%% (37), Def Rating (112)
echo    4. Click 'Get Prediction'
echo    5. See ML mock prediction with confidence score
echo.
echo ⚙️ Mock ML Configuration:
echo    - Uses sample prediction logic (no Azure ML needed)
echo    - Provides realistic confidence scores
echo    - Stores predictions in browser localStorage
echo    - Replace with real ML endpoint in Phase 3
echo.
echo 📖 Documentation:
echo    - Quick Start:  %cd%\QUICKSTART.md
echo    - Full Setup:   %cd%\README.md
echo    - Next Steps:   %cd%\SETUP_GITHUB_SECRETS.md
echo.
echo Press Ctrl+C to stop server
echo.

REM Try Python first
python -m http.server %PORT% >nul 2>&1
if !errorlevel! equ 0 goto done

REM Try npx if Python not found
npx http-server . -p %PORT%
if !errorlevel! equ 0 goto done

REM If both fail
echo ❌ Error: Please install Python or Node.js
exit /b 1

:done
