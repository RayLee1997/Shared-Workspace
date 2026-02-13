# There’s a Hidden Preference to Auto-Resize Columns in the Finder on MacOS 14 and 15

**Author:** 
**Published:** 2026-01-26T23:18:37.000Z
**Link:** https://forums.realmacsoftware.com/t/auto-resizing-columns-in-finder/52435
**GUID:** 
**Tags:** 

---

## Summary

Good tip from “DifferentDan” on the Realmac customer forum, posted back in November:
I saw on macOS Tahoe 26.1, Apple finally added an option in the
Column View settings to automatically right size all columns
individually and that setting would persist, but I don’t really
like Liquid Glass (yet) so I haven’t updated to Tahoe.
Looks like someone found a workaround however for those that are
still on Sequoia. Just open up Terminal on your Mac, copy in the
below, and press return.
The one-line command:
defaults write com.apple.finder _FXEnableColumnAutoSizing -bool YES; killall Finder

(Change YES to NO if you want to go back.)
Marcel Bresink’s TinkerTool is a great free app for adjusting hidden preferences using a proper GUI, and it turns out TinkerTool has exposed this hidden Finder preference for a few years now. You learn something every day. I enabled this a few days ago on MacOS 15 Sequoia, and it seems exactly like the implementation Apple has exposed in the Finder’s View Options window in Tahoe, which I wrote about Friday. No better, no worse.
 ★

---

## Content


<p>Good tip from “DifferentDan” on the Realmac customer forum, posted back in November:</p>

<blockquote>
  <p>I saw on macOS Tahoe 26.1, Apple finally added an option in the
Column View settings to automatically right size all columns
individually and that setting would persist, but I don’t really
like Liquid Glass (yet) so I haven’t updated to Tahoe.</p>

<p>Looks like someone found a workaround however for those that are
still on Sequoia. Just open up Terminal on your Mac, copy in the
below, and press return.</p>
</blockquote>

<p>The one-line command:</p>

<pre><code>defaults write com.apple.finder _FXEnableColumnAutoSizing -bool YES; killall Finder
</code></pre>

<p>(Change <code>YES</code> to <code>NO</code> if you want to go back.)</p>

<p>Marcel Bresink’s <a href="http://www.bresink.com/osx/TinkerTool.html">TinkerTool</a> is a great free app for adjusting hidden preferences using a proper GUI, and it turns out TinkerTool has exposed this hidden Finder preference for a few years now. You learn something every day. I enabled this a few days ago on MacOS 15 Sequoia, and it seems exactly like the implementation Apple has exposed in the Finder’s View Options window in Tahoe, <a href="https://daringfireball.net/2026/01/resize_columns_to_fit_filenames">which I wrote about Friday</a>. No better, no worse.</p>

<div>
<a  title="Permanent link to ‘There’s a Hidden Preference to Auto-Resize Columns in the Finder on MacOS 14 and 15’"  href="https://daringfireball.net/linked/2026/01/26/hidden-pref-column-resizing">&nbsp;★&nbsp;</a>
</div>

	

---

**ISO Date:** 2026-01-26T23:18:37.000Z