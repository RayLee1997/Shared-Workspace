# Show HN: Multimodal perception system for real-time conversation

**Author:** mert_gerdan
**Published:** Tue, 10 Feb 2026 18:58:35 +0000
**Link:** https://raven.tavuslabs.org
**GUID:** https://news.ycombinator.com/item?id=46965012
**Tags:** 

---

## Summary

I work on real-time voice/video AI at Tavus and for the past few years, I’ve mostly focused on how machines respond in a conversation.
One thing that’s always bothered me is that almost all conversational systems still reduce everything to transcripts, and throw away a ton of signals that need to be used downstream. Some existing emotion understanding models try to analyze and classify into small sets of arbitrary boxes, but they either aren’t fast / rich enough to do this with conviction in real-time.
So I built a multimodal perception system which gives us a way to encode visual and audio conversational signals and have them translated into natural language by aligning a small LLM on these signals, such that the agent can "see" and "hear" you, and that you can interface with it via an OpenAI compatible tool schema in a live conversation.
It outputs short natural language descriptions of what’s going on in the interaction - things like uncertainty building, sarcasm, disengagement, or even shift in attention of a single turn in a convo.
Some quick specs:
- Runs in real-time per conversation
- Processing at ~15fps video + overlapping audio alongside the conversation
- Handles nuanced emotions, whispers vs shouts
- Trained on synthetic + internal convo data
Happy to answer questions or go deeper on architecture/tradeoffs
More details here: https://www.tavus.io/post/raven-1-bringing-emotional-intelli...
Comments URL: https://news.ycombinator.com/item?id=46965012
Points: 40
# Comments: 12

---

## Content


<p>I work on real-time voice/video AI at Tavus and for the past few years, I’ve mostly focused on how machines respond in a conversation.<p>One thing that’s always bothered me is that almost all conversational systems still reduce everything to transcripts, and throw away a ton of signals that need to be used downstream. Some existing emotion understanding models try to analyze and classify into small sets of arbitrary boxes, but they either aren’t fast / rich enough to do this with conviction in real-time.<p>So I built a multimodal perception system which gives us a way to encode visual and audio conversational signals and have them translated into natural language by aligning a small LLM on these signals, such that the agent can "see" and "hear" you, and that you can interface with it via an OpenAI compatible tool schema in a live conversation.<p>It outputs short natural language descriptions of what’s going on in the interaction - things like uncertainty building, sarcasm, disengagement, or even shift in attention of a single turn in a convo.<p>Some quick specs:<p>- Runs in real-time per conversation<p>- Processing at ~15fps video + overlapping audio alongside the conversation<p>- Handles nuanced emotions, whispers vs shouts<p>- Trained on synthetic + internal convo data<p>Happy to answer questions or go deeper on architecture/tradeoffs<p>More details here: <a href="https://www.tavus.io/post/raven-1-bringing-emotional-intelligence-to-artificial-intelligence">https://www.tavus.io/post/raven-1-bringing-emotional-intelli...</a></p>
<hr>
<p>Comments URL: <a href="https://news.ycombinator.com/item?id=46965012">https://news.ycombinator.com/item?id=46965012</a></p>
<p>Points: 40</p>
<p># Comments: 12</p>


---

**ISO Date:** 2026-02-10T18:58:35.000Z