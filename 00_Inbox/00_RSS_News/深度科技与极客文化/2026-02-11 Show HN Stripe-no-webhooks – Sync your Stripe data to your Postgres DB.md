# Show HN: Stripe-no-webhooks – Sync your Stripe data to your Postgres DB

**Author:** prasoonds
**Published:** Tue, 10 Feb 2026 17:14:48 +0000
**Link:** https://github.com/pretzelai/stripe-no-webhooks
**GUID:** https://news.ycombinator.com/item?id=46963177
**Tags:** 

---

## Summary

Hey HN, stripe-no-webhooks is an open-source library that syncs your Stripe payments data to your own Postgres database:
https://github.com/pretzelai/stripe-no-webhooks.
Here's a demo video: https://youtu.be/cyEgW7wElcs
Why is this useful? (1) You don't have to figure out which webhooks you need or write listeners for each one. The library handles all of that. This follows the approach of libraries like dj-stripe in the Django world (https://dj-stripe.dev/). (2) Stripe's API has a 100 rpm rate limit. If you're checking subscription status frequently or building internal tools, you'll hit it. Querying your own Postgres doesn't have this problem. (3) You can give an AI agent read access to the stripe.* schema to debug payment issues—failed charges, refunds, whatever—without handing over Stripe dashboard access. (4) You can join Stripe data with your own tables for custom analytics, LTV calculations, etc.
It creates a webhook endpoint in your Stripe account to forward webhooks to your backend where a webhook listener stores all the data into a new stripe.* schema. You define your plans in TypeScript, run a sync command, and the library takes care of creating Stripe products and prices, handling webhooks, and keeping your database in sync. We also let you backfill your Stripe data for existing accounts.
It supports pre-paid usage credits, account wallets and usage-based billing. It also lets you generate a pricing table component that you can customize. You can access the user information using the simple API the library provides:
  billing.subscriptions.get({ userId });
  billing.credits.consume({ userId, key: "api_calls", amount: 1 });
  billing.usage.record({ userId, key: "ai_model_tokens_input", amount: 4726 });

Let's see how it works with a quick example. Say you have a billing plan like Cursor (the IDE) used to have: $20/mo, you get 500 API completions + 2000 tab completions, you can buy additional API credits, and any additional usage is billed as overage.
You define your plan in TypeScript:
  {
    name: "Pro",
    description: "Cursor Pro plan",
    price: [{ amount: 2000, currency: "usd", interval: "month" }],
    features: {
      api_completion: {
        pricePerCredit: 1,              // 1 cent per unit
        trackUsage: true,               // Enable usage billing
        credits: { allocation: 500 },
        displayName: "API Completions",
      },
      tab_completion: {
        credits: { allocation: 2000 },
        displayName: "Tab Completions",
      },
    },
  }

Consume code would look like this:
  await billing.credits.consume({
    userId: user.id,
    key: "api_completion",
    amount: 1,
  });

  await billing.credits.topUp({
    userId: user.id,
    key: "api_completion",
    amount: 500,     // buy 500 credits, charges $5.00
  });

This would be a lot of work to implement by yourself on top of Stripe. You need to keep track of all of these entitlements in your own DB and deal with renewals, expiry, ad-hoc grants, etc. It's definitely doable, especially with AI coding, but you'll probably end up building something fragile and hard to maintain.
This is just a high-level overview of what the library is capable of. It also supports seat-level credits, monetary wallets (with micro-cent precision), auto top-ups, robust failure recovery, tax collection, invoices, and an out-of-the-box pricing table.
I vibe-coded a little toy app for testing: https://snw-test.vercel.app. There's no validation so feel free to sign up with a dummy email, then subscribe to a plan with a test card: 4242 4242 4242 4242, any future expiry, any 3-digit CVV.
Screenshot: https://imgur.com/a/demo-screenshot-Rh6Ucqx
Feel free to try it out! If you end up using this library, please report any bugs on the repo. If you're having trouble / want to chat, I'm happy to help - my contact is in my HN profile.
Comments URL: https://news.ycombinator.com/item?id=46963177
Points: 50
# Comments: 19

---

## Content


