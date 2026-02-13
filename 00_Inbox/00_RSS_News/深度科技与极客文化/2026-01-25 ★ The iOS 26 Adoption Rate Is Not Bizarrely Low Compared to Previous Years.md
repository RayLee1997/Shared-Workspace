# ★ The iOS 26 Adoption Rate Is Not Bizarrely Low Compared to Previous Years

**Author:** 
**Published:** 2026-01-25T00:14:52.000Z
**Link:** https://daringfireball.net/2026/01/ios_26_adoption_rate_is_not_bizarrely_low
**GUID:** 
**Tags:** 

---

## Summary

A few weeks ago there were a rash of stories claiming that iOS 26 is seeing bizarrely low adoption rates from iPhone users. The methodology behind these numbers is broken and the numbers are totally wrong. Those false numbers are so low, so jarringly different from previous years, that it boggles my mind that they didn’t raise a red flag for anyone who took a moment to consider them.
The ball started rolling with this post from Ed Hardy at Cult of Mac on January 8, “iOS 26 Still Struggles to Gain Traction With iPhone Users”, which began:
Only a tiny percentage of iPhone users have installed iOS 26,
according to data from a web analytics service. The adoption rate
is far less than previous iOS versions at this same point months
after their releases. The data only reveals how few iPhone users
run Apple’s latest operating system upgrade, not why they’ve
chosen to avoid it. But the most likely candidate is the new
Liquid Glass look of the update. [...]
Roughly four months after launching in mid-September, only about
15% of iPhone users have some version of the new operating system
installed. That’s according to data for January 2026 from
StatCounter. Instead, most users hold onto previous versions.
For comparison, in January 2025, about 63% of iPhone users had
some iOS 18 version installed. So after roughly the same
amount of time, the adoption rate of Apple [sic] newest OS was
about four times higher.
Those links point to Statcounter, a web analytics service. A lot of websites include Statcounter’s analytics tracker, and Statcounter’s tracker attempts to determine the version of the OS each visitor’s device is running. The problem is, starting with Safari 26 — the version that ships with iOS 26 — Safari changed how it reports its user agent string. From the WebKit blog, “WebKit Features in Safari 26.0”:
Also, now in Safari on iOS, iPadOS, and visionOS 26 the user agent
string no longer lists the current version of the operating
system. Safari 18.6 on iOS has a UA string of:
Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X)
AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6
Mobile/15E148 Safari/604.1
And Safari 26.0 on iOS has a UA string of:
Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X)
AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0
Mobile/15E148 Safari/604.1
This matches the long-standing behavior on macOS, where the user
agent string for Safari 26.0 is:
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)
AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0
Safari/605.1.15
It was back in 2017 when Safari on Mac first started freezing the
Mac OS string. Now the behavior on iOS, iPadOS, and visionOS does
the same in order to minimize compatibility issues. The WebKit and
Safari version number portions of the string will continue to
change with each release.
In other words, Safari now reports, in its user agent string, that it’s running on iOS 18.6 when it is running on iOS 18.6, and reports that it’s running on iOS 18.6 when it’s running on iOS 26.0 or later. And it’s going to keep reporting that it’s running on iOS 18.6 forever, just like how Safari 26 on MacOS reports that it’s running on MacOS 10.15 Catalina, from 2019.
Statcounter completely dropped the ball on this change, and it explains the entirety of this false narrative that iOS 26 adoption is incredibly low. (Statcounter has a “detect” page where you can see what browser and OS it thinks you’re using.) The reason they reported that 15 percent of iPhone users were using iOS 26 is probably because that’s the amount of web traffic Statcounter sees from iOS 26 web browsers that aren’t Safari (most of which, I’ll bet, are in-app browser views in social media apps).
Nick Heer, at Pixel Envy, wrote a good piece delving into this saga. And then he posted a follow-up item pointing out that (a) Statcounter’s CEO has acknowledged their error and they’re fixing it; and (b) Wikimedia publishes network-wide stats that serve as a good baseline. The audience for Wikipedia is, effectively, the audience for the web itself. And Wikipedia’s stats show that while iOS 26 adoption, in January 2026, isn’t absurdly low (as Statcounter had been suggesting, erroneously, and writers like Ed Hardy at Cult of Mac and David Price at Macworld foolishly regurgitated, no matter how little sense it made that the numbers would be that low), they are in fact lower than those for iOS 18 a year ago and iOS 17 two years ago. Per Wikimedia:
iOS 26, January 2026: 50%
iOS 18, January 2025: 72%
iOS 17, January 2024: 65%
So, no, iOS 26 adoption isn’t at just 15 percent, which only a dope would believe, but it’s not as high as previous iOS versions in previous years at this point on the calendar. Something, obviously, is going on.
David Smith, developer of popular apps like Widgetsmith and Pedometer++, on Mastodon:
I noticed iOS 26 adoption had entered a ‘third wave’ of rapid
adoption. So I made a graph of the relative adoption versus iOS 18
at this point in the release cycle.
While lower than iOS 18 at this point for my apps (65% vs. 78%),
the shape of this graph says to me that Apple is in full control
of the adoption rate and can tune it to their plans. The
coordinated surges are Apple dialing up automatic updates.
If this surge were as long as previous ones, we’d hit the
saturation point very soon.

 
What’s going on, quite obviously, is that Apple itself is slow-rolling the automatic updates to iOS 26. For years now Apple has steered users, via default suggestions during device setup, to adopt settings to allow OS updates to happen automatically, including updates to major new versions. Apple tends not to push these automatic updates to major new versions of iOS until two months after the .0 release in September. This year that second wave was delayed by about two weeks, and there’s now a third wave starting midway through January. It’s a different pattern from previous years — but it’s a pattern Apple controls. A large majority of users of all Apple devices get major OS updates when, and only when, their devices automatically update. Apple has been slower to push those updates to iOS 26 than they have been for previous iOS updates in recent years. With good reason! iOS 26 is a more significant — and buggier — update than iOS 18 and 17 were.
People like you, readers of Daring Fireball, may well be hesitant to update to iOS 26, or (like me) to MacOS 26, or to any of the version 26 OS updates, because you are aware of things (like UI changes) that you are loath to adopt.
But the overwhelming majority of Apple users — especially iPhone users — just let their devices update automatically. They might like iOS 26’s changes, they might dislike them, or they might not care or even notice. But they just let their software updates happen automatically — and they will form the entirety of their opinions regarding iOS 26 after it’s running on their iPhones.

