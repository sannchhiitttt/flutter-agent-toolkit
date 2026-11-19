from __future__ import annotations

import json
import os
import re
import sqlite3
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def normalize_tags(tags: list[str] | None) -> list[str]:
    if not tags:
        return []
    cleaned = []
    for tag in tags:
        value = tag.strip()
        if value:
            cleaned.append(value)
    return cleaned


def get_current_project(cwd: str | Path | None = None) -> str:
    """Auto-detect the active project/repository name."""
    env_proj = os.environ.get("EVOLVEMEM_PROJECT", "").strip()
    if env_proj:
        return env_proj

    work_dir = Path(cwd) if cwd else Path.cwd()
    try:
        res = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=work_dir,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=2,
        )
        if res.returncode == 0 and res.stdout.strip():
            return Path(res.stdout.strip()).name
    except Exception:
        pass

    return work_dir.name or "default"


class MemoryStore:
    def __init__(self, db_path: str | Path):
        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._fts_enabled = False
        self._initialize()

    def _connect(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def _initialize(self) -> None:
        with self._connect() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS memories (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    kind TEXT NOT NULL DEFAULT 'note',
                    title TEXT NOT NULL DEFAULT '',
                    content TEXT NOT NULL,
                    tags TEXT NOT NULL DEFAULT '[]',
                    source TEXT NOT NULL DEFAULT '',
                    importance INTEGER NOT NULL DEFAULT 3,
                    project TEXT NOT NULL DEFAULT '',
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                )
                """
            )

            # Ensure 'project' column exists (migration for existing DBs)
            cursor = conn.execute("PRAGMA table_info(memories)")
            columns = [row["name"] for row in cursor.fetchall()]
            if "project" not in columns:
                conn.execute("ALTER TABLE memories ADD COLUMN project TEXT NOT NULL DEFAULT ''")

            # Setup FTS
            try:
                # Check if memories_fts exists and has project column
                cursor = conn.execute(
                    "SELECT sql FROM sqlite_master WHERE type='table' AND name='memories_fts'"
                )
                fts_row = cursor.fetchone()
                if fts_row:
                    if "project" not in fts_row["sql"]:
                        conn.execute("DROP TABLE memories_fts")
                        self._create_and_populate_fts(conn)
                    else:
                        self._fts_enabled = True
                else:
                    self._create_and_populate_fts(conn)
            except sqlite3.OperationalError:
                self._fts_enabled = False

    def _create_and_populate_fts(self, conn: sqlite3.Connection) -> None:
        try:
            conn.execute(
                """
                CREATE VIRTUAL TABLE IF NOT EXISTS memories_fts
                USING fts5(title, content, tags, source, project, memory_id UNINDEXED)
                """
            )
            # Populate existing
            conn.execute(
                """
                INSERT INTO memories_fts (rowid, title, content, tags, source, project, memory_id)
                SELECT id, title, content, tags, source, project, id FROM memories
                """
            )
            self._fts_enabled = True
        except sqlite3.OperationalError:
            self._fts_enabled = False

    def remember(
        self,
        *,
        content: str,
        title: str = "",
        kind: str = "note",
        tags: list[str] | None = None,
        source: str = "",
        importance: int = 3,
        project: str = "",
    ) -> dict[str, Any]:
        tags = normalize_tags(tags)
        now = utc_now()
        title = title.strip()
        kind = kind.strip() or "note"
        source = source.strip()
        content = content.strip()
        project = project.strip() if project else get_current_project()

        with self._connect() as conn:
            cursor = conn.execute(
                """
                INSERT INTO memories (kind, title, content, tags, source, importance, project, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    kind,
                    title,
                    content,
                    json.dumps(tags, ensure_ascii=False),
                    source,
                    max(1, min(int(importance), 5)),
                    project,
                    now,
                    now,
                ),
            )
            memory_id = int(cursor.lastrowid)

            if self._fts_enabled:
                conn.execute(
                    """
                    INSERT INTO memories_fts (rowid, title, content, tags, source, project, memory_id)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    (memory_id, title, content, ", ".join(tags), source, project, memory_id),
                )

        return self.get(memory_id)  # type: ignore[return-value]

    def get(self, memory_id: int) -> dict[str, Any] | None:
        with self._connect() as conn:
            row = conn.execute(
                "SELECT * FROM memories WHERE id = ?",
                (int(memory_id),),
            ).fetchone()
        return self._row_to_dict(row) if row else None

    def list_projects(self) -> list[dict[str, Any]]:
        """List all distinct projects with their memory count."""
        with self._connect() as conn:
            rows = conn.execute(
                """
                SELECT project, count(*) as count, max(updated_at) as last_updated
                FROM memories
                GROUP BY project
                ORDER BY last_updated DESC
                """
            ).fetchall()
        return [
            {
                "project": row["project"] or "(unspecified)",
                "count": row["count"],
                "last_updated": row["last_updated"],
            }
            for row in rows
        ]

    def recent(
        self,
        limit: int = 10,
        kind: str | None = None,
        project: str | None = None,
        all_projects: bool = False,
    ) -> list[dict[str, Any]]:
        limit = max(1, min(int(limit), 100))
        query = "SELECT * FROM memories"
        conditions: list[str] = []
        params: list[Any] = []

        if kind:
            conditions.append("kind = ?")
            params.append(kind.strip())

        target_project = project.strip() if project else (None if all_projects else get_current_project())
        if target_project and target_project != "*":
            conditions.append("project = ?")
            params.append(target_project)

        if conditions:
            query += " WHERE " + " AND ".join(conditions)

        query += " ORDER BY updated_at DESC, id DESC LIMIT ?"
        params.append(limit)

        with self._connect() as conn:
            rows = conn.execute(query, params).fetchall()

        # If filtered by project and got 0 results, check if all_projects gives results
        if not rows and target_project and target_project != "*" and not all_projects:
            # Fallback to recent across all projects
            return self.recent(limit=limit, kind=kind, all_projects=True)

        return [self._row_to_dict(row) for row in rows]

    def search(
        self,
        query: str,
        limit: int = 10,
        kind: str | None = None,
        project: str | None = None,
        all_projects: bool = False,
    ) -> list[dict[str, Any]]:
        limit = max(1, min(int(limit), 50))
        query = query.strip()
        if not query:
            return self.recent(limit=limit, kind=kind, project=project, all_projects=all_projects)

        target_project = project.strip() if project else (None if all_projects else get_current_project())
        if target_project == "*":
            target_project = None

        if self._fts_enabled:
            try:
                results = self._search_fts(query, limit=limit, kind=kind, project=target_project)
                if not results and target_project:
                    # Fallback to search all projects if project-scoped search had no hits
                    results = self._search_fts(query, limit=limit, kind=kind, project=None)
                return results
            except sqlite3.OperationalError:
                pass

        results = self._search_like(query, limit=limit, kind=kind, project=target_project)
        if not results and target_project:
            results = self._search_like(query, limit=limit, kind=kind, project=None)
        return results

    def delete(self, memory_id: int) -> bool:
        with self._connect() as conn:
            row = conn.execute(
                "SELECT id FROM memories WHERE id = ?",
                (int(memory_id),),
            ).fetchone()
            if not row:
                return False

            conn.execute("DELETE FROM memories WHERE id = ?", (int(memory_id),))
            if self._fts_enabled:
                conn.execute("DELETE FROM memories_fts WHERE memory_id = ?", (int(memory_id),))
        return True

    def _search_fts(
        self,
        query: str,
        *,
        limit: int,
        kind: str | None,
        project: str | None,
    ) -> list[dict[str, Any]]:
        fts_query = self._build_fts_query(query)
        sql = """
            SELECT m.*,
                   bm25(memories_fts) AS score
            FROM memories_fts
            JOIN memories m ON m.id = memories_fts.memory_id
            WHERE memories_fts MATCH ?
        """
        params: list[Any] = [fts_query]
        if kind:
            sql += " AND m.kind = ?"
            params.append(kind.strip())
        if project:
            sql += " AND m.project = ?"
            params.append(project)

        sql += " ORDER BY score ASC, m.updated_at DESC, m.id DESC LIMIT ?"
        params.append(limit)

        with self._connect() as conn:
            rows = conn.execute(sql, params).fetchall()
        return [self._row_to_dict(row) for row in rows]

    def _search_like(
        self,
        query: str,
        *,
        limit: int,
        kind: str | None,
        project: str | None,
    ) -> list[dict[str, Any]]:
        like = f"%{query.lower()}%"
        sql = """
            SELECT *
            FROM memories
            WHERE (lower(title) LIKE ?
               OR lower(content) LIKE ?
               OR lower(tags) LIKE ?
               OR lower(source) LIKE ?
               OR lower(project) LIKE ?)
        """
        params: list[Any] = [like, like, like, like, like]
        if kind:
            sql += " AND kind = ?"
            params.append(kind.strip())
        if project:
            sql += " AND project = ?"
            params.append(project)

        sql += " ORDER BY updated_at DESC, id DESC LIMIT ?"
        params.append(limit)

        with self._connect() as conn:
            rows = conn.execute(sql, params).fetchall()
        return [self._row_to_dict(row) for row in rows]

    def _build_fts_query(self, query: str) -> str:
        tokens = re.findall(r"[A-Za-z0-9_\-]+", query)
        if not tokens:
            return '""'
        return " AND ".join(f"{token}*" for token in tokens[:8])

    def _row_to_dict(self, row: sqlite3.Row) -> dict[str, Any]:
        tags = []
        try:
            parsed = json.loads(row["tags"] or "[]")
            if isinstance(parsed, list):
                tags = [str(item) for item in parsed]
        except json.JSONDecodeError:
            tags = []

        return {
            "id": int(row["id"]),
            "kind": row["kind"],
            "title": row["title"],
            "content": row["content"],
            "tags": tags,
            "source": row["source"],
            "importance": int(row["importance"]),
            "project": row["project"] if "project" in row.keys() else "",
            "created_at": row["created_at"],
            "updated_at": row["updated_at"],
        }
