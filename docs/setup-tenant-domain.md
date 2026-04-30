# M365 / Entra Tenant Domain Setup

**Purpose:** Configure custom domain, users, roles, and Exchange Online mailboxes in a personal lab tenant.

---

First I wanted a cool custom name, so I went and bought **monkey.place**. This would be a great place to add some users and start messing around.

I purchased this domain, then went to Microsoft tenant administration:
https://admin.cloud.microsoft/?#/Domains

From there, I clicked **`Add domain`**.

---

## Domain Verification

Once you add a domain, Microsoft makes you add a TXT record in your registrar.

Since I like Vercel (preference + comfort, and I might add a site later with GitHub Actions), this was my choice.

On Vercel, I added the TXT record:

```

TXT name: @
TXT value: MS=ms#######
TTL: 3600

```

Then I hit **Verify** and went ahead with the next steps to create the domain.

---

## User Creation

After that, I created a few users under the domain.

*not actual names*

- user1@monkey.place  
- user2@monkey.place  
- etc  
- etc

I then gave them some rbac permissions like reader and corresponding admin roles to their Interests and job related skills (security admin, cloud admin, etc) 


# buy licensing
https://admin.cloud.microsoft/?referrer=entra#/licenses

billing> your products
https://admin.cloud.microsoft/?referrer=entra#/catalog
