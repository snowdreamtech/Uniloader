@echo off
setlocal EnableDelayedExpansion

:: Set default values
set "INVENTORY=localhost"
set "PLAYBOOK=orchestrator"
set "VERBOSITY="
set "VAULT_VARS=@%USERPROFILE%\.uniloader\.vault.yml"
set "VAULT_PASS=%USERPROFILE%\.uniloader\.vault_pass"
set "EXTRA_ARGS="

:: Parse arguments
:parse_args
if "%~1"=="" goto :execute

if /i "%~1"=="-i" (
    set "INVENTORY=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--inventory" (
    set "INVENTORY=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-p" (
    set "PLAYBOOK=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--playbook" (
    set "PLAYBOOK=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-v" (
    set "VERBOSITY=%~1"
    shift
    goto :parse_args
)
if /i "%~1"=="-vv" (
    set "VERBOSITY=%~1"
    shift
    goto :parse_args
)
if /i "%~1"=="-vvv" (
    set "VERBOSITY=%~1"
    shift
    goto :parse_args
)
if /i "%~1"=="-vvvv" (
    set "VERBOSITY=%~1"
    shift
    goto :parse_args
)
if /i "%~1"=="--vault-vars" (
    set "VAULT_VARS=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--vault-pass" (
    set "VAULT_PASS=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-e" (
    set "EXTRA_ARGS=!EXTRA_ARGS! -e "%~2""
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--extra-vars" (
    set "EXTRA_ARGS=!EXTRA_ARGS! -e "%~2""
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--home-action" (
    set "HOME_ACTION=%~2"
    set "PLAYBOOK=home"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--home-files" (
    set "HOME_FILES=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-h" goto :usage
if /i "%~1"=="--help" goto :usage

:: Pass through any other arguments
set "EXTRA_ARGS=!EXTRA_ARGS! %~1"
shift
goto :parse_args

:usage
echo Usage: %~nx0 [OPTIONS]
echo.
echo Options:
echo   -i, --inventory ^<name^>    Inventory name (default: localhost -> inventory\localhost.yml)
echo   -p, --playbook ^<name^>     Playbook name (default: orchestrator -> playbooks\orchestrator.yml)
echo   -v                        Verbosity level (default: none, supports -v, -vv, -vvv, etc.)
echo   --vault-vars ^<file^>       Path to vault vars file (default: ~/.uniloader/.vault.yml)
echo   --vault-pass ^<file^>       Path to vault password file (default: ~/.uniloader/.vault_pass)
echo   -e, --extra-vars ^<vars^>   Additional extra vars
echo   --home-action ^<action^>    Home role action (encrypt, decrypt, restore). Sets playbook to 'home'.
echo   --home-files ^<files^>      Comma-separated list of files for home role action.
echo   -h, --help                Show this help message
echo.
exit /b 0

:execute

:: Resolve inventory path
echo "%INVENTORY%" | findstr /R "[\\/]" >nul
if errorlevel 1 (
    set "INVENTORY_PATH=inventory\%INVENTORY%.yml"
) else (
    set "INVENTORY_PATH=%INVENTORY%"
)

:: Resolve playbook path
echo "%PLAYBOOK%" | findstr /R "[\\/]" >nul
if errorlevel 1 (
    if /i not "%PLAYBOOK:~-4%"==".yml" set "PLAYBOOK=%PLAYBOOK%.yml"
    set "PLAYBOOK_PATH=playbooks\%PLAYBOOK%"
) else (
    set "PLAYBOOK_PATH=%PLAYBOOK%"
)

:: Ensure paths exist (Basic check, Windows path handling can be tricky)
if not exist "%INVENTORY_PATH%" (
    echo Error: Inventory file '%INVENTORY_PATH%' not found.
    exit /b 1
)

if not exist "%PLAYBOOK_PATH%" (
    echo Error: Playbook file '%PLAYBOOK_PATH%' not found.
    exit /b 1
)

:: Activate Virtual Environment
set "PROJECT_ROOT=%~dp0.."
if exist "%PROJECT_ROOT%\.venv\Scripts\activate.bat" (
    call "%PROJECT_ROOT%\.venv\Scripts\activate.bat"
) else (
    if exist "%PROJECT_ROOT%\scripts\setup_venv.bat" (
        echo Virtual environment not found. Attempting to create one...
        call "%PROJECT_ROOT%\scripts\setup_venv.bat"
    ) else (
        echo Error: Virtual environment not found and setup script missing.
        exit /b 1
    )
)

)

:: Process Home Role arguments if present
if defined HOME_ACTION (
    set "EXTRA_ARGS=!EXTRA_ARGS! -e "home_action=!HOME_ACTION!""
)

if defined HOME_FILES (
    :: Convert comma-separated to JSON list: "file1,file2" -> "file1","file2"
    :: We use substitution to replace commas with quote-comma-quote
    set "FILES=!HOME_FILES:,=","!"

    :: Wrap in JSON array syntax
    :: We must be careful with quotes for cmd.
    :: Constructing: -e "{\"home_files\": [\"file1\",\"file2\"]}"
    set "JSON_PAYLOAD={\"home_files\": [\"!FILES!\"]}"
    set "EXTRA_ARGS=!EXTRA_ARGS! -e "!JSON_PAYLOAD!""
)

:: Construct Command
set "CMD=ansible-playbook -i "%INVENTORY_PATH%" "%PLAYBOOK_PATH%" %VERBOSITY% -e "%VAULT_VARS%" --vault-password-file "%VAULT_PASS%" %EXTRA_ARGS%"

echo Running: %CMD%
echo ----------------------------------------------------------------

:: Execute
%CMD%
