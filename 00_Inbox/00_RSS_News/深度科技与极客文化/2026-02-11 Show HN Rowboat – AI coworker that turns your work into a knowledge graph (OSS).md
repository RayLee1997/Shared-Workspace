# Show HN: Rowboat – AI coworker that turns your work into a knowledge graph (OSS)

**Author:** segmenta
**Published:** Tue, 10 Feb 2026 16:47:29 +0000
**Link:** https://github.com/rowboatlabs/rowboat
**GUID:** https://news.ycombinator.com/item?id=46962641
**Tags:** 

---

## Summary

Hi HN,
AI agents that can run tools on your machine are powerful for knowledge work, but they’re only as useful as the context they have. Rowboat is an open-source, local-first app that turns your work into a living knowledge graph (stored as plain Markdown with backlinks) and uses it to accomplish tasks on your computer.
For example, you can say "Build me a deck about our next quarter roadmap." Rowboat pulls priorities and commitments from your graph, loads a presentation skill, and exports a PDF.
Our repo is https://github.com/rowboatlabs/rowboat, and there’s a demo video here: https://www.youtube.com/watch?v=5AWoGo-L16I
Rowboat has two parts:
(1) A living context graph: Rowboat connects to sources like Gmail and meeting notes like Granola and Fireflies, extracts decisions, commitments, deadlines, and relationships, and writes them locally as linked and editable Markdown files (Obsidian-style), organized around people, projects, and topics. As new conversations happen (including voice memos), related notes update automatically. If a deadline changes in a standup, it links back to the original commitment and updates it.
(2) A local assistant: On top of that graph, Rowboat includes an agent with local shell access and MCP support, so it can use your existing context to actually do work on your machine. It can act on demand or run scheduled background tasks. Example: “Prep me for my meeting with John and create a short voice brief.” It pulls relevant context from your graph and can generate an audio note via an MCP tool like ElevenLabs.
Why not just search transcripts? Passing gigabytes of email, docs, and calls directly to an AI agent is slow and lossy. And search only answers the questions you think to ask. A system that accumulates context over time can track decisions, commitments, and relationships across conversations, and surface patterns you didn't know to look for.
Rowboat is Apache-2.0 licensed, works with any LLM (including local ones), and stores all data locally as Markdown you can read, edit, or delete at any time.
Our previous startup was acquired by Coinbase, where part of my work involved graph neural networks. We're excited to be working with graph-based systems again. Work memory feels like the missing layer for agents.
We’d love to hear your thoughts and welcome contributions!
Comments URL: https://news.ycombinator.com/item?id=46962641
Points: 19
# Comments: 5

---

## Content


<p>Hi HN,<p>AI agents that can run tools on your machine are powerful for knowledge work, but they’re only as useful as the context they have. Rowboat is an open-source, local-first app that turns your work into a living knowledge graph (stored as plain Markdown with backlinks) and uses it to accomplish tasks on your computer.<p>For example, you can say "Build me a deck about our next quarter roadmap." Rowboat pulls priorities and commitments from your graph, loads a presentation skill, and exports a PDF.<p>Our repo is <a href="https://github.com/rowboatlabs/rowboat" rel="nofollow">https://github.com/rowboatlabs/rowboat</a>, and there’s a demo video here: <a href="https://www.youtube.com/watch?v=5AWoGo-L16I" rel="nofollow">https://www.youtube.com/watch?v=5AWoGo-L16I</a><p>Rowboat has two parts:<p>(1) A living context graph: Rowboat connects to sources like Gmail and meeting notes like Granola and Fireflies, extracts decisions, commitments, deadlines, and relationships, and writes them locally as linked and editable Markdown files (Obsidian-style), organized around people, projects, and topics. As new conversations happen (including voice memos), related notes update automatically. If a deadline changes in a standup, it links back to the original commitment and updates it.<p>(2) A local assistant: On top of that graph, Rowboat includes an agent with local shell access and MCP support, so it can use your existing context to actually do work on your machine. It can act on demand or run scheduled background tasks. Example: “Prep me for my meeting with John and create a short voice brief.” It pulls relevant context from your graph and can generate an audio note via an MCP tool like ElevenLabs.<p>Why not just search transcripts? Passing gigabytes of email, docs, and calls directly to an AI agent is slow and lossy. And search only answers the questions you think to ask. A system that accumulates context over time can track decisions, commitments, and relationships across conversations, and surface patterns you didn't know to look for.<p>Rowboat is Apache-2.0 licensed, works with any LLM (including local ones), and stores all data locally as Markdown you can read, edit, or delete at any time.<p>Our previous startup was acquired by Coinbase, where part of my work involved graph neural networks. We're excited to be working with graph-based systems again. Work memory feels like the missing layer for agents.<p>We’d love to hear your thoughts and welcome contributions!</p>
<hr>
<p>Comments URL: <a href="https://news.ycombinator.com/item?id=46962641">https://news.ycombinator.com/item?id=46962641</a></p>
<p>Points: 19</p>
<p># Comments: 5</p>


---

**ISO Date:** 2026-02-10T16:47:29.000Z