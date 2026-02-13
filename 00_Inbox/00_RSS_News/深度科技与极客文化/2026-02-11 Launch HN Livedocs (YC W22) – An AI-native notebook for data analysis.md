# Launch HN: Livedocs (YC W22) – An AI-native notebook for data analysis

**Author:** arsalanb
**Published:** Tue, 10 Feb 2026 18:09:14 +0000
**Link:** https://livedocs.com
**GUID:** https://news.ycombinator.com/item?id=46964162
**Tags:** 

---

## Summary

Hi HN, I'm Arsalan, founder of LiveDocs (https://livedocs.com). We're building an AI-native data workspace that lets teams ask questions of their real data and have the system plan, execute, and maintain the analysis end-to-end.
We previously posted about LiveDocs four years ago (https://news.ycombinator.com/item?id=30735058). Back then, LiveDocs was a no-code analytics tool for stitching together metrics from tools like Stripe and Google Analytics. It worked for basic reporting, but over time we ran into the same ceiling our users did. Dashboards are fine until the questions get messy, and notebooks slowly turn into hard-to-maintain piles of glue.
Over the last few years, we rebuilt LiveDocs almost entirely around a different idea. Data work should behave like a living system, not a static document or a chat transcript.
Today, LiveDocs is a reactive notebook environment backed by real execution engines. Notebooks are not linear. Each cell participates in a dependency graph, so when data or logic changes, only the affected parts recompute. You can freely mix SQL, Python, charts, tables, and text in the same document and everything stays in sync. Locally we run on DuckDB and Polars, and when you connect a warehouse like Snowflake, BigQuery, or Postgres, queries are pushed down instead of copying data out. Every result is inspectable and reproducible.
On top of this environment sits an AI agent, but it is not "chat with your data." The agent works inside the notebook itself. It can plan multi-step analyses, write and debug SQL or Python, spawn specialized sub-agents for different tasks, run code in a terminal, and browse documentation or the web when it lacks context. Because it operates inside the same execution graph as humans, you can see exactly what it ran, edit it, or take over at any point.
We also support a canvas mode where the agent can build custom UI for your analysis, not just charts. This includes tables with controls, comparisons, and derived views that stay wired to the underlying data. When a notebook is not the right interface, you can publish parts of it as an interactive app. These behave more like lightweight internal tools, similar in spirit to Retool, but backed by the same analysis logic.
Everything in LiveDocs is fully real-time collaborative. Multiple people can edit the same notebook, see results update live, comment inline, and share documents or apps without exposing raw code unless they want to.
Teams use LiveDocs to investigate questions that do not fit cleanly into dashboards, build analyses that evolve over time without constant rewrites, and automate recurring questions without turning them into brittle pipelines.
Pricing is pay-as-you-go, starting at $15 per month, with a free tier so people can try it without talking to us. You'll have to sign up, as it requires us to provision a sandbox for your to run your notebook. Here's a video demo: https://youtu.be/Hl12su9Jn_I
We are still learning where this breaks. Long-running agent workflows on production data surface a lot of sharp edges. We would love feedback from people who have built or lived with analytics systems, notebooks, or "chat with your data" tools and felt their limits. Happy to go deep on technical details and trade notes.
Comments URL: https://news.ycombinator.com/item?id=46964162
Points: 43
# Comments: 18

---

## Content


<p>Hi HN, I'm Arsalan, founder of LiveDocs (<a href="https://livedocs.com">https://livedocs.com</a>). We're building an AI-native data workspace that lets teams ask questions of their real data and have the system plan, execute, and maintain the analysis end-to-end.<p>We previously posted about LiveDocs four years ago (<a href="https://news.ycombinator.com/item?id=30735058">https://news.ycombinator.com/item?id=30735058</a>). Back then, LiveDocs was a no-code analytics tool for stitching together metrics from tools like Stripe and Google Analytics. It worked for basic reporting, but over time we ran into the same ceiling our users did. Dashboards are fine until the questions get messy, and notebooks slowly turn into hard-to-maintain piles of glue.<p>Over the last few years, we rebuilt LiveDocs almost entirely around a different idea. Data work should behave like a living system, not a static document or a chat transcript.<p>Today, LiveDocs is a reactive notebook environment backed by real execution engines. Notebooks are not linear. Each cell participates in a dependency graph, so when data or logic changes, only the affected parts recompute. You can freely mix SQL, Python, charts, tables, and text in the same document and everything stays in sync. Locally we run on DuckDB and Polars, and when you connect a warehouse like Snowflake, BigQuery, or Postgres, queries are pushed down instead of copying data out. Every result is inspectable and reproducible.<p>On top of this environment sits an AI agent, but it is not "chat with your data." The agent works inside the notebook itself. It can plan multi-step analyses, write and debug SQL or Python, spawn specialized sub-agents for different tasks, run code in a terminal, and browse documentation or the web when it lacks context. Because it operates inside the same execution graph as humans, you can see exactly what it ran, edit it, or take over at any point.<p>We also support a canvas mode where the agent can build custom UI for your analysis, not just charts. This includes tables with controls, comparisons, and derived views that stay wired to the underlying data. When a notebook is not the right interface, you can publish parts of it as an interactive app. These behave more like lightweight internal tools, similar in spirit to Retool, but backed by the same analysis logic.<p>Everything in LiveDocs is fully real-time collaborative. Multiple people can edit the same notebook, see results update live, comment inline, and share documents or apps without exposing raw code unless they want to.<p>Teams use LiveDocs to investigate questions that do not fit cleanly into dashboards, build analyses that evolve over time without constant rewrites, and automate recurring questions without turning them into brittle pipelines.<p>Pricing is pay-as-you-go, starting at $15 per month, with a free tier so people can try it without talking to us. You'll have to sign up, as it requires us to provision a sandbox for your to run your notebook. Here's a video demo: <a href="https://youtu.be/Hl12su9Jn_I" rel="nofollow">https://youtu.be/Hl12su9Jn_I</a><p>We are still learning where this breaks. Long-running agent workflows on production data surface a lot of sharp edges. We would love feedback from people who have built or lived with analytics systems, notebooks, or "chat with your data" tools and felt their limits. Happy to go deep on technical details and trade notes.</p>
<hr>
<p>Comments URL: <a href="https://news.ycombinator.com/item?id=46964162">https://news.ycombinator.com/item?id=46964162</a></p>
<p>Points: 43</p>
<p># Comments: 18</p>


---

**ISO Date:** 2026-02-10T18:09:14.000Z