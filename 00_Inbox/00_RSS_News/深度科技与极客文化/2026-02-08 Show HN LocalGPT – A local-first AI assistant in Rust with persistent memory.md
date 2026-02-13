# Show HN: LocalGPT – A local-first AI assistant in Rust with persistent memory

**Author:** yi_wang
**Published:** Sun, 08 Feb 2026 01:26:38 +0000
**Link:** https://github.com/localgpt-app/localgpt
**GUID:** https://news.ycombinator.com/item?id=46930391
**Tags:** 

---

## Summary

I built LocalGPT over 4 nights as a Rust reimagining of the OpenClaw assistant pattern (markdown-based persistent memory, autonomous heartbeat tasks, skills system).
It compiles to a single ~27MB binary — no Node.js, Docker, or Python required.
Key features:
- Persistent memory via markdown files (MEMORY, HEARTBEAT, SOUL markdown files) — compatible with OpenClaw's format
- Full-text search (SQLite FTS5) + semantic search (local embeddings, no API key needed)
- Autonomous heartbeat runner that checks tasks on a configurable interval
- CLI + web interface + desktop GUI
- Multi-provider: Anthropic, OpenAI, Ollama etc
- Apache 2.0
Install: `cargo install localgpt`
I use it daily as a knowledge accumulator, research assistant, and autonomous task runner for my side projects. The memory compounds — every session makes the next one better.
GitHub: https://github.com/localgpt-app/localgpt
Website: https://localgpt.app
Would love feedback on the architecture or feature ideas.
Comments URL: https://news.ycombinator.com/item?id=46930391
Points: 228
# Comments: 91

---

## Content


<p>I built LocalGPT over 4 nights as a Rust reimagining of the OpenClaw assistant pattern (markdown-based persistent memory, autonomous heartbeat tasks, skills system).<p>It compiles to a single ~27MB binary — no Node.js, Docker, or Python required.<p>Key features:<p>- Persistent memory via markdown files (MEMORY, HEARTBEAT, SOUL markdown files) — compatible with OpenClaw's format
- Full-text search (SQLite FTS5) + semantic search (local embeddings, no API key needed)
- Autonomous heartbeat runner that checks tasks on a configurable interval
- CLI + web interface + desktop GUI
- Multi-provider: Anthropic, OpenAI, Ollama etc
- Apache 2.0<p>Install: `cargo install localgpt`<p>I use it daily as a knowledge accumulator, research assistant, and autonomous task runner for my side projects. The memory compounds — every session makes the next one better.<p>GitHub: <a href="https://github.com/localgpt-app/localgpt" rel="nofollow">https://github.com/localgpt-app/localgpt</a>
Website: <a href="https://localgpt.app" rel="nofollow">https://localgpt.app</a><p>Would love feedback on the architecture or feature ideas.</p>
<hr>
<p>Comments URL: <a href="https://news.ycombinator.com/item?id=46930391">https://news.ycombinator.com/item?id=46930391</a></p>
<p>Points: 228</p>
<p># Comments: 91</p>


---

**ISO Date:** 2026-02-08T01:26:38.000Z