# Fragments Dec 4

**Author:** 
**Published:** 2025-12-04T15:59:00.000Z
**Link:** https://martinfowler.com/articles/20251204-frags.html
**GUID:** 
**Tags:** 

---

## Summary

Rob Bowley summarizes a study from Carnegie Mellon looking on the impact of AI on a bunch of open-source software projects. Like any such study, we shouldn’t take its results as definitive, but there seems enough there to make it a handy data point. The key point is that the AI code probably reduced the quality of the code base - at least if static code analysis can be trusted to determine quality. And perhaps some worrying second-order effects
This study shows more than 800 popular GitHub projects with code quality degrading after adopting AI tools. It’s hard not to see a form of context collapse playing out in real time. If the public code that future models learn from is becoming more complex and less maintainable, there’s a real risk that newer models will reinforce and amplify those trends, producing even worse code over time.
 ❄                ❄                ❄                ❄                ❄
Rob’s post is typical of much of the thoughtful writing on AI. We can see its short-term benefits, but worry about its long-term impact. But on a much deeper note is this lovely story from Jim Highsmith. Jim has turned 0x50, and has spent the last decade fighting Parkinson’s disease. To help him battle it he has two AI assisted allies.
Between my neural implants and Byron’s digital guidance, I now collaborate with two adaptive systems: one for motion, one for thought. Neither replaces me. Both extend me.
If you read anything on AI this week, make it be this. It offers a positive harbinger for our future and opens my mind to a whole different perspective of the role of AI in it
 ❄                ❄                ❄                ❄                ❄
Anthropic recently announced that it disrupted a Chinese state-sponsored operation abusing Claude Code. Jim Gumbley looks at the core lesson to learn from this, that we have to understand the serious risk of  AI Jailbreaking
New AI tools are able to analyze your attack surface at the next level of granularity. As a business leader, that means you now have two options: wait for someone else to run AI-assisted vulnerability detection against your attack surface, or run it yourself first.
 ❄                ❄                ❄                ❄                ❄
There’s plenty of claims that AI Vibe Coding can replace software developers, something that folks like me (perhaps with a bias) think unlikely. Gergely Orosz shared this tidbit
Talked with an exec at a tech company who is obsessed with AI and has been for 3 years. Not a developer but company makes software. Uses AI for everything, vibe codes ideas.
Here’s the kicker:
Has a team of several devs to implement his vibe coded prototypes to sg workable
I’d love to hear more about this (and similar stories)
 ❄                ❄                ❄                ❄                ❄
Nick Radcliffe writes about a month of using AI
I spent a solid month “pair programming” with Claude Code, trying to suspend disbelief and adopt a this-will-be-productive mindset. More specifically, I got Claude to write well over 99% of the code produced during the month. I found the experience infuriating, unpleasant, and stressful before even worrying about its energy impact. Ideally, I would prefer not to do it again for at least a year or two. The only problem with that is that it “worked”.
He stresses that his approach is the “polar opposite” of Vibe Coding. The post is long, and rambles a bit, but is worthwhile because he talks in detail about his workflow and how he uses the tool. Such posts are important so we can learn the nitty-gritty of how our programming habits are changing.
 ❄                ❄                ❄                ❄                ❄
Along similar lines is a post of Brian Chambers on his workflow, that he calls Issue-Driven Development (and yes, I’m also sick of the “something-driven” phraseology). As with much of the better stuff I’ve heard about AI assisted work, it’s all about carefully managing the context window, ensuring the AI is focused on the right things and not distracted by textual squirrels.

---

## Content

<p><a href="https://blog.robbowley.net/2025/12/04/ai-is-still-making-code-worse-a-new-cmu-study-confirms/">Rob Bowley</a> summarizes a study from Carnegie Mellon looking on the impact of AI on a bunch of open-source software projects. Like any such study, we shouldn’t take its results as definitive, but there seems enough there to make it a handy data point. The key point is that the AI code probably reduced the quality of the code base - at least if static code analysis can be trusted to determine quality. And perhaps some worrying second-order effects</p>

