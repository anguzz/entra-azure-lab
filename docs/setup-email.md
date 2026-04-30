# Exchange Online Email Setup (M365 Lab)

**Purpose:** Configure and validate email (mailboxes, DNS, and basic Exchange settings) in the tenant.

---

## Pre-req

Before you can give email, I went ahead and had to buy licenses.

Because I'm cheap and broke, I got a few **Exchange Online (Plan 1)** for me and some buddies I want to add to the domain so they can mess around.

---

## Assigning Licenses

To assign these licenses you gotta go to:  
https://admin.cloud.microsoft/?referrer=entra#/users  

Trying it in other places throws an error.

Then click on a user, which brings up a blade.  
Go to **Licenses**, add the license, and save changes.

---

## Internal Mail Test

This will make it so you can email each other internally.

After this, we sent each other a few emails and saw it was working, which was fun.

---

## External Email Issue

But I noticed that inbound/outbound wouldn’t work and got an error when emailing an external email along the lines of: 

```
Your message wasn't delivered because the recipient's email provider rejected it.

mx.google.com gave this error:
Your email has been blocked because the sender is unauthenticated. Gmail requires all senders to authenticate with either SPF or DKIM. Authentication results: DKIM = did not pass SPF [monkey.place] = did not pass
```

---

## Next Steps

So my next steps are to set up **DKIM** and **SPF** in `setup-dkim-spf.md`.

