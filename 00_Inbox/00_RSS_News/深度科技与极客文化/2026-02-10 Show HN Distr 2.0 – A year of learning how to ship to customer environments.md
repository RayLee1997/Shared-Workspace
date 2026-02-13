# Show HN: Distr 2.0 – A year of learning how to ship to customer environments

**Author:** louis_w_gk
**Published:** Tue, 10 Feb 2026 12:19:23 +0000
**Link:** https://github.com/distr-sh/distr
**GUID:** https://news.ycombinator.com/item?id=46958742
**Tags:** 

---

## Summary

A year ago, we launched Distr here to help software vendors manage customer deployments remotely. We had agents that pulled updates, a hub with a GUI, and a lot of assumptions about what on-prem deployment needed.
It turned out things get messy when your software is running in places you can't simply SSH into.
Over the last year, we’ve also helped modernize a lot of home-baked solutions: bash scripts that email when updates fail, Excel sheets nobody trusts to track customer versions, engineers driving to customer sites to fix things in person, debug sessions over email (“can you take a screenshot of the logs and send it to me?”), customers with access to internal AWS or GCP registries because there was no better option, and deployments two major versions behind that nobody wants to touch.
We waited a year before making our first breaking change, which led to a major SemVer update—but it was eventually necessary. We needed to completely rewrite how we manage customer organizations. In Distr, we differentiate between vendors and customers. A vendor is typically the author of a software / AI application that wants to distribute it to customers. Previously, we had taken a shortcut where every customer was just a single user who owned a deployment. We’ve now introduced customer organizations. Vendors onboard customer organizations onto the platform, and customers own their internal user management, including RBAC. This change obviously broke our API, and although the migration for our cloud customers was smooth, custom solutions built on top of our APIs needed updates.
Other notable features we’ve implemented since our first launch:
- An OCI container registry built on an adapted version of https://github.com/google/go-containerregistry/, directly embedded into our codebase and served via a separate port from a single Docker image. This allows vendors to distribute Docker images and other OCI artifacts if customers want to self-manage deployments.
- License Management to restrict which customers can access which applications or artifact versions. Although “license management” is a broadly used term, the main purpose here is to codify contractual agreements between vendors and customers. In its simplest form, this is time-based access to specific software versions, which vendors can now manage with Distr.
- Container logs and metrics you can actually see without SSH access. Internally, we debated whether to use a time-series database or store all logs in Postgres. Although we had to tinker quite a bit with Postgres indexes, it now runs stably.
- Secret Management, so database passwords don’t show up in configuration steps or logs.
Distr is now used by 200+ vendors, including Fortune 500 companies, across on-prem, GovCloud, AWS, and GCP, spanning health tech, fintech, security, and AI companies. We’ve also started working on our first air-gapped environment.
For Distr 3.0, we’re working on native Terraform / OpenTofu and Zarf support to provision and update infrastructure in customers’ cloud accounts and physical environments—empowering vendors to offer BYOC and air-gapped use cases, all from a single platform.
Distr is fully open source and self-hostable: https://github.com/distr-sh/distr
Docs: https://distr.sh/docs
We’re YC S24. Happy to answer questions about on-prem deployments and would love to hear about your experience with complex customer deployments.
Comments URL: https://news.ycombinator.com/item?id=46958742
Points: 48
# Comments: 13

---

## Content


<p>A year ago, we launched Distr here to help software vendors manage customer deployments remotely. We had agents that pulled updates, a hub with a GUI, and a lot of assumptions about what on-prem deployment needed.<p>It turned out things get messy when your software is running in places you can't simply SSH into.<p>Over the last year, we’ve also helped modernize a lot of home-baked solutions: bash scripts that email when updates fail, Excel sheets nobody trusts to track customer versions, engineers driving to customer sites to fix things in person, debug sessions over email (“can you take a screenshot of the logs and send it to me?”), customers with access to internal AWS or GCP registries because there was no better option, and deployments two major versions behind that nobody wants to touch.<p>We waited a year before making our first breaking change, which led to a major SemVer update—but it was eventually necessary. We needed to completely rewrite how we manage customer organizations. In Distr, we differentiate between vendors and customers. A vendor is typically the author of a software / AI application that wants to distribute it to customers. Previously, we had taken a shortcut where every customer was just a single user who owned a deployment. We’ve now introduced customer organizations. Vendors onboard customer organizations onto the platform, and customers own their internal user management, including RBAC. This change obviously broke our API, and although the migration for our cloud customers was smooth, custom solutions built on top of our APIs needed updates.<p>Other notable features we’ve implemented since our first launch:<p>- An OCI container registry built on an adapted version of <a href="https://github.com/google/go-containerregistry/" rel="nofollow">https://github.com/google/go-containerregistry/</a>, directly embedded into our codebase and served via a separate port from a single Docker image. This allows vendors to distribute Docker images and other OCI artifacts if customers want to self-manage deployments.<p>- License Management to restrict which customers can access which applications or artifact versions. Although “license management” is a broadly used term, the main purpose here is to codify contractual agreements between vendors and customers. In its simplest form, this is time-based access to specific software versions, which vendors can now manage with Distr.<p>- Container logs and metrics you can actually see without SSH access. Internally, we debated whether to use a time-series database or store all logs in Postgres. Although we had to tinker quite a bit with Postgres indexes, it now runs stably.<p>- Secret Management, so database passwords don’t show up in configuration steps or logs.<p>Distr is now used by 200+ vendors, including Fortune 500 companies, across on-prem, GovCloud, AWS, and GCP, spanning health tech, fintech, security, and AI companies. We’ve also started working on our first air-gapped environment.<p>For Distr 3.0, we’re working on native Terraform / OpenTofu and Zarf support to provision and update infrastructure in customers’ cloud accounts and physical environments—empowering vendors to offer BYOC and air-gapped use cases, all from a single platform.<p>Distr is fully open source and self-hostable: <a href="https://github.com/distr-sh/distr" rel="nofollow">https://github.com/distr-sh/distr</a><p>Docs: <a href="https://distr.sh/docs">https://distr.sh/docs</a><p>We’re YC S24. Happy to answer questions about on-prem deployments and would love to hear about your experience with complex customer deployments.</p>
<hr>
<p>Comments URL: <a href="https://news.ycombinator.com/item?id=46958742">https://news.ycombinator.com/item?id=46958742</a></p>
<p>Points: 48</p>
<p># Comments: 13</p>


---

**ISO Date:** 2026-02-10T12:19:23.000Z