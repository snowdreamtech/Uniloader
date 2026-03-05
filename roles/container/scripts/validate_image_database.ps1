# validate_image_database.ps1 -- delegates all logic to validate_image_database.sh via POSIX sh
[CmdletBinding()]
param()

$sh = Get-Command sh -ErrorAction SilentlyContinue
if (-not $sh) {
  Write-Error "[ERROR] 'sh' not found. Install Git for Windows, WSL, or MSYS2."
  exit 1
}

$shScript = Join-Path $PSScriptRoot "validate_image_database.sh"
& sh $shScript @args
exit $LASTEXITCODE