<p>Hey HN, stripe-no-webhooks is an open-source library that syncs your Stripe payments data to your own Postgres database:
<a href="https://github.com/pretzelai/stripe-no-webhooks" rel="nofollow">https://github.com/pretzelai/stripe-no-webhooks</a>.<p>Here's a demo video: <a href="https://youtu.be/cyEgW7wElcs" rel="nofollow">https://youtu.be/cyEgW7wElcs</a><p>Why is this useful? (1) You don't have to figure out which webhooks you need or write listeners for each one. The library handles all of that. This follows the approach of libraries like dj-stripe in the Django world (<a href="https://dj-stripe.dev/" rel="nofollow">https://dj-stripe.dev/</a>). (2) Stripe's API has a 100 rpm rate limit. If you're checking subscription status frequently or building internal tools, you'll hit it. Querying your own Postgres doesn't have this problem. (3) You can give an AI agent read access to the stripe.* schema to debug payment issues—failed charges, refunds, whatever—without handing over Stripe dashboard access. (4) You can join Stripe data with your own tables for custom analytics, LTV calculations, etc.<p>It creates a webhook endpoint in your Stripe account to forward webhooks to your backend where a webhook listener stores all the data into a new <i>stripe.*</i> schema. You define your plans in TypeScript, run a sync command, and the library takes care of creating Stripe products and prices, handling webhooks, and keeping your database in sync. We also let you backfill your Stripe data for existing accounts.<p>It supports pre-paid usage credits, account wallets and usage-based billing. It also lets you generate a pricing table component that you can customize. You can access the user information using the simple API the library provides:<p><pre><code>  billing.subscriptions.get({ userId });
  billing.credits.consume({ userId, key: "api_calls", amount: 1 });
  billing.usage.record({ userId, key: "ai_model_tokens_input", amount: 4726 });
</code></pre>
Effectively, you don't have to deal with either the Stripe dashboard or the Stripe API/SDK any more if you don't want to. The library gives you a nice abstraction on top of Stripe that should cover ~most subscription payment use-cases.<p>Let's see how it works with a quick example. Say you have a billing plan like Cursor (the IDE) used to have: $20/mo, you get 500 API completions + 2000 tab completions, you can buy additional API credits, and any additional usage is billed as overage.<p>You define your plan in TypeScript:<p><pre><code>  {
    name: "Pro",
    description: "Cursor Pro plan",
    price: [{ amount: 2000, currency: "usd", interval: "month" }],
    features: {
      api_completion: {
        pricePerCredit: 1,              // 1 cent per unit
        trackUsage: true,               // Enable usage billing
        credits: { allocation: 500 },
        displayName: "API Completions",
      },
      tab_completion: {
        credits: { allocation: 2000 },
        displayName: "Tab Completions",
      },
    },
  }
</code></pre>
Then on the CLI, you run the `init` command which creates the DB tables + some API handlers. Run `sync` to sync the plans to your Stripe account and create a webhook endpoint. When a subscription is created, the library automatically grants the 500 API completion credits and 2000 tab completion credits to the user. Renewals and up/downgrades are handled sanely.<p>Consume code would look like this:<p><pre><code>  await billing.credits.consume({
    userId: user.id,
    key: "api_completion",
    amount: 1,
  });
</code></pre>
And if they want to allow manual top-ups by the user:<p><pre><code>  await billing.credits.topUp({
    userId: user.id,
    key: "api_completion",
    amount: 500,     // buy 500 credits, charges $5.00
  });
</code></pre>
Similarly, we have APIs for wallets and usage.<p>This would be a lot of work to implement by yourself on top of Stripe. You need to keep track of all of these entitlements in your own DB and deal with renewals, expiry, ad-hoc grants, etc. It's definitely doable, especially with AI coding, but you'll probably end up building something fragile and hard to maintain.<p>This is just a high-level overview of what the library is capable of. It also supports seat-level credits, monetary wallets (with micro-cent precision), auto top-ups, robust failure recovery, tax collection, invoices, and an out-of-the-box pricing table.<p>I vibe-coded a little toy app for testing: <a href="https://snw-test.vercel.app" rel="nofollow">https://snw-test.vercel.app</a>. There's no validation so feel free to sign up with a dummy email, then subscribe to a plan with a test card: 4242 4242 4242 4242, any future expiry, any 3-digit CVV.<p>Screenshot: <a href="https://imgur.com/a/demo-screenshot-Rh6Ucqx" rel="nofollow">https://imgur.com/a/demo-screenshot-Rh6Ucqx</a><p>Feel free to try it out! If you end up using this library, please report any bugs on the repo. If you're having trouble / want to chat, I'm happy to help - my contact is in my HN profile.</p>
<hr>
<p>Comments URL: <a href="https://news.ycombinator.com/item?id=46963177">https://news.ycombinator.com/item?id=46963177</a></p>
<p>Points: 50</p>
<p># Comments: 19</p>


---

**ISO Date:** 2026-02-10T17:14:48.000Z