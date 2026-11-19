# ==============================================================================
# Flutter Agent Toolkit — Cross-Platform Installer (Windows PowerShell)
# Installs MCP Servers (EvolveMem, Graphify, Marionette, Dart) & Agent Skills
# ==============================================================================

[CmdletBinding()]
param (
    [string]$Target = (Get-Location).Path,
    [switch]$Global,
    [switch]$Yes
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n[STEP] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

Write-Host @"
╔════════════════════════════════════════════════════════════════════╗
║                   FLUTTER AGENT TOOLKIT                            ║
║        AI-Agentic MCP Servers & Skills for Supercharged Flutter    ║
╚════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. Prerequisites Check
Write-Step "Checking prerequisites on Windows..."

# Check Python
$PythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $PythonCmd) {
    $PythonCmd = Get-Command py -ErrorAction SilentlyContinue
}
if (-not $PythonCmd) {
    Write-Err "Python is not found in PATH. Please install Python 3.10+ from python.org or via 'winget install Python.Python.3.12'."
    exit 1
}
$PythonPath = $PythonCmd.Source
Write-Success "Found Python at: $PythonPath"

# Check Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Err "Git is not installed. Please install Git via 'winget install Git.Git'."
    exit 1
}
Write-Success "Found Git."

# Check Dart / Flutter
$DartCmd = Get-Command dart -ErrorAction SilentlyContinue
if (-not $DartCmd) {
    $FlutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($FlutterCmd) {
        $DartPath = Join-Path (Split-Path -Parent $FlutterCmd.Source) "dart.bat"
    } else {
        Write-Warn "Neither 'dart' nor 'flutter' was found in PATH."
        Write-Warn "Please install Flutter SDK and add it to your System PATH."
    }
} else {
    Write-Success "Found Dart SDK."
}

# Check or install Astral 'uv'
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Step "Installing uv (fast Python package manager)..."
    try {
        Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
        $env:Path = "$env:USERPROFILE\.cargo\bin;$env:Path"
    } catch {
        Write-Warn "Could not install uv automatically. Falling back to standard pip."
    }
}

# 2. Install MCP Servers
Write-Step "Installing MCP Servers..."

# Marionette MCP (Flutter UI Automation)
if (Get-Command dart -ErrorAction SilentlyContinue) {
    Write-Host "Activating marionette_mcp via dart pub..."
    dart pub global activate marionette_mcp
    $PubBin = Join-Path $env:LOCALAPPDATA "Pub\Cache\bin"
    if ($env:Path -notlike "*$PubBin*") {
        $env:Path = "$PubBin;$env:Path"
    }
    Write-Success "marionette_mcp installed."
} else {
    Write-Warn "Skipping marionette_mcp installation (dart not found in PATH)."
}

# Graphify MCP (AST Knowledge Graph)
Write-Host "Installing graphify MCP server..."
if (Get-Command uv -ErrorAction SilentlyContinue) {
    uv tool install --force graphifyy
} else {
    & $PythonPath -m pip install --user graphifyy
}
Write-Success "graphify-mcp installed."

# EvolveMem MCP (Persistent Memory)
Write-Host "Configuring EvolveMem MCP server..."
$EvolveMemDir = Join-Path $env:USERPROFILE ".evolvemem"
if (-not (Test-Path $EvolveMemDir)) {
    New-Item -ItemType Directory -Path $EvolveMemDir -Force | Out-Null
}

$VenvDir = Join-Path $EvolveMemDir "venv"
if (-not (Test-Path $VenvDir)) {
    Write-Host "Creating Python virtual environment at $VenvDir..."
    & $PythonPath -m venv $VenvDir
}

$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$VenvPip = Join-Path $VenvDir "Scripts\pip.exe"

& $VenvPip install --quiet --upgrade pip
$ReqFile = Join-Path $ScriptDir "tools\evolvemem_mcp\requirements.txt"
& $VenvPip install --quiet -r $ReqFile

$MemDbPath = Join-Path $EvolveMemDir "memories.sqlite3"
$ServerPy = Join-Path $ScriptDir "tools\evolvemem_mcp\server.py"

# Create run_evolvemem.cmd batch wrapper
$CmdWrapper = Join-Path $ScriptDir "tools\evolvemem_mcp\run_evolvemem.cmd"
"@echo off`n`"$VenvPython`" `"$ServerPy`" --db `"$MemDbPath`" %*" | Out-File -FilePath $CmdWrapper -Encoding ascii

Write-Success "EvolveMem configured with SQLite database at $MemDbPath"

# 3. Deploy Skills
Write-Step "Deploying Agent Skills..."
$TargetDirs = @()
if ($Global) {
    $TargetDirs += (Join-Path $env:USERPROFILE ".gemini\skills")
    $TargetDirs += (Join-Path $env:USERPROFILE ".claude\skills")
    $TargetDirs += (Join-Path $env:USERPROFILE ".agents\skills")
} else {
    $TargetDirs += (Join-Path $Target ".gemini\skills")
    $TargetDirs += (Join-Path $Target ".claude\skills")
    $TargetDirs += (Join-Path $Target ".agents\skills")
}

foreach ($dest in $TargetDirs) {
    if (-not (Test-Path $dest)) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
    }
    # Copy Flutter skills
    $FlutterSkills = Join-Path $ScriptDir "skills\flutter\*"
    if (Test-Path (Join-Path $ScriptDir "skills\flutter")) {
        Copy-Item -Path $FlutterSkills -Destination $dest -Recurse -Force
    }
    # Copy Design skills
    $DesignSkills = Join-Path $ScriptDir "skills\design\*"
    if (Test-Path (Join-Path $ScriptDir "skills\design")) {
        Copy-Item -Path $DesignSkills -Destination $dest -Recurse -Force
    }
    # Copy SEO skills
    $SeoSkills = Join-Path $ScriptDir "skills\seo\*"
    if (Test-Path (Join-Path $ScriptDir "skills\seo")) {
        Copy-Item -Path $SeoSkills -Destination $dest -Recurse -Force
    }
}
Write-Success "Skills successfully copied to target environments."

# 4. Generate MCP Configuration
Write-Step "Generating MCP configuration files..."
$VsCodeDir = Join-Path $Target ".vscode"
if (-not (Test-Path $VsCodeDir)) {
    New-Item -ItemType Directory -Path $VsCodeDir -Force | Out-Null
}

$VenvPythonJson = $VenvPython.Replace("\", "/")
$ServerPyJson = $ServerPy.Replace("\", "/")
$MemDbJson = $MemDbPath.Replace("\", "/")

$McpJsonContent = @"
{
  "mcpServers": {
    "dart-mcp-server": {
      "command": "dart",
      "args": ["mcp-server"],
      "cwd": "`${workspaceFolder}"
    },
    "marionette_mcp": {
      "command": "marionette_mcp",
      "args": [],
      "cwd": "`${workspaceFolder}"
    },
    "graphify": {
      "command": "graphify-mcp",
      "args": [
        "--graph",
        "`${workspaceFolder}/.graphify_ast.json"
      ],
      "cwd": "`${workspaceFolder}"
    },
    "evolvemem-memory": {
      "command": "$VenvPythonJson",
      "args": [
        "$ServerPyJson",
        "--db",
        "$MemDbJson"
      ],
      "cwd": "`${workspaceFolder}"
    }
  }
}
"@

$VsCodeMcpPath = Join-Path $VsCodeDir "mcp.json"
$RootMcpPath = Join-Path $Target ".mcp.json"

$McpJsonContent | Out-File -FilePath $VsCodeMcpPath -Encoding utf8
$McpJsonContent | Out-File -FilePath $RootMcpPath -Encoding utf8

Write-Success "Generated MCP configs at:"
Write-Host "  - $VsCodeMcpPath"
Write-Host "  - $RootMcpPath"

Write-Host @"

════════════════════════════════════════════════════════════════════
🎉 Installation Complete! Flutter Agent Toolkit is Ready on Windows! 🎉
════════════════════════════════════════════════════════════════════

Next Steps:
  1. Open your project in VS Code, Cursor, or Antigravity.
  2. Launch your Flutter app and let your AI agent write, test, and refactor!
"@ -ForegroundColor Green
