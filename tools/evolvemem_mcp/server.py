from __future__ import annotations

import argparse
import os
from pathlib import Path
from typing import Any

from mcp.server.fastmcp import FastMCP
from storage import MemoryStore, get_current_project

DEFAULT_DB = Path(
    os.environ.get("EVOLVEMEM_DB", str(Path.home() / ".evolvemem" / "memories.sqlite3"))
)
store = MemoryStore(DEFAULT_DB)
mcp = FastMCP("evolvemem-memory")


@mcp.tool()
def remember(
    content: str,
    title: str = "",
    kind: str = "note",
    tags: list[str] | None = None,
    source: str = "",
    importance: int = 3,
    project: str = "",
) -> dict[str, Any]:
    """Store a durable memory item for later retrieval. Supports project scoping across multiple workspaces."""
    return store.remember(
        content=content,
        title=title,
        kind=kind,
        tags=tags,
        source=source,
        importance=importance,
        project=project,
    )


@mcp.tool()
def search_memory(
    query: str,
    limit: int = 10,
    kind: str = "",
    project: str = "",
    all_projects: bool = False,
) -> dict[str, Any]:
    """Search stored memories by keywords, title, tags, source, or project across workspaces."""
    results = store.search(
        query=query,
        limit=limit,
        kind=kind or None,
        project=project or None,
        all_projects=all_projects,
    )
    active_proj = project or (None if all_projects else get_current_project())
    return {
        "query": query,
        "active_project": active_proj,
        "all_projects": all_projects,
        "count": len(results),
        "results": results,
    }


@mcp.tool()
def recent_memory(
    limit: int = 10,
    kind: str = "",
    project: str = "",
    all_projects: bool = False,
) -> dict[str, Any]:
    """List the most recently updated memories for current project or across all projects."""
    results = store.recent(
        limit=limit,
        kind=kind or None,
        project=project or None,
        all_projects=all_projects,
    )
    active_proj = project or (None if all_projects else get_current_project())
    return {
        "active_project": active_proj,
        "all_projects": all_projects,
        "count": len(results),
        "results": results,
    }


@mcp.tool()
def get_memory(memory_id: int) -> dict[str, Any]:
    """Fetch a single memory item by its numeric ID."""
    result = store.get(memory_id)
    if result is None:
        return {"found": False, "memory_id": memory_id}
    return {"found": True, "memory": result}


@mcp.tool()
def forget_memory(memory_id: int) -> dict[str, Any]:
    """Delete a stored memory item by ID."""
    deleted = store.delete(memory_id)
    return {"deleted": deleted, "memory_id": memory_id}


@mcp.tool()
def list_projects() -> dict[str, Any]:
    """List all distinct projects that have stored memories and their counts."""
    projects = store.list_projects()
    return {
        "current_project": get_current_project(),
        "total_projects": len(projects),
        "projects": projects,
    }


@mcp.tool()
def memory_stats(project: str = "") -> dict[str, Any]:
    """Return health, inventory snapshot, and multi-project statistics."""
    current_proj = project or get_current_project()
    recent = store.recent(limit=5, project=current_proj)
    projects = store.list_projects()
    return {
        "database": str(store.db_path),
        "fts_enabled": store._fts_enabled,
        "current_project": current_proj,
        "projects_overview": projects,
        "recent_count": len(recent),
        "recent": recent,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="EvolveMem-compatible MCP multi-project memory server"
    )
    parser.add_argument(
        "--db",
        default=str(DEFAULT_DB),
        help="Path to the SQLite database file",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    db_path = Path(args.db)

    global store
    store = MemoryStore(db_path)

    mcp.run(transport="stdio")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
