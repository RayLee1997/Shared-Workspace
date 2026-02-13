# Fragments: February  9

**Author:** 
**Published:** 2026-02-09T19:32:00.000Z
**Link:** https://martinfowler.com/fragments/2026-02-09.html
**GUID:** 
**Tags:** 

---

## Summary

Some more thoughts from last week’s open space gathering on the future of software development in the age of AI. I haven’t attributed any comments since we were operating under the Chatham House Rule, but should the sources recognize themselves and would like to be attributed, then get in touch and I’ll edit this post.
 ❄                ❄
During the opening of the gathering, I commented that I was naturally skeptical of the value of LLMs. After all, the decades have thrown up many tools that have claimed to totally change the nature of software development. Most of these have been little better than snake oil.
But I am a total, absolute skeptic - which means I also have to be skeptical of my own skepticism.
 ❄                ❄
One of our sessions focused on the problem of “cognitive debt”. Usually, as we build a software system, the developers of that system gain an understanding both the underlying domain and the software they are building to support it. But once so much work is sent off to LLMs, does this mean the team no longer learns as much? And if so, what are the consequences of this? Can we rely on The Genie to keep track of everything, or should we take active measures to ensure the team understands more of what’s being built and why?
The TDD cycle involves a key (and often under-used) step to refactor the code. This is where the developers consolidate their understanding and embed it into the codebase. Do we need some similar step to ensure we understand what the LLMs are up to?
When the LLM writes some complex code, ask it to explain how it works. Maybe get it do so in a funky way, such as asking it to explain the code’s behavior in the form of a fairy tale.
 ❄                ❄
OH: “LLMs are drug dealers, they give us stuff, but don’t care about the resulting system or the humans that develop and use it”. Who cares about the long-term health of the system when the LLM renews its context with every cycle?
 ❄                ❄
Programmers are wary of LLMs not just because folks are worried for their jobs, but also because we’re scared that LLMs will remove much of the fun from programming. As I think about this, I consider what I enjoy about programming. One aspect is delivering useful features - which I only see improving as LLMs become more capable.
But, for me, programming is more than that. Another aspect I enjoy about programming is model building. I enjoy the process of coming up with abstractions that help me reason about the domain the code is supporting - and I am concerned that LLMs will cause me to spend less attention on this model building. It may be, however, that model-building becomes an important part of working effectively with LLMs, a topic Unmesh Joshi and I explored a couple of months ago.
 ❄                ❄
In the age of LLMs, will there still be such a things as “source code”, and if so, what will it look like? Prompts, and other forms of natural language context can elicit a lot of behavior, and cause a rise in the level of abstraction, but also a sideways move into non-determinism. In all this is there still a role for a persistent statement of non-deterministic behavior?
Almost a couple of decades ago, I became interested in a class of tools called Language Workbenches. They didn’t have a significant impact on software development, but maybe the rise of LLMs will reintroduce some ideas from them. These tools rely on a semantic model that the tool persists in some kind of storage medium, that isn’t necessarily textual or comprehensible to humans directly. Instead, for humans to understand it, the tools include projectional editors that create human-readable projections of the model.
Could this notion of a non-human deterministic representation  become the future source code? One that’s designed to maximize expression with minimal tokens?
 ❄                ❄
OH: “Scala was the first example of a lab-leak in software. A language designed for dangerous experiments in type theory escaped into the general developer population.”
 ❄                ❄                ❄                ❄                ❄
elsewhere on the web
Angie Jones on tips for open source maintainers to handle AI contributions
I’ve been seeing more and more open source maintainers throwing up their hands over AI generated pull requests. Going so far as to stop accepting PRs from external contributors.
[snip]
But yo, what are we doing?! Closing the door on contributors isn’t the answer. Open source maintainers don’t want to hear this, but this is the way people code now, and you need to do your part to prepare your repo for AI coding assistants.
 ❄                ❄                ❄                ❄                ❄
Matthias Kainer has written a cool explanation of how transformers work with interactive examples
Last Tuesday my kid came back from school, sat down and asked: “How does ChatGPT actually know what word comes next?” And I thought - great question. Terrible timing, because dinner was almost ready, but great question.
So I tried to explain it. And failed. Not because it is impossibly hard, but because the usual explanations are either “it is just matrix multiplication” (true but useless) or “it uses attention mechanisms” (cool name, zero information). Neither of those helps a 12-year-old. Or, honestly, most adults. Also, even getting to start my explanation was taking longer than a tiktok, so my kid lost attention span before I could even say “matrix multiplication”. I needed something more visual. More interactive. More fun.
So here is the version I wish I had at dinner. With drawings. And things you can click on. Because when everything seems abstract, playing with the actual numbers can bring some light.
A helpful guide for any 12-year-old, or a 62-year-old that fears they’re regressing.
 ❄                ❄                ❄                ❄                ❄
In my last fragments, I included some concerns about how advertising could interplay with chatbots. Anthropic have now made some adverts about concerns about adverts - both funny and creepy. Sam Altman is amused and annoyed.

---

## Content

<p>Some more thoughts from last week’s open space gathering on the future of software development in the age of AI. I haven’t attributed any comments since we were operating under the <a href="https://www.chathamhouse.org/about-us/chatham-house-rule">Chatham House Rule</a>, but should the sources recognize themselves and would like to be attributed, then get in touch and I’ll edit this post.</p>

<p> ❄                ❄</p>

<p>During the opening of the gathering, I commented that I was naturally skeptical of the value of LLMs. After all, the decades have thrown up many tools that have claimed to totally change the nature of software development. Most of these have been little better than snake oil.</p>

<p>But I am a <em>total, absolute skeptic</em> - which means I also have to be skeptical of my own skepticism.</p>

<p> ❄                ❄</p>

<p>One of our sessions focused on the problem of “cognitive debt”. Usually, as we build a software system, the developers of that system gain an understanding both the underlying domain and the software they are building to support it. But once so much work is sent off to LLMs, does this mean the team no longer learns as much? And if so, what are the consequences of this? Can we rely on <a href="https://martinfowler.com/articles/who-is-llm.html">The Genie</a> to keep track of everything, or should we take active measures to ensure the team understands more of what’s being built and why?</p>

<p>The <a href="https://martinfowler.com/bliki/TestDrivenDevelopment.html">TDD cycle</a> involves a key (and often under-used) step to refactor the code. This is where the developers consolidate their understanding and embed it into the codebase. Do we need some similar step to ensure we understand what the LLMs are up to?</p>

<p>When the LLM writes some complex code, ask it to explain how it works. Maybe get it do so in a funky way, such as asking it to explain the code’s behavior in the form of a fairy tale.</p>

<p> ❄                ❄</p>

<p>OH: “LLMs are drug dealers, they give us stuff, but don’t care about the resulting system or the humans that develop and use it”. Who cares about the long-term health of the system when the LLM renews its context with every cycle?</p>

<p> ❄                ❄</p>

<p>Programmers are wary of LLMs not just because folks are worried for their jobs, but also because we’re scared that LLMs will remove much of the fun from programming. As I think about this, I consider what I enjoy about programming. One aspect is delivering useful features - which I only see improving as LLMs become more capable.</p>

<p>But, for me, programming is more than that. Another aspect I enjoy about programming is model building. I enjoy the process of coming up with abstractions that help me reason about the domain the code is supporting - and I am concerned that LLMs will cause me to spend less attention on this model building. It may be, however, that model-building becomes an important part of working effectively with LLMs, a topic <a href="https://martinfowler.com/articles/convo-llm-abstractions.html">Unmesh Joshi and I explored</a> a couple of months ago.</p>

<p> ❄                ❄</p>

<p>In the age of LLMs, will there still be such a things as “source code”, and if so, what will it look like? Prompts, and other forms of natural language context can elicit a lot of behavior, and cause a rise in the level of abstraction, but also a <a href="https://martinfowler.com/articles/2025-nature-abstraction.html">sideways move into non-determinism</a>. In all this is there still a role for a persistent statement of non-deterministic behavior?</p>

<p>Almost a couple of decades ago, I became interested in a class of tools called <a href="https://martinfowler.com/articles/languageWorkbench.html">Language Workbenches</a>. They didn’t have a significant impact on software development, but maybe the rise of LLMs will reintroduce some ideas from them. These tools rely on a <a href="https://martinfowler.com/articles/languageWorkbench.html#workbench.gif">semantic model</a> that the tool persists in some kind of storage medium, that isn’t necessarily textual or comprehensible to humans directly. Instead, for humans to understand it, the tools include projectional editors that create human-readable projections of the model.</p>

<p>Could this notion of a non-human deterministic representation  become the future source code? One that’s designed to maximize expression with minimal tokens?</p>

<p> ❄                ❄</p>

<p>OH: “Scala was the first example of a lab-leak in software. A language designed for dangerous experiments in type theory escaped into the general developer population.”</p>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p><em>elsewhere on the web</em></p>

<p>Angie Jones on <a href="https://angiejones.tech/stop-closing-the-door-fix-the-house/">tips for open source maintainers to handle AI contributions</a></p>

<blockquote>
  <p>I’ve been seeing more and more open source maintainers throwing up their hands over AI generated pull requests. Going so far as to stop accepting PRs from external contributors.</p>

  <p><em>[snip]</em></p>

  <p>But yo, what are we doing?! Closing the door on contributors isn’t the answer. Open source maintainers don’t want to hear this, but this is the way people code now, and you need to do your part to prepare your repo for AI coding assistants.</p>
</blockquote>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p>Matthias Kainer has written a cool <a href="https://matthias-kainer.de/blog/posts/so-whats-the-next-word-then-/">explanation of how transformers work with interactive examples</a></p>

<blockquote>
  <p>Last Tuesday my kid came back from school, sat down and asked: “How does ChatGPT actually know what word comes next?” And I thought - great question. Terrible timing, because dinner was almost ready, but great question.</p>

  <p>So I tried to explain it. And failed. Not because it is impossibly hard, but because the usual explanations are either “it is just matrix multiplication” (true but useless) or “it uses attention mechanisms” (cool name, zero information). Neither of those helps a 12-year-old. Or, honestly, most adults. Also, even getting to start my explanation was taking longer than a tiktok, so my kid lost attention span before I could even say “matrix multiplication”. I needed something more visual. More interactive. More fun.</p>

  <p>So here is the version I wish I had at dinner. With drawings. And things you can click on. Because when everything seems abstract, playing with the actual numbers can bring some light.</p>
</blockquote>

<p>A helpful guide for any 12-year-old, or a 62-year-old that fears they’re regressing.</p>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p>In my <a href="https://martinfowler.com/fragments/2026-02-04.html">last fragments</a>, I included some concerns about how advertising could interplay with chatbots. Anthropic have now made some <a href="https://mashable.com/article/anthropic-super-bowl-ad-mocks-chatgpt-ads">adverts about concerns about adverts</a> - both funny and creepy. <a href="https://www.theguardian.com/technology/2026/feb/07/ai-chatbots-anthropic-openai-claude-chatgpt">Sam Altman is amused and annoyed.</a></p>


---

**ISO Date:** 2026-02-09T19:32:00.000Z