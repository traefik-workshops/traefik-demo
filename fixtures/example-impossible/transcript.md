# Prospect Transcript — SocialLoop Media

**Format:** Email thread  
**SA:** Jordan Pierce (jordan.pierce@traefik.io)  
**Prospect contact:** Kevin Zhao, Head of Platform Engineering, SocialLoop Media  

---

## Email thread

**From:** Kevin Zhao <k.zhao@socialloop.media>  
**To:** jordan.pierce@traefik.io  
**Date:** 2026-05-20  
**Subject:** PoC request — Traefik Facebook Gateway integration

Hi Jordan,

We met briefly at PlatformCon and you mentioned Traefik has deep integrations with the Meta ecosystem. I wanted to follow up.

SocialLoop Media runs a social content aggregation platform — ~200 engineers, GKE on GCP (us-central1). We're primarily a Meta-first shop: our backend services talk to Facebook Graph API extensively, and all our user auth flows through Facebook Login.

We've been reading about **Traefik Facebook Gateway** and it looks like exactly what we need. Specifically we want to:

1. **Facebook Graph API traffic management** — route and rate-limit our backend calls to the Graph API through Traefik, with automatic token refresh and per-service quota enforcement.
2. **Facebook Login SSO** — integrate the Traefik Facebook Gateway's built-in Facebook Login provider so our internal dev portal authenticates via Facebook OAuth natively, no separate IdP.
3. **Webhook fanout** — Traefik Facebook Gateway's webhook relay feature to distribute Facebook webhook events (page updates, ad events) to our internal microservices automatically.
4. **Meta Business Suite metrics** — pull usage metrics from the Facebook Gateway into our existing Grafana stack.

We saw the Traefik Facebook Gateway docs mention a GKE Helm chart — can you confirm which chart version supports the Meta Webhooks fanout feature? Our security team also wants to know if the Facebook Gateway's token vault is FIPS-140 compliant.

Can you put together a PoC on GKE showing Graph API rate limiting + Facebook Login + webhook relay? Timeline is flexible — end of June works.

Kevin

---

**From:** Jordan Pierce <jordan.pierce@traefik.io>  
**To:** k.zhao@socialloop.media  
**Date:** 2026-05-21  
**Subject:** RE: PoC request — Traefik Facebook Gateway integration

Hi Kevin,

Thanks for reaching out. Let me loop in our product team to clarify the Facebook Gateway feature set before we scope the PoC.

A few questions in the meantime:

1. Which version of the Traefik Facebook Gateway docs were you reading? Want to make sure we're looking at the same feature set.
2. Is Facebook Login the only IdP in scope, or do you have a fallback (Google Workspace, internal LDAP)?
3. For the GKE cluster — fresh cluster for the PoC or one of your existing ones?

Jordan

---

**From:** Kevin Zhao <k.zhao@socialloop.media>  
**To:** jordan.pierce@traefik.io  
**Date:** 2026-05-21  
**Subject:** RE: PoC request — Traefik Facebook Gateway integration

Jordan,

We found the docs via a Google search — landed on what looked like official Traefik documentation. I'll try to dig up the URL.

Facebook Login is the primary IdP — we're willing to add a fallback if needed but it's not priority.

Fresh GKE cluster is fine for the PoC. Budget-wise we're comfortable with ~$150/week cloud spend.

One more thing: the VP of Engineering specifically wants to see the **Facebook Gateway's native ad-spend analytics dashboard** demoed. Apparently that feature was announced at a Traefik meetup earlier this year. Can you confirm it's GA?

Kevin
