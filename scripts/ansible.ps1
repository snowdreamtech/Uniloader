[CmdletBinding()]
param(
    [string]$Inventory = "localhost",
    [string]$Playbook = "orchestrator",
    [string]$Verbosity = "",
    [string]$VaultVars = "@$HOME\.uniloader\.vault.yml",
    [string]$VaultPass = "$HOME\.uniloader\.vault_pass",
    [string[]]$ExtraVars,
    [string]$HomeAction,
    [string]$HomeFiles,
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\run.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Inventory <name>     Inventory name (default: localhost -> inventory\localhost.yml)"
    Write-Host "  -Playbook <name>      Playbook name (default: orchestrator -> playbooks\orchestrator.yml)"
    Write-Host "  -Verbosity <level>    Verbosity level (default: none, supports -v, -vv, -vvv, etc.)"
    Write-Host "  -VaultVars <file>     Path to vault vars file (default: ~\.uniloader\.vault.yml)"
    Write-Host "  -VaultPass <file>     Path to vault password file (default: ~\.uniloader\.vault_pass)"
    Write-Host "  -ExtraVars <vars>     Additional extra vars"
    Write-Host "  -HomeAction <action>  Home role action (encrypt, decrypt, restore). Sets playbook to 'home'."
    Write-Host "  -HomeFiles <files>    Comma-separated list of files for home role action."
    Write-Host "  -Help                 Show this help message"
    exit
}

# Sets paths relative to the script location
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path "$ScriptDir\.."

# Resolve inventory path
if ($Inventory -notmatch "[\\/]") {
    $InventoryPath = Join-Path $ProjectRoot "inventory\$Inventory.yml"
} else {
    $InventoryPath = $Inventory
}

# Resolve playbook path
if ($Playbook -notmatch "[\\/]") {
    if ($Playbook -notmatch "\.yml$") {
        $Playbook = "$Playbook.yml"
    }
    $PlaybookPath = Join-Path $ProjectRoot "playbooks\$Playbook"
} else {
    $PlaybookPath = $Playbook
}

# Check if files exist
if (-not (Test-Path $InventoryPath)) {
    Write-Error "Inventory file '$InventoryPath' not found."
    exit 1
}
if (-not (Test-Path $PlaybookPath)) {
    Write-Error "Playbook file '$PlaybookPath' not found."
    exit 1
}

# Activate Virtual Environment
$VenvInfo = Join-Path $ProjectRoot ".venv\Scripts\Activate.ps1"

if (Test-Path $VenvInfo) {
    . $VenvInfo
} else {
    $SetupScript = Join-Path $ProjectRoot "scripts\setup_venv.ps1"
    if (Test-Path $SetupScript) {
        Write-Host "Virtual environment not found. Attempting to create one..."
        . $SetupScript
    } else {
        Write-Error "Virtual environment not found and setup script missing."
        exit 1
    }
}

    }
}

# Process Home Role arguments if present
if (-not [string]::IsNullOrEmpty($HomeAction)) {
    $PlaybookPath = Join-Path $ProjectRoot "playbooks\home.yml"
    $ExtraVars += "home_action=$HomeAction"
}

if (-not [string]::IsNullOrEmpty($HomeFiles)) {
    # Convert "file1,file2" -> ["file1","file2"]
    $FilesArray = $HomeFiles -split ','
    $JsonStructure = @{ home_files = $FilesArray } | ConvertTo-Json -Compress
    # PowerShell passing JSON via -e needs careful handling, relying on ConvertTo-Json
    $ExtraVars += "$JsonStructure"
}

# Construct arguments list
$AnsibleArgs = @(
    "-i", $InventoryPath,
    $PlaybookPath,
    $Verbosity,
    "-e", $VaultVars,
    "--vault-password-file", $VaultPass
)

foreach ($Var in $ExtraVars) {
    $AnsibleArgs += "-e"
    $AnsibleArgs += $Var
}

Write-Host "Running: ansible-playbook $AnsibleArgs"
Write-Host "----------------------------------------------------------------"

# Execute ansible-playbook
& ansible-playbook $AnsibleArgs
