# Show HN: 20+ Claude Code agents coordinating on real work (open source)

**Author:** austinbaggio
**Published:** Thu, 12 Feb 2026 16:23:37 +0000
**Link:** https://github.com/mutable-state-inc/lean-collab
**GUID:** https://news.ycombinator.com/item?id=46990733
**Tags:** 

---

## Summary

Single-agent LLMs suck at long-running complex tasks.
We’ve open-sourced a multi-agent orchestrator that we’ve been using to handle long-running LLM tasks. We found that single LLM agents tend to stall, loop, or generate non-compiling code, so we built a harness for agents to coordinate over shared context while work is in progress.
How it works:
1. Orchestrator agent that manages task decomposition
2. Sub-agents for parallel work
3. Subscriptions to task state and progress
4. Real-time sharing of intermediate discoveries between agents
We tested this on a Putnam-level math problem, but the pattern generalizes to things like refactors, app builds, and long research.
It’s packaged as a Claude Code skill and designed to be small, readable, and modifiable.
Use it, break it, tell me about what workloads we should try and run next!
Comments URL: https://news.ycombinator.com/item?id=46990733
Points: 8
# Comments: 7

---

## Content


<p>Single-agent LLMs suck at long-running complex tasks.<p>We’ve open-sourced a multi-agent orchestrator that we’ve been using to handle long-running LLM tasks. We found that single LLM agents tend to stall, loop, or generate non-compiling code, so we built a harness for agents to coordinate over shared context while work is in progress.<p>How it works:
1. Orchestrator agent that manages task decomposition
2. Sub-agents for parallel work
3. Subscriptions to task state and progress
4. Real-time sharing of intermediate discoveries between agents<p>We tested this on a Putnam-level math problem, but the pattern generalizes to things like refactors, app builds, and long research.
It’s packaged as a Claude Code skill and designed to be small, readable, and modifiable.<p>Use it, break it, tell me about what workloads we should try and run next!</p>
<hr>
<p>Comments URL: <a href="https://news.ycombinator.com/item?id=46990733">https://news.ycombinator.com/item?id=46990733</a></p>
<p>Points: 8</p>
<p># Comments: 7</p>


---

**ISO Date:** 2026-02-12T16:23:37.000Z