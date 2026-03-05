# detect_image_uid.ps1 -- delegates all logic to detect_image_uid.sh via POSIX sh
[CmdletBinding()]
param()

$sh = Get-Command sh -ErrorAction SilentlyContinue
if (-not $sh) {
    Write-Error "[ERROR] 'sh' not found. Install Git for Windows, WSL, or MSYS2."
    exit 1
}

$shScript = Join-Path $PSScriptRoot "detect_image_uid.sh"
& sh $shScript @args
exit $LASTEXITCODE
