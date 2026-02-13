# Show HN: Itsyhome – Control HomeKit from your Mac menu bar (open source)

**Author:** nixus76
**Published:** Tue, 10 Feb 2026 22:31:12 +0000
**Link:** https://itsyhome.app
**GUID:** https://news.ycombinator.com/item?id=46967898
**Tags:** 

---

## Summary

Hey HN!
Nick here – developer of Itsyhome, a menu bar app for macOS that gives you control over your whole HomeKit fleet (and very soon Home Assistant). I run 130+ HomeKit devices at home and the Home app was too heavy for quick adjustments.
Full HomeKit support, favourites, hidden items, device groups, pinning of rooms/accessories/groups as separate menu bar items, iCloud sync – all in a native experience and tiny package.
Open source (https://github.com/nickustinov/itsyhome-macos) and free to use (there is an optional one-time purchase for a Pro version which includes cameras and automation features).
Itsyhome is a Mac Catalyst app because HomeKit requires the iOS SDK, so it runs a headless Catalyst process for HomeKit (and now Home Assistant) access while using a native AppKit plugin over a bridge protocol to provide the actual menu bar UI – since AppKit gives you the real macOS menu bar experience that Catalyst alone can't.
It comes with deeplink support, a webhook server, a CLI tool (golang, all open source), a Stream Deck plugin (open source, all accessories supported), and the recent update also includes an SSE event stream (HomeKit and HA) - you can curl -N localhost:8423/events and get a real-time JSON stream of every device state change in your home.
Home Assistant version is still in beta – would anyone be willing to test it via TestFlight?
Appreciate any feedback and happy to answer any questions.
Comments URL: https://news.ycombinator.com/item?id=46967898
Points: 33
# Comments: 37

---

## Content


<p>Hey HN!<p>Nick here – developer of Itsyhome, a menu bar app for macOS that gives you control over your whole HomeKit fleet (and very soon Home Assistant). I run 130+ HomeKit devices at home and the Home app was too heavy for quick adjustments.<p>Full HomeKit support, favourites, hidden items, device groups, pinning of rooms/accessories/groups as separate menu bar items, iCloud sync – all in a native experience and tiny package.<p>Open source (<a href="https://github.com/nickustinov/itsyhome-macos" rel="nofollow">https://github.com/nickustinov/itsyhome-macos</a>) and free to use (there is an optional one-time purchase for a Pro version which includes cameras and automation features).<p>Itsyhome is a Mac Catalyst app because HomeKit requires the iOS SDK, so it runs a headless Catalyst process for HomeKit (and now Home Assistant) access while using a native AppKit plugin over a bridge protocol to provide the actual menu bar UI – since AppKit gives you the real macOS menu bar experience that Catalyst alone can't.<p>It comes with deeplink support, a webhook server, a CLI tool (golang, all open source), a Stream Deck plugin (open source, all accessories supported), and the recent update also includes an SSE event stream (HomeKit and HA) - you can curl -N localhost:8423/events and get a real-time JSON stream of every device state change in your home.<p>Home Assistant version is still in beta – would anyone be willing to test it via TestFlight?<p>Appreciate any feedback and happy to answer any questions.</p>
<hr>
<p>Comments URL: <a href="https://news.ycombinator.com/item?id=46967898">https://news.ycombinator.com/item?id=46967898</a></p>
<p>Points: 33</p>
<p># Comments: 37</p>


---

**ISO Date:** 2026-02-10T22:31:12.000Z