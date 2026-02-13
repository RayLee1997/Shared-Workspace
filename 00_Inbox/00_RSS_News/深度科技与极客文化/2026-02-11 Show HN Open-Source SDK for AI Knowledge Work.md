# Show HN: Open-Source SDK for AI Knowledge Work

**Author:** ankit219
**Published:** Tue, 10 Feb 2026 17:06:00 +0000
**Link:** https://github.com/ClioAI/kw-sdk
**GUID:** https://news.ycombinator.com/item?id=46963026
**Tags:** 

---

## Summary

GitHub: https://github.com/ClioAI/kw-sdk
Most AI agent frameworks target code. Write code, run tests, fix errors, repeat. That works because code has a natural verification signal. It works or it doesn't.
This SDK treats knowledge work like an engineering problem:
Task → Brief → Rubric (hidden from executor) → Work → Verify → Fail? → Retry → Pass → Submit
The orchestrator coordinates subagents, web search, code execution, and file I/O. then checks its own work against criteria it can't game (the rubric is generated in a separate call and the executor never sees it directly).
We originally built this as a harness for RL training on knowledge tasks. The rubric is the reward function. If you're training models on knowledge work, the brief→rubric→execute→verify loop gives you a structured reward signal for tasks that normally don't have one.
What makes Knowledge work different from code? (apart from feedback loop)
I believe there is some functionality missing from today's agents when it comes to knowledge work. I tried to include that in this release. Example:
Explore mode: Mapping the solution space, identifying the set level gaps, and giving options.
Most agents optimize for a single answer, and end up with a median one. For strategy, design, creative problems, you want to see the options, what are the tradeoffs, and what can you do? Explore mode generates N distinct approaches, each with explicit assumptions and counterfactuals ("this works if X, breaks if Y"). The output ends with set-level gaps ie what angles the entire set missed. The gaps are often more valuable than the takes. I think this is what many of us do on a daily basis, but no agent directly captures it today. See https://github.com/ClioAI/kw-sdk/blob/main/examples/explore_... and the output for a sense of how this is different.
Checkpointing: With many ai agents and especially multi agent systems, i can see where it went wrong, but cant run inference from same stage. (or you may want multiple explorations once an agent has done some tasks like search and is now looking at ideas). I used this for rollouts a lot, and think its a great feature to run again, or fork from a specific checkpoint.
A note on Verification loop:
The verify step is where the real leverage is. A model that can accurately assess its own work against a rubric is more valuable than one that generates slightly better first drafts. The rubric makes quality legible — to the agent, to the human, and potentially to a training signal.
Some things i like about this: 
- You can pass a remote execution environment (including your browser as a sandbox) and it would work. It can be docker, e2b, your local env, anything, the model will execute commands in your context, and will iterate based on feedback loop. Code execution is a protocol here.
- Tool calling: I realize you don't need complex functions. Models are good at writing terminal code, and can iterate based on feedback, so you can just pass either functions in context and model will execute or you can pass docs and model will write the code. (same as anthropic's programmatic tool calling). Details: https://github.com/ClioAI/kw-sdk/blob/main/TOOL_CALLING_GUID...
Lastly, some guides: 
- SDK guide: https://github.com/ClioAI/kw-sdk/blob/main/SDK_GUIDE.md
- Extensible. See bizarro example where i add a new mode: https://github.com/ClioAI/kw-sdk/blob/main/examples/custom_m...
- working with files: https://github.com/ClioAI/kw-sdk/blob/main/examples/with_fil... 
- this is simple but i love the csv example: https://github.com/ClioAI/kw-sdk/blob/main/examples/csv_rese...
- remote execution: https://github.com/ClioAI/kw-sdk/blob/main/examples/with_cus...
And a lot more. This was completely refactored by opus and given the rework, probably would have taken a lot of time to release it.
MIT licensed. Would love your feedback.
Comments URL: https://news.ycombinator.com/item?id=46963026
Points: 4
# Comments: 1

---

## Content


