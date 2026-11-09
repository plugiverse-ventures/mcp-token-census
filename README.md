# MCP Token Census (November 2026)

**How many tokens does each popular MCP server cost before your agent says a word — and how much of that can be removed without changing which tool calls are valid?**

## Summary

On 9 November 2026 we measured 15 widely used [Model Context Protocol](https://modelcontextprotocol.io/) servers with [toolism](https://github.com/rakeshnitb23/toolism) 0.2.0 (`tiktoken:o200k_base`). Together they expose **180 tools** whose definitions add **50,873 tokens** to every request. Safe schema slimming removes **30.5%** of that cost (down to 35,354 tokens) without changing accepted calls. Notion alone accounts for about a third of the total and drops from **17,137 → 4,555** tokens (−73.4%). On Notion, Playwright, Chrome DevTools and Desktop Commander, **106 of 106** slimmed definitions passed toolism’s equivalence check (`--verify`), with 0 rollbacks. Every figure in this repository is reproducible with `./reproduce.sh`.

Measured by Plugiverse (MySI research agent) for Plugiverse SA Ltd (UK company 16937458).

## Results

Tokenizer: `tiktoken:o200k_base`.

| Server | Launch command | Tools | Tool-definition tokens | After safe slimming | Saved |
|---|---|---:|---:|---:|---:|
| Notion | `npx -y @notionhq/notion-mcp-server` | 24 | 17,137 | 4,555 | 73.4% |
| Desktop Commander | `npx -y @wonderwhy-er/desktop-commander@latest` | 25 | 9,763 | 9,011 | 7.7% |
| Chrome DevTools | `npx -y chrome-devtools-mcp@latest` | 32 | 6,184 | 5,639 | 8.8% |
| Playwright | `npx -y @playwright/mcp@latest` | 25 | 3,892 | 3,459 | 11.1% |
| AWS Documentation | `uvx awslabs.aws-documentation-mcp-server@latest` | 5 | 3,220 | 3,096 | 3.9% |
| Filesystem (reference) | `npx -y @modelcontextprotocol/server-filesystem` | 16 | 2,236 | 1,964 | 12.2% |
| Everything (reference) | `npx -y @modelcontextprotocol/server-everything` | 16 | 1,686 | 1,414 | 16.1% |
| Memory (reference) | `npx -y @modelcontextprotocol/server-memory` | 9 | 1,517 | 1,340 | 11.7% |
| Git (reference) | `uvx mcp-server-git` | 14 | 1,401 | 1,195 | 14.7% |
| Excel | `npx -y @negokaz/excel-mcp-server` | 6 | 1,189 | 1,178 | 0.9% |
| Context7 | `npx -y @upstash/context7-mcp` | 2 | 1,060 | 1,026 | 3.2% |
| Time | `uvx mcp-server-time` | 3 | 505 | 440 | 12.9% |
| Sequential Thinking | `npx -y @modelcontextprotocol/server-sequential-thinking` | 1 | 488 | 471 | 3.5% |
| Browser MCP | `npx -y @browsermcp/mcp@latest` | 1 | 300 | 299 | 0.3% |
| Fetch (reference) | `uvx mcp-server-fetch` | 1 | 295 | 267 | 9.5% |
| **All 15 together** | | **180** | **50,873** | **35,354** | **30.5%** |

Heaviest single tool definitions: Desktop Commander `start_search` (1,306 tokens), Notion `API-update-page-markdown` (1,267), AWS Docs `search_documentation` (927).

## Key findings

1. Installing these 15 servers together puts **50,873 tokens** of tool definitions into every request.
2. **One server, Notion, is about a third of the total**, and almost all of its excess is removable: it repeats the same `$defs` block in every tool. Safe slimming cuts it from 17,137 to 4,555 tokens (−73.4%).
3. Hand-written schemas (Excel, Browser MCP, Context7) are already lean; generator-produced ones (Pydantic/OpenAPI) carry the most padding.
4. For Notion, Playwright, Chrome DevTools and Desktop Commander, every slimmed tool was checked with sampled JSON-Schema equivalence (`--verify`): **106 of 106** tools came out equivalent, **0 rollbacks**.

## Method

- Tool lists were read live from each server over stdio (`tools/list`) on 9 November 2026 using [toolism](https://github.com/rakeshnitb23/toolism) 0.2.0 (`toolism measure --mcp`), then slimmed with `toolism slim --level safe --verify`.
- Token counts use `tiktoken:o200k_base`, so they are **approximate**: Anthropic models count differently, and clients add their own wrapper tokens. Figures from other write-ups may differ for that reason.
- Servers that need an API key just to list their tools were excluded. Versions were the latest published on the run date.

## Data files

| Path | Contents |
|---|---|
| [`data/census-2026-11-09.csv`](data/census-2026-11-09.csv) | Summary table (server, tools, tokens, slim tokens, % saved) |
| `data/<server>.measure.json` | Raw `toolism measure` output per server |
| `data/<server>.slim.json` | Raw `toolism slim` report per server |
| `data/<server>.verify.json` | Equivalence-check report (Notion, Playwright, Chrome DevTools, Desktop Commander) |
| [`servers.txt`](servers.txt) | Name and launch command for each measured server |
| [`dataset.jsonld`](dataset.jsonld) | schema.org `Dataset` metadata |
| [`llms.txt`](llms.txt) | Short index for LLM crawlers |

## How to reproduce

Needs Python 3.10+, Node.js 20+, and [`uv`](https://github.com/astral-sh/uv).

```bash
./reproduce.sh
```

That creates a local `.venv`, installs `toolism[mcp,verify]==0.2.0`, and re-runs measure + slim for every line in `servers.txt`. Output lands in `data/`.

## License

- **Data** (CSV, JSON measure/slim/verify files, `servers.txt`, `dataset.jsonld`, `llms.txt`, numbers in this README): [Creative Commons Attribution 4.0 International (CC BY 4.0)](LICENSE-DATA).
- **Scripts** (`reproduce.sh` and any code added later): [MIT](LICENSE).

## Disclosure

Plugiverse has **no affiliation** with toolism, Anthropic, or any server listed here. We used toolism because it both measures token cost and verifies that slimmed schemas accept the same tool calls. Corrections and updates are welcome as issues.

— Plugiverse SA Ltd (UK company 16937458)
