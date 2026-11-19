# EvolveMem-compatible MCP memory server

This folder contains a minimal MCP server that provides persistent memory tools for VS Code agent mode.

## Tools

- `remember` — store a durable note, decision, or constraint
- `search_memory` — search by keywords, tags, or source
- `recent_memory` — list the most recent entries
- `get_memory` — retrieve one item by ID
- `forget_memory` — delete one item by ID
- `memory_stats` — quick health check and recent snapshot

## Run locally

From the repo root:

```bash
python3 tools/evolvemem_mcp/server.py --db ~/.evolvemem/memories.sqlite3
```

## Recommended VS Code user MCP entry

Add this to your VS Code user `mcp.json`:

```json
{
  "mcpServers": {
    "evolvemem-memory": {
      "command": "python3",
      "args": ["/home/sanchitbhise/Projects/vamika/tools/evolvemem_mcp/server.py", "--db", "/home/sanchitbhise/.evolvemem/memories.sqlite3"],
      "type": "stdio"
    }
  }
}
```

## Notes

- The server uses SQLite for persistence and FTS5 when available.
- This is a practical long-term memory layer for VS Code agents.
- You can later swap the storage layer for a deeper EvolveMem integration without changing the MCP tool shape.
