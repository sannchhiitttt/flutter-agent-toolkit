<div align="center">

# 🚀 Flutter Agent Toolkit
### *The Ultimate AI-Agentic Development Environment & MCP Suite for Flutter*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/sannchhiitttt/flutter-agent-toolkit?style=flat&color=blue)](https://github.com/sannchhiitttt/flutter-agent-toolkit/stargazers)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-blueviolet)](#-quickstart-installation)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![MCP](https://img.shields.io/badge/Protocol-MCP-10B981)](https://modelcontextprotocol.io)

**Supercharge Antigravity, Cursor, Claude Code, and VS Code into an elite Flutter pair-programmer.**

[Features](#-why-this-stack-supercharges-flutter) • [Architecture](#-architecture) • [Quickstart](#-quickstart-installation) • [MCP Servers](#-included-mcp-servers) • [Agent Skills](#-specialized-agent-skills) • [Author & Credits](#-author--credits)

---

</div>

## 🌟 Why This Stack Supercharges Flutter

Traditional coding agents often suffer from **context amnesia**, **blind refactoring**, and **an inability to verify UI changes**. The **Flutter Agent Toolkit** solves this by connecting cognitive memory, structural code intelligence, and live app automation:

| Component | Flutter Superpower | The Pain It Solves |
| :--- | :--- | :--- |
| 🧠 **EvolveMem-Memory** | Retains your state management (Bloc/Riverpod/Signals), theme tokens, API models, and architectural decisions across sessions. | Stops the AI from forgetting project rules and asking repetitive setup questions every conversation. |
| 🕸️ **Graphify AST** | Maps widget hierarchy dependencies, caller trees, and blast radius before touching any file. | Prevents silent regressions and broken provider chains when refactoring complex Flutter widgets. |
| 🎭 **Marionette MCP** | Connects directly to the Dart VM Service to tap buttons, scroll, enter text, and inspect live widget trees. | Enables the AI to visually and functionally test its own Flutter UI code without manual intervention. |
| 🎯 **Dart SDK MCP** | Real-time compiler diagnostics, analyzer errors, hot-reload/restart triggers, and pub package resolution. | Instant feedback on type mismatches, missing imports, and broken constraints. |
| 🎨 **UI/UX Design Skills** | Enforces 8pt grid spacing, micro-interactions, responsive breakpoints, and modern Material 3 / Cupertino styling. | Upgrades generic code into high-polish, production-grade mobile and desktop experiences. |
| 🌐 **SEO Suite** | Audits crawlability, generates JSON-LD schema, meta tags, and OpenGraph headers for **Flutter Web**. | Overcomes the classic SEO challenges of Flutter single-page web applications. |

---

## 🏛️ Architecture

```
                    ┌───────────────────────────────────────────────┐
                    │      AI Agent (Antigravity / Cursor / Claude)  │
                    └───────────────────────┬───────────────────────┘
                                            │
                ┌───────────────────────────┼───────────────────────────┐
                ▼                           ▼                           ▼
   ┌─────────────────────────┐ ┌─────────────────────────┐ ┌─────────────────────────┐
   │    🧠 Cognitive Layer   │ │   ⚡ Execution Layer    │ │   🎨 Domain Guidance    │
   ├─────────────────────────┤ ├─────────────────────────┤ ├─────────────────────────┤
   │ • EvolveMem Memory      │ │ • Dart SDK MCP          │ │ • Flutter & Dart Skills │
   │   (SQLite + FTS5)       │ │ • Marionette UI Driver  │ │ • UI/UX Design System   │
   │ • Graphify AST Graph    │ │ • Hot Reload / Restart  │ │ • Web SEO Suite         │
   └─────────────────────────┘ └─────────────────────────┘ └─────────────────────────┘
```

---

## ⚡ Quickstart Installation

One-click automated setup scripts for **Linux (Fedora, Ubuntu, Debian, Arch)**, **macOS**, and **Windows 10/11**:

### 🐧 Linux & 🍎 macOS

Clone the repository and run the automated installer:

```bash
git clone https://github.com/sannchhiitttt/flutter-agent-toolkit.git
cd flutter-agent-toolkit
chmod +x install.sh
./install.sh --target /path/to/your/flutter_project
```

> **Options:**
> * `--target <dir>`: Sets up MCP configuration and deploys skills directly into your Flutter workspace.
> * `--global`: Installs skills globally into `~/.gemini/skills`, `~/.claude/skills`, and `~/.agents/skills`.

---

### 🪟 Windows (PowerShell)

Open PowerShell as Administrator or ensure script execution is enabled:

```powershell
git clone https://github.com/sannchhiitttt/flutter-agent-toolkit.git
cd flutter-agent-toolkit
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1 -Target "C:\path\to\your\flutter_project"
```

---

## 📦 Included MCP Servers

### 1. 🧠 EvolveMem-Memory
* **What it does**: A lightweight FastMCP server powered by SQLite with full-text search (FTS5).
* **Location**: `tools/evolvemem_mcp/`
* **Tools**:
  * `remember`: Store key decisions, conventions, and state architectures.
  * `search_memory`: Retrieve past decisions using semantic keywords or tags.
  * `recent_memory`: Snapshot of the latest project memory items.
  * `memory_stats`: Health and memory metrics.

### 2. 🎭 Marionette MCP
* **What it does**: Live Flutter app automation tool for agent pair-programming.
* **Capabilities**:
  * Live widget tree exploration (`get_interactive_elements`).
  * User interaction emulation (`tap`, `double_tap`, `swipe`, `scroll_to`, `enter_text`).
  * Visual inspection (`take_screenshots`).
  * Live developer runtime controls (`hot_reload`, `hot_restart`).

### 3. 🕸️ Graphify MCP
* **What it does**: AST knowledge graph generation and dependency impact analyzer.
* **Capabilities**:
  * Explores caller-callee graphs (`query_graph`, `get_node`, `get_neighbors`).
  * Identifies architectural bottlenecks (`god_nodes`).
  * Computes blast radius before refactoring (`get_pr_impact`).

### 4. 🎯 Dart SDK MCP
* **What it does**: Directly invokes the official Dart compiler MCP server built into the Dart/Flutter SDK (`dart mcp-server`).
* **Capabilities**:
  * Instant static analysis and compile error diagnostics.
  * Pub package search and dependency conflict resolution.
  * LSP symbol inspection across project files.

---

## 🎨 Specialized Agent Skills

The toolkit includes curated, battle-tested agent skills referenced in [`skills-lock.json`](skills-lock.json):

* **📱 Flutter Engineering**:
  * `flutter-apply-architecture-best-practices`
  * `flutter-build-responsive-layout`
  * `flutter-add-widget-test` & `flutter-add-integration-test`
  * `flutter-fix-layout-issues`
  * `flutter-setup-declarative-routing`
* **🎯 Dart Excellence**:
  * `dart-run-static-analysis`
  * `dart-fix-runtime-errors`
  * `dart-add-unit-test`
* **🎨 UI/UX & Design**:
  * `ui-ux-pro-max` (Modern design tokens, responsive breakpoints, ergonomics)
  * `frontend-design` & `web-design-guidelines`
  * `taste-skill` & `impeccable`
* **🌐 Web & Flutter Web SEO**:
  * `seo-audit`, `seo-technical`, `seo-schema`, `seo-geo`, and `seo-content`

---

## 📁 Repository Structure

```
flutter-agent-toolkit/
├── install.sh                  # Automated installer for Linux (Fedora/Ubuntu/Arch) & macOS
├── install.ps1                 # Automated installer for Windows PowerShell
├── uninstall.sh                # Clean uninstaller script
├── skills-lock.json            # Curated registry of agent skills
├── templates/                  # Ready-to-use MCP configuration files
│   ├── vscode-mcp.json         # For .vscode/mcp.json in your project
│   ├── mcp.json                # For project root .mcp.json
│   └── claude-desktop-mcp.json # For Claude Desktop integration
└── tools/
    └── evolvemem_mcp/          # FastMCP persistent memory server
        ├── server.py           # FastMCP tool declarations
        ├── storage.py          # SQLite FTS5 database implementation
        └── requirements.txt    # Python dependencies
```

---

## 👤 Author & Credits

### 👨‍💻 Created & Maintained by:
**Sanchit Bhise**
* GitHub: [@sannchhiitttt](https://github.com/sannchhiitttt)

### 🙏 Acknowledgments & Credits:
Special thanks to the open-source communities driving modern agentic development:
* **The Flutter & Dart Team** ([Google](https://flutter.dev)) for the `dart mcp-server` and the Flutter ecosystem.
* **Anthropic** for pioneering the [Model Context Protocol (MCP)](https://modelcontextprotocol.io).
* The creators of **Marionette MCP** for Flutter UI automation.
* The creators of **Graphify** for AST code knowledge graphing.
* The open-source AI community for curated agent skill patterns.

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

<div align="center">
  <sub>Built with ❤️ for Flutter developers building the future of agentic engineering.</sub>
</div>