---

## Content


<p>A few weeks ago there were a rash of stories claiming that iOS 26 is seeing bizarrely low adoption rates from iPhone users. The methodology behind these numbers is broken and the numbers are totally wrong. Those false numbers are so low, so jarringly different from previous years, that it boggles my mind that they didn’t raise a red flag for anyone who took a moment to consider them.</p>

<p>The ball started rolling with this post from Ed Hardy at Cult of Mac on January 8, “<a href="https://www.cultofmac.com/news/ios-26-adoption-struggles-with-iphone-users">iOS 26 Still Struggles to Gain Traction With iPhone Users</a>”, which began:</p>

<blockquote>
  <p>Only a tiny percentage of iPhone users have installed iOS 26,
according to data from a web analytics service. The adoption rate
is far less than previous iOS versions at this same point months
after their releases. The data only reveals how few iPhone users
run Apple’s latest operating system upgrade, not why they’ve
chosen to avoid it. But the most likely candidate is the new
Liquid Glass look of the update. [...]</p>

<p>Roughly four months after launching in mid-September, <a href="https://gs.statcounter.com/ios-version-market-share/mobile-tablet/worldwide/#monthly-202601-202601-bar">only about
15% of iPhone users have some version of the new operating system
installed</a>. That’s according to data for January 2026 from
StatCounter. Instead, most users hold onto previous versions.</p>

<p>For comparison, in January 2025, about <a href="https://gs.statcounter.com/ios-version-market-share/mobile-tablet/worldwide/#monthly-202501-202501-bar">63% of iPhone users had
some iOS 18 version</a> installed. So after roughly the same
amount of time, the adoption rate of Apple [<em>sic</em>] newest OS was
about four times higher.</p>
</blockquote>

<p>Those links point to Statcounter, a web analytics service. A lot of websites include Statcounter’s analytics tracker, and Statcounter’s tracker attempts to determine the version of the OS each visitor’s device is running. The problem is, starting with Safari 26 — the version that ships with iOS 26 — Safari changed how it reports its user agent string. From the WebKit blog, “<a href="https://webkit.org/blog/17333/webkit-features-in-safari-26-0/">WebKit Features in Safari 26.0</a>”:</p>

<blockquote>
  <p>Also, now in Safari on iOS, iPadOS, and visionOS 26 the user agent
string no longer lists the current version of the operating
system. Safari 18.6 on iOS has a UA string of:</p>

<p><code>Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X)
AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6
Mobile/15E148 Safari/604.1</code></p>

<p>And Safari 26.0 on iOS has a UA string of:</p>

<p><code>Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X)
AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0
Mobile/15E148 Safari/604.1</code></p>

<p>This matches the long-standing behavior on macOS, where the user
agent string for Safari 26.0 is:</p>

<p><code>Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)
AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0
Safari/605.1.15</code></p>

<p>It was back in 2017 when Safari on Mac first started freezing the
Mac OS string. Now the behavior on iOS, iPadOS, and visionOS does
the same in order to minimize compatibility issues. The WebKit and
Safari version number portions of the string will continue to
change with each release.</p>
</blockquote>

<p>In other words, Safari now reports, in its user agent string, that it’s running on iOS 18.6 when it is running on iOS 18.6, and reports that it’s running on iOS 18.6 <em>when it’s running on iOS 26.0 or later</em>. And it’s going to keep reporting that it’s running on iOS 18.6 forever, just like how Safari 26 on MacOS reports that it’s running on MacOS 10.15 Catalina, from 2019.</p>

