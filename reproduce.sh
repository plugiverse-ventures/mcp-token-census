#!/usr/bin/env bash
# Reproduce the MCP Token Census. Needs Python 3.10+, Node 20+, uv.
set -euo pipefail
python3 -m venv .venv && . .venv/bin/activate && pip install -q "toolism[mcp,verify]==0.2.0"
mkdir -p data
while IFS='|' read -r name cmd; do
  toolism measure --mcp "$cmd" -f json -o "data/$name.measure.json"
  toolism slim --mcp "$cmd" --verify -q -r json --report-file "data/$name.slim.json" -o /dev/null
done < servers.txt
