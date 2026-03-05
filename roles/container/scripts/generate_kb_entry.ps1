# generate_kb_entry.ps1 -- delegates all logic to generate_kb_entry.sh via POSIX sh
[CmdletBinding()]
param()

$sh = Get-Command sh -ErrorAction SilentlyContinue
if (-not $sh) {
    Write-Error "[ERROR] 'sh' not found. Install Git for Windows, WSL, or MSYS2."
    exit 1
}

$shScript = Join-Path $PSScriptRoot "generate_kb_entry.sh"
& sh $shScript @args
exit $LASTEXITCODE