<p>Statcounter completely dropped the ball on this change, and it explains the entirety of this false narrative that iOS 26 adoption is incredibly low. (Statcounter has a <a href="https://gs.statcounter.com/detect">“detect” page</a> where you can see what browser and OS it thinks you’re using.) The reason they reported that 15 percent of iPhone users were using iOS 26 is probably because that’s the amount of web traffic Statcounter sees from iOS 26 web browsers that aren’t Safari (most of which, I’ll bet, are in-app browser views in social media apps).</p>

<p>Nick Heer, at Pixel Envy, <a href="https://pxlnv.com/blog/updating-the-record-on-ios-26/">wrote a good piece delving into this saga</a>. And then he <a href="https://pxlnv.com/linklog/ios-26-usage-updates/">posted a follow-up item</a> pointing out that (a) Statcounter’s CEO has acknowledged their error and they’re fixing it; and (b) Wikimedia publishes network-wide stats that serve as a good baseline. The audience for Wikipedia is, effectively, the audience for the web itself. And Wikipedia’s stats show that while iOS 26 adoption, in January 2026, isn’t absurdly low (as Statcounter had been suggesting, erroneously, and writers like <a href="https://www.cultofmac.com/news/ios-26-adoption-struggles-with-iphone-users">Ed Hardy at Cult of Mac</a> and <a href="https://www.macworld.com/article/3022985/ios-26s-failure-shows-what-happens-when-you-take-customers-for-granted.html">David Price</a> <a href="https://www.macworld.com/article/3028428/ios-26-is-a-massive-flop-with-iphone-users-and-you-can-probably-guess-why.html">at Macworld</a> foolishly regurgitated, no matter how little sense it made that the numbers would be <em>that</em> low), they are in fact lower than those for iOS 18 a year ago and iOS 17 two years ago. Per Wikimedia:</p>

<ul>
<li>iOS 26, January 2026: 50%</li>
<li>iOS 18, January 2025: 72%</li>
<li>iOS 17, January 2024: 65%</li>
</ul>

<p>So, no, iOS 26 adoption isn’t at just 15 percent, which only a dope would believe, but it’s not as high as previous iOS versions in previous years at this point on the calendar. Something, obviously, is going on.</p>

<p>David Smith, developer of popular apps like <a href="https://apps.apple.com/us/app/widgetsmith/id1523682319">Widgetsmith</a> and <a href="https://apps.apple.com/us/app/pedometer/id712286167">Pedometer++</a>, <a href="https://mastodon.social/@_Davidsmith/115932682921860872">on Mastodon</a>:</p>

<blockquote>
  <p>I noticed iOS 26 adoption had entered a ‘third wave’ of rapid
adoption. So I made a graph of the relative adoption versus iOS 18
at this point in the release cycle.</p>

<p>While lower than iOS 18 at this point for my apps (65% vs. 78%),
the shape of this graph says to me that Apple is in full control
of the adoption rate and can tune it to their plans. The
coordinated surges are Apple dialing up automatic updates.</p>

<p>If this surge were as long as previous ones, we’d hit the
saturation point very soon.</p>

<p><a href="https://mastodon.social/@_Davidsmith/115932682921860872" class="noborder">
 <img
  src = "https://daringfireball.net/misc/2026/01/david-smith-ios-v26-v18-adoption.png"
  alt = "Chart of iOS 26 vs. iOS 18 adoption, day-by-day after each version was released."
  width = 500
 /></a></p>
</blockquote>

<p>What’s going on, quite obviously, is that Apple itself is slow-rolling the automatic updates to iOS 26. For years now Apple has steered users, via default suggestions during device setup, to adopt settings to allow OS updates to happen automatically, including updates to major new versions. Apple tends not to push these automatic updates to major new versions of iOS until two months after the .0 release in September. This year that second wave was delayed by about two weeks, and there’s now a third wave starting midway through January. It’s a different pattern from previous years — but it’s a pattern Apple controls. A large majority of users of all Apple devices get major OS updates when, and only when, their devices automatically update. Apple has been slower to push those updates to iOS 26 than they have been for previous iOS updates in recent years. With good reason! iOS 26 is a more significant — and buggier — update than iOS 18 and 17 were.</p>

<p>People like <em>you</em>, readers of Daring Fireball, may well be hesitant to update to iOS 26, or (<a href="https://daringfireball.net/2026/01/resize_columns_to_fit_filenames">like me</a>) to MacOS 26, or to any of the version 26 OS updates, because you are aware of things (like UI changes) that you are loath to adopt.</p>

<p>But the overwhelming majority of Apple users — especially iPhone users — just let their devices update automatically. They might like iOS 26’s changes, they might dislike them, or they might not care or even notice. But they just let their software updates happen automatically — and they will form the entirety of their opinions regarding iOS 26 after it’s running on their iPhones.</p>



    

---

**ISO Date:** 2026-01-25T00:14:52.000Z