<p>GitHub: <a href="https://github.com/ClioAI/kw-sdk" rel="nofollow">https://github.com/ClioAI/kw-sdk</a><p>Most AI agent frameworks target code. Write code, run tests, fix errors, repeat. That works because code has a natural verification signal. It works or it doesn't.<p>This SDK treats knowledge work like an engineering problem:<p>Task → Brief → Rubric (hidden from executor) → Work → Verify → Fail? → Retry → Pass → Submit<p>The orchestrator coordinates subagents, web search, code execution, and file I/O. then checks its own work against criteria it can't game (the rubric is generated in a separate call and the executor never sees it directly).<p>We originally built this as a harness for RL training on knowledge tasks. The rubric is the reward function. If you're training models on knowledge work, the brief→rubric→execute→verify loop gives you a structured reward signal for tasks that normally don't have one.<p>What makes Knowledge work different from code? (apart from feedback loop)
I believe there is some functionality missing from today's agents when it comes to knowledge work. I tried to include that in this release. Example:<p>Explore mode: Mapping the solution space, identifying the set level gaps, and giving options.<p>Most agents optimize for a single answer, and end up with a median one. For strategy, design, creative problems, you want to see the options, what are the tradeoffs, and what can you do? Explore mode generates N distinct approaches, each with explicit assumptions and counterfactuals ("this works if X, breaks if Y"). The output ends with set-level gaps ie what angles the entire set missed. The gaps are often more valuable than the takes. I think this is what many of us do on a daily basis, but no agent directly captures it today. See <a href="https://github.com/ClioAI/kw-sdk/blob/main/examples/explore_mode.py" rel="nofollow">https://github.com/ClioAI/kw-sdk/blob/main/examples/explore_...</a> and the output for a sense of how this is different.<p>Checkpointing: With many ai agents and especially multi agent systems, i can see where it went wrong, but cant run inference from same stage. (or you may want multiple explorations once an agent has done some tasks like search and is now looking at ideas). I used this for rollouts a lot, and think its a great feature to run again, or fork from a specific checkpoint.<p>A note on Verification loop:
The verify step is where the real leverage is. A model that can accurately assess its own work against a rubric is more valuable than one that generates slightly better first drafts. The rubric makes quality legible — to the agent, to the human, and potentially to a training signal.<p>Some things i like about this: 
- You can pass a remote execution environment (including your browser as a sandbox) and it would work. It can be docker, e2b, your local env, anything, the model will execute commands in your context, and will iterate based on feedback loop. Code execution is a protocol here.<p>- Tool calling: I realize you don't need complex functions. Models are good at writing terminal code, and can iterate based on feedback, so you can just pass either functions in context and model will execute or you can pass docs and model will write the code. (same as anthropic's programmatic tool calling). Details: <a href="https://github.com/ClioAI/kw-sdk/blob/main/TOOL_CALLING_GUIDE.md" rel="nofollow">https://github.com/ClioAI/kw-sdk/blob/main/TOOL_CALLING_GUID...</a><p>Lastly, some guides: 
- SDK guide: <a href="https://github.com/ClioAI/kw-sdk/blob/main/SDK_GUIDE.md" rel="nofollow">https://github.com/ClioAI/kw-sdk/blob/main/SDK_GUIDE.md</a>
- Extensible. See bizarro example where i add a new mode: <a href="https://github.com/ClioAI/kw-sdk/blob/main/examples/custom_mode_bizarro.py" rel="nofollow">https://github.com/ClioAI/kw-sdk/blob/main/examples/custom_m...</a>
- working with files: <a href="https://github.com/ClioAI/kw-sdk/blob/main/examples/with_files.py" rel="nofollow">https://github.com/ClioAI/kw-sdk/blob/main/examples/with_fil...</a> 
- this is simple but i love the csv example: <a href="https://github.com/ClioAI/kw-sdk/blob/main/examples/csv_research_and_calc.py" rel="nofollow">https://github.com/ClioAI/kw-sdk/blob/main/examples/csv_rese...</a>
- remote execution: <a href="https://github.com/ClioAI/kw-sdk/blob/main/examples/with_custom_executor.py" rel="nofollow">https://github.com/ClioAI/kw-sdk/blob/main/examples/with_cus...</a><p>And a lot more. This was completely refactored by opus and given the rework, probably would have taken a lot of time to release it.<p>MIT licensed. Would love your feedback.</p>
<hr>
<p>Comments URL: <a href="https://news.ycombinator.com/item?id=46963026">https://news.ycombinator.com/item?id=46963026</a></p>
<p>Points: 4</p>
<p># Comments: 1</p>


---

**ISO Date:** 2026-02-10T17:06:00.000Z