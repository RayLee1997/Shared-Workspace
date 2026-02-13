# Show HN: Algorithmically Finding the Longest Line of Sight on Earth

**Author:** tombh
**Published:** Mon, 09 Feb 2026 10:05:55 +0000
**Link:** https://alltheviews.world
**GUID:** https://news.ycombinator.com/item?id=46943568
**Tags:** 

---

## Summary

We're Tom and Ryan and we teamed up to build an algorithm with Rust and SIMD to exhaustively search for the longest line of sight on the planet. We can confirm that a previously speculated view between Pik Dankova in Kyrgyzstan and the Hindu Kush in China is indeed the longest, at 530km.
We go into all the details at https://alltheviews.world
And there's an interactive map with over 1 billion longest lines, covering the whole world at https://map.alltheviews.world Just click on any point and it'll load its longest line of sight.
Some of you may remember Tom's post[1] from a few months ago about how to efficiently pack visibility tiles for computing the entire planet. Well now it's done. The compute run itself took 100s of AMD Turin cores, 100s of GBs of RAM, a few TBs of disk and 2 days of constant runtime on multiple machines.
If you are interested in the technical details, Ryan and I have written extensively about the algorithm and pipeline that got us here:
* Tom's blog post: https://tombh.co.uk/longest-line-of-sight
* Ryan's technical breakdown: https://ryan.berge.rs/posts/total-viewshed-algorithm
This was a labor of love and we hope it inspires you both technically and naturally, to get you out seeing some of these vast views for yourselves!
1. https://news.ycombinator.com/item?id=45485227
Comments URL: https://news.ycombinator.com/item?id=46943568
Points: 253
# Comments: 102

---

## Content


<p>We're Tom and Ryan and we teamed up to build an algorithm with Rust and SIMD to exhaustively search for the longest line of sight on the planet. We can confirm that a previously speculated view between Pik Dankova in Kyrgyzstan and the Hindu Kush in China is indeed the longest, at 530km.<p>We go into all the details at <a href="https://alltheviews.world" rel="nofollow">https://alltheviews.world</a><p>And there's an interactive map with over 1 billion longest lines, covering the whole world at <a href="https://map.alltheviews.world" rel="nofollow">https://map.alltheviews.world</a> Just click on any point and it'll load its longest line of sight.<p>Some of you may remember Tom's post[1] from a few months ago about how to efficiently pack visibility tiles for computing the entire planet. Well now it's done. The compute run itself took 100s of AMD Turin cores, 100s of GBs of RAM, a few TBs of disk and 2 days of constant runtime on multiple machines.<p>If you are interested in the technical details, Ryan and I have written extensively about the algorithm and pipeline that got us here:<p>* Tom's blog post: <a href="https://tombh.co.uk/longest-line-of-sight" rel="nofollow">https://tombh.co.uk/longest-line-of-sight</a><p>* Ryan's technical breakdown: <a href="https://ryan.berge.rs/posts/total-viewshed-algorithm" rel="nofollow">https://ryan.berge.rs/posts/total-viewshed-algorithm</a><p>This was a labor of love and we hope it inspires you both technically and naturally, to get you out seeing some of these vast views for yourselves!<p>1. <a href="https://news.ycombinator.com/item?id=45485227">https://news.ycombinator.com/item?id=45485227</a></p>
<hr>
<p>Comments URL: <a href="https://news.ycombinator.com/item?id=46943568">https://news.ycombinator.com/item?id=46943568</a></p>
<p>Points: 253</p>
<p># Comments: 102</p>


---

**ISO Date:** 2026-02-09T10:05:55.000Z