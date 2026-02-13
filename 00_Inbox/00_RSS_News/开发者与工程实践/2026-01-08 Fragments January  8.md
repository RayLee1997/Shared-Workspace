# Fragments: January  8

**Author:** 
**Published:** 2026-01-08T13:29:00.000Z
**Link:** https://martinfowler.com/fragments/2026-01-08.html
**GUID:** 
**Tags:** 

---

## Summary

Anthropic report on how their AI is changing their own software development practice.
Most usage is for debugging and helping understand existing code
Notable increase in using it for implementing new features
Developers using it for 59% of their work and getting 50% productivity increase
14% of developers are “power users” reporting much greater gains
Claude helps developers to work outside their core area
Concerns about changes to the profession, career evolution, and social dynamics
 ❄                ❄                ❄                ❄                ❄
Much of the discussion about using LLMs for software development lacks details on workflow. Rather than just hear people gush about how wonderful it is, I want to understand the gritty details. What kinds of interactions occur with the LLM? What decisions do the humans make? When reviewing LLM outputs, what kinds of things are the humans looking for, what corrections do they make?
Obie Fernandez has written a post that goes into these kinds of details. Over the Christmas / New Year period he used Claude to build a knowledge distillation application, that takes transcripts from Claude Code sessions, slack discussion, github PR threads etc, turns them into an RDF graph database, and provides a web app with natural language ways to query them.
Not a proof of concept. Not a demo. The first cut of Nexus, a production-ready system with authentication, semantic search, an MCP server for agent access, webhook integrations for our primary SaaS platforms, comprehensive test coverage, deployed, integrated and ready for full-scale adoption at my company this coming Monday. Nearly 13,000 lines of code.
The article is long, but worth the time to read it.
An important feature of his workflow is relying on Test-Driven Development
Here’s what made this sustainable rather than chaotic: TDD. Test-driven development. For most of the features, I insisted that Claude Code follow the red-green-refactor cycle with me. Write a failing test first. Make it pass with the simplest implementation. Then refactor while keeping tests green.
This wasn’t just methodology purism. TDD served a critical function in AI-assisted development: it kept me in the loop. When you’re directing thousands of lines of code generation, you need a forcing function that makes you actually understand what’s being built. Tests are that forcing function. You can’t write a meaningful test for something you don’t understand. And you can’t verify that a test correctly captures intent without understanding the intent yourself.
The account includes a major refactoring, and much evolution of the initial version of the tool. It’s also an interesting glimpse of how AI tooling may finally make RDF useful.
 ❄                ❄                ❄                ❄                ❄
When thinking about requirements for software, most discussions focus on prioritization. Some folks talk about buckets such as the MoSCoW set: Must, Should, Could, and Want. (The old joke being that, in MoSCoW, the cow is silent, because hardly any requirements end up in those buckets.) Jason Fried has a different set of buckets for interface design: Obvious, Easy, and Possible. This immediately resonates with me: a good way of think about how to allocate the cognitive costs for those who use a tool.
 ❄                ❄                ❄                ❄                ❄
Casey Newton explains how he followed up on an interesting story of dark patterns in food delivery, and found it to be a fake story, buttressed by AI image and document creation. On one hand, it clarifies the important role reporters play in exposing lies that get traction on the internet. But time taken to do this is time not spent on investigating real stories
For most of my career up until this point, the document shared with me by the whistleblower would have seemed highly credible in large part because it would have taken so long to put together. Who would take the time to put together a detailed, 18-page technical document about market dynamics just to troll a reporter? Who would go to the trouble of creating a fake badge?
Today, though, the report can be generated within minutes, and the badge within seconds. And while no good reporter would ever have published a story based on a single document and an unknown source, plenty would take the time to investigate the document’s contents and see whether human sources would back it up.
The internet has always been full of slop, and we have always needed to be wary of what we read there. AI now makes it easy to manufacture convincing looking evidence, and this is never more dangerous than when it confirms strongly held beliefs and fears.
 ❄                ❄                ❄                ❄                ❄
Kent Beck:
The descriptions of Spec-Driven development that I have seen emphasize writing the whole specification before implementation. This encodes the (to me bizarre) assumption that you aren’t going to learn anything during implementation that would change the specification.
I’ve heard this story so many times told so many ways by well-meaning folks–if only we could get the specification “right”, the rest of this would be easy.
Like him, that story has been the constant background siren to my career in tech. But the learning loop of experimentation is essential to the model building that’s at the heart of any kind of worthwhile specification. As Unmesh puts it:
Large Language Models give us great leverage—but they only work if we focus on learning and understanding. They make it easier to explore ideas, to set things up, to translate intent into code across many specialized languages. But the real capability—our ability to respond to change—comes not from how fast we can produce code, but from how deeply we understand the system we are shaping.
When Kent defined Extreme Programming, he made feedback one of its four core values. It strikes me that the key to making the full use of AI in software development is how to use it to accelerate the feedback loops.
 ❄                ❄                ❄                ❄                ❄
