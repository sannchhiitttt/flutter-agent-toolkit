# Flutter Agent Toolkit

A unified developer toolkit and MCP configuration suite to empower AI coding assistants (such as Antigravity, Cursor, Claude Code, and VS Code) for Flutter, mobile, and full-stack development.

## Overview

Modern AI-assisted engineering requires more than plain chat. It needs:
1. **Persistent Memory**: Retaining project architectural patterns, design decisions, and state conventions across sessions.
2. **Codebase Understanding**: AST-level dependency graphs and blast-radius analysis before refactoring.
3. **Live App Interaction**: Driving running Flutter applications, inspecting widget trees, and verifying UI behavior.
4. **Curated Skills**: Modular domain skills covering Flutter best practices, UI/UX design tokens, and web SEO.

---

## Included Components

### 1. Model Context Protocol (MCP) Servers
- **Dart SDK MCP (`dart mcp-server`)**: Native Dart compiler diagnostics, static analysis, hot reload/restart, and package lookups.
- **Marionette MCP (`marionette_mcp`)**: Real-time Flutter UI driver capable of inspecting widgets, triggering actions (tap, swipe, input), and capturing screenshots.
- **Graphify MCP (`graphify-mcp`)**: Codebase AST parser and dependency graph visualizer for safe refactoring and architecture analysis.
- **EvolveMem Memory Server (`evolvemem-memory`)**: Local SQLite-backed memory engine with full-text search (FTS5) to provide agents with durable context across sessions.

### 2. Specialized Agent Skills
- **Flutter & Dart**: Clean architecture, Riverpod/Bloc patterns, responsive layout construction, widget and integration testing, and automated runtime error resolution.
- **UI/UX & Design**: Systematic spacing, typography, modern Material 3 / Cupertino styling guidelines, and micro-interactions.
- **SEO Suite**: Technical SEO audits, structured data (JSON-LD), meta tag configurations, and crawlability optimization for Flutter Web and web landing pages.

---

## Installation

### Linux & macOS
Run the automated installer from the repository root:
```bash
./install.sh --target /path/to/your/flutter_project
```

Or install skills globally for your user profile:
```bash
./install.sh --global
```

### Windows
Run PowerShell as Administrator or with script execution permitted:
```powershell
.\install.ps1 -Target "C:\path\to\your\flutter_project"
```

---

## Workspace Setup

The installer automatically places configuration files in your target project:
- `.vscode/mcp.json` / `.mcp.json`: Configures the MCP servers for VS Code, Cursor, and compatible agent extensions.
- `.gemini/skills`, `.claude/skills`, `.agents/skills`: Provides modular skill definitions to your coding assistant.

---

## Repository Structure

```
flutter-agent-toolkit/
├── install.sh                  # Linux & macOS automated installer
├── install.ps1                 # Windows PowerShell installer
├── uninstall.sh                # Uninstallation script
├── templates/                  # Ready-to-use MCP configuration files
├── tools/
│   └── evolvemem_mcp/          # SQLite persistent memory MCP server
└── skills/
    ├── flutter/                # Flutter & Dart engineering guidelines
    ├── design/                 # UI/UX design systems & styling skills
    └── seo/                    # Web & Flutter Web SEO optimization skills
```

## License

MIT License. See [LICENSE](LICENSE) for details.