<blockquote>
  <p>This study shows more than 800 popular GitHub projects with code quality degrading after adopting AI tools. It’s hard not to see a form of context collapse playing out in real time. If the public code that future models learn from is becoming more complex and less maintainable, there’s a real risk that newer models will reinforce and amplify those trends, producing even worse code over time.</p>
</blockquote>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p>Rob’s post is typical of much of the thoughtful writing on AI. We can see its short-term benefits, but worry about its long-term impact. But on a much deeper note is this lovely story from <a href="https://www.linkedin.com/pulse/my-80th-birthday-i-bought-myself-new-brain-jim-highsmith-8qcrc/">Jim Highsmith</a>. Jim has turned 0x50, and has spent the last decade fighting Parkinson’s disease. To help him battle it he has two AI assisted allies.</p>

<blockquote>
  <p>Between my neural implants and Byron’s digital guidance, I now collaborate with two adaptive systems: one for motion, one for thought. Neither replaces me. Both extend me.</p>
</blockquote>

<p><strong>If you read anything on AI this week, <a href="https://www.linkedin.com/pulse/my-80th-birthday-i-bought-myself-new-brain-jim-highsmith-8qcrc/">make it be this</a>.</strong> It offers a positive harbinger for our future and opens my mind to a whole different perspective of the role of AI in it</p>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p>Anthropic recently announced that it disrupted a Chinese state-sponsored operation abusing Claude Code. Jim Gumbley looks at the core lesson to learn from this, that we have to understand the serious risk of  <a href="https://www.thoughtworks.com/insights/blog/security/anthropic-ai-espionage-disclosure-signal-from-noise?utm_source=linkedin&amp;utm_medium=social-organic&amp;utm_campaign=dt_bs_rp-in-clt_tech_thought_leaders_2025-11&amp;gh_src=d1fe17bc1us">AI Jailbreaking</a></p>

<blockquote>
  <p>New AI tools are able to analyze your attack surface at the next level of granularity. As a business leader, that means you now have two options: wait for someone else to run AI-assisted vulnerability detection against your attack surface, or run it yourself first.</p>
</blockquote>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p>There’s plenty of claims that AI Vibe Coding can replace software developers, something that folks like me (perhaps with a bias) think unlikely. <a href="https://bsky.app/profile/gergely.pragmaticengineer.com/post/3m75kmb7bh22i">Gergely Orosz</a> shared this tidbit</p>

<blockquote>
  <p>Talked with an exec at a tech company who is obsessed with AI and has been for 3 years. Not a developer but company makes software. Uses AI for everything, vibe codes ideas.</p>

  <p>Here’s the kicker:</p>

  <p>Has a team of several devs to implement his vibe coded prototypes to sg workable</p>
</blockquote>

<p>I’d love to hear more about this (and similar stories)</p>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p><a href="https://checkeagle.com/checklists/njr/a-month-of-chat-oriented-programming/">Nick Radcliffe</a> writes about a month of using AI</p>

<blockquote>
  <p>I spent a solid month “pair programming” with Claude Code, trying to suspend disbelief and adopt a this-will-be-productive mindset. More specifically, I got Claude to write well over 99% of the code produced during the month. I found the experience infuriating, unpleasant, and stressful before even worrying about its energy impact. Ideally, I would prefer not to do it again for at least a year or two. The only problem with that is that it “worked”.</p>
</blockquote>

<p>He stresses that his approach is the “polar opposite” of Vibe Coding. The post is long, and rambles a bit, but is worthwhile because he talks in detail about his workflow and how he uses the tool. Such posts are important so we can learn the nitty-gritty of how our programming habits are changing.</p>

<p> ❄                ❄                ❄                ❄                ❄</p>

<p>Along similar lines is a post of <a href="https://brianchambers.substack.com/p/chamber-of-tech-secrets-55-issue">Brian Chambers</a> on his workflow, that he calls Issue-Driven Development (and yes, I’m also sick of the “something-driven” phraseology). As with much of the better stuff I’ve heard about AI assisted work, it’s all about carefully managing the context window, ensuring the AI is focused on the right things and not distracted by textual squirrels.</p>



---

**ISO Date:** 2025-12-04T15:59:00.000Z