As I listen to people who are serious with AI-assisted programming, the crucial thing I hear is managing context. Programming-oriented tools are geting more sophisticated for that, but there’s also efforts at providing simpler tools, that allow customization. Carlos Villela recently recommended Pi, and its developer, Mario Zechner, has an interesting blog on its development.
So what’s an old guy yelling at Claudes going to do? He’s going to write his own coding agent harness and give it a name that’s entirely un-Google-able, so there will never be any users. Which means there will also never be any issues on the GitHub issue tracker. How hard can it be?
If I ever get the time to sit and really play with these tools, then something like Pi would be something I’d like to try out. Although as an addict to The One True Editor, I’m interested in some of libraries that work with that, such as gptel. That would enable me to use Emacs’s inherent programability to create my own command set to drive the interaction with LLMs.
 ❄                ❄                ❄                ❄                ❄
Outside of my professional work, I’ve posting regularly about my boardgaming on the specialist site BoardGameGeek. However its blogging environment doesn’t do a good job of providing an index to my posts, so I’ve created a list of my BGG posts  on my own site. If you’re interested in my regular posts on boardgaming, and you’re on BGG you can subscribe to me there. If you’re not on BGG you can  subscribe to the blog’s RSS feed.
I’ve also created a list of my favorite board games.

---

## Content

<p>Anthropic report on <a href="https://www.anthropic.com/research/how-ai-is-transforming-work-at-anthropic">how their AI is changing their own software development practice</a>.</p>

<ul>
  <li>Most usage is for debugging and helping understand existing code</li>
  <li>Notable increase in using it for implementing new features</li>
  <li>Developers using it for 59% of their work and getting 50% productivity increase</li>
  <li>14% of developers are “power users” reporting much greater gains</li>
  <li>Claude helps developers to work outside their core area</li>
  <li>Concerns about changes to the profession, career evolution, and social dynamics</li>
</ul>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p>Much of the discussion about using LLMs for software development lacks details on workflow. Rather than just hear people gush about how wonderful it is, I want to understand the gritty details. What kinds of interactions occur with the LLM? What decisions do the humans make? When reviewing LLM outputs, what kinds of things are the humans looking for, what corrections do they make?</p>

<p><a href="https://obie.medium.com/what-used-to-take-months-now-takes-days-cc8883cc21e9">Obie Fernandez</a> has written a post that goes into these kinds of details. Over the Christmas / New Year period he used Claude to build a knowledge distillation application, that takes transcripts from Claude Code sessions, slack discussion, github PR threads etc, turns them into an RDF graph database, and provides a web app with natural language ways to query them.</p>

<blockquote>
  <p>Not a proof of concept. Not a demo. The first cut of Nexus, a production-ready system with authentication, semantic search, an MCP server for agent access, webhook integrations for our primary SaaS platforms, comprehensive test coverage, deployed, integrated and ready for full-scale adoption at my company this coming Monday. Nearly 13,000 lines of code.</p>
</blockquote>

<p>The article is long, but worth the time to read it.</p>

<p>An important feature of his workflow is relying on <a href="https://martinfowler.com/bliki/TestDrivenDevelopment.html">Test-Driven Development</a></p>

<blockquote>
  <p>Here’s what made this sustainable rather than chaotic: TDD. Test-driven development. For most of the features, I insisted that Claude Code follow the red-green-refactor cycle with me. Write a failing test first. Make it pass with the simplest implementation. Then refactor while keeping tests green.</p>

  <p>This wasn’t just methodology purism. TDD served a critical function in AI-assisted development: it kept me in the loop. When you’re directing thousands of lines of code generation, you need a forcing function that makes you actually understand what’s being built. Tests are that forcing function. You can’t write a meaningful test for something you don’t understand. And you can’t verify that a test correctly captures intent without understanding the intent yourself.</p>
</blockquote>

<p>The account includes a major refactoring, and much evolution of the initial version of the tool. It’s also an interesting glimpse of how AI tooling may finally make RDF useful.</p>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p>When thinking about requirements for software, most discussions focus on prioritization. Some folks talk about buckets such as the <a href="https://en.wikipedia.org/wiki/MoSCoW_method">MoSCoW set</a>: Must, Should, Could, and Want. (The old joke being that, in MoSCoW, the cow is silent, because hardly any requirements end up in those buckets.) <a href="https://world.hey.com/jason/the-obvious-the-easy-and-the-possible-2e11a3fb">Jason Fried</a> has a different set of buckets for interface design: <strong>Obvious, Easy, and Possible</strong>. This immediately resonates with me: a good way of think about how to allocate the cognitive costs for those who use a tool.</p>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p><a href="https://www.platformer.news/fake-uber-eats-whisleblower-hoax-debunked/">Casey Newton</a> explains how he followed up on an interesting story of dark patterns in food delivery, and found it to be a fake story, buttressed by AI image and document creation. On one hand, it clarifies the important role reporters play in exposing lies that get traction on the internet. But time taken to do this is time not spent on investigating real stories</p>

<blockquote>
  <p>For most of my career up until this point, the document shared with me by the whistleblower would have seemed highly credible in large part because it would have taken so long to put together. Who would take the time to put together a detailed, 18-page technical document about market dynamics just to troll a reporter? Who would go to the trouble of creating a fake badge?</p>

  <p>Today, though, the report can be generated within minutes, and the badge within seconds. And while no good reporter would ever have published a story based on a single document and an unknown source, plenty would take the time to investigate the document’s contents and see whether human sources would back it up.</p>
</blockquote>

<p>The internet has always been full of slop, and we have always needed to be wary of what we read there. AI now makes it easy to manufacture convincing looking evidence, and this is never more dangerous than when it confirms strongly held beliefs and fears.</p>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p><a href="https://www.linkedin.com/feed/update/urn:li:activity:7413956151144542208/">Kent Beck</a>:</p>

<blockquote>
  <p>The descriptions of Spec-Driven development that I have seen emphasize writing the whole specification before implementation. This encodes the (to me bizarre) assumption that you aren’t going to learn anything during implementation that would change the specification.
I’ve heard this story so many times told so many ways by well-meaning folks–if only we could get the specification “right”, the rest of this would be easy.</p>
</blockquote>

<p>Like him, that story has been the constant background siren to my career in tech. But the <a href="https://martinfowler.com/articles/llm-learning-loop.html">learning loop</a> of experimentation is essential to the model building that’s at the heart of any kind of worthwhile specification. As <a href="https://martinfowler.com/articles/llm-learning-loop.html">Unmesh puts it:</a></p>

<blockquote>
  <p>Large Language Models give us great leverage—but they only work if we focus on learning and understanding. They make it easier to explore ideas, to set things up, to translate intent into code across many specialized languages. But the real capability—our ability to respond to change—comes not from how fast we can produce code, but from how deeply we understand the system we are shaping.</p>
</blockquote>

<p>When Kent defined Extreme Programming, he made <em>feedback</em> one of its four core values. It strikes me that the key to making the full use of AI in software development is how to use it to accelerate the feedback loops.</p>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p>As I listen to people who are serious with AI-assisted programming, the crucial thing I hear is managing context. Programming-oriented tools are geting more sophisticated for that, but there’s also efforts at providing simpler tools, that allow customization. <a href="https://lixo.org">Carlos Villela</a> recently recommended Pi, and its developer, <a href="https://mariozechner.at/posts/2025-11-30-pi-coding-agent/">Mario Zechner, has an interesting blog</a> on its development.</p>

<blockquote>
  <p>So what’s an old guy yelling at Claudes going to do? He’s going to write his own coding agent harness and give it a name that’s entirely un-Google-able, so there will never be any users. Which means there will also never be any issues on the GitHub issue tracker. How hard can it be?</p>
</blockquote>

<p>If I ever get the time to sit and really play with these tools, then something like Pi would be something I’d like to try out. Although as an addict to The One True Editor, I’m interested in some of libraries that work with that, such as <a href="https://github.com/karthink/gptel">gptel</a>. That would enable me to use Emacs’s inherent programability to create my own command set to drive the interaction with LLMs.</p>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p>Outside of my professional work, I’ve <a href="https://boardgamegeek.com/blog/13064/martins-7th-decade">posting regularly about my boardgaming</a> on the specialist site BoardGameGeek. However its blogging environment doesn’t do a good job of providing an index to my posts, so I’ve created <a href="https://martinfowler.com/boardgames/">a list of my BGG posts </a> on my own site. If you’re interested in my regular posts on boardgaming, and you’re on BGG you can subscribe to me there. If you’re not on BGG you can  subscribe to the blog’s <a href="https://boardgamegeek.com/rss/blog/13064">RSS feed</a>.</p>

<p>I’ve also created a list of <a href="https://martinfowler.com/boardgames/fav-games.html">my favorite board games</a>.</p>

<p><img src="https://martinfowler.com/boardgames/index/game-grid.png" alt=""></p>


---

**ISO Date:** 2026-01-08T13:29:00.000Z