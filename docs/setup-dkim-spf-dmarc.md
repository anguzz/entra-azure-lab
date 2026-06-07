# Setting Up DKIM and SPF

**Purpose:** Add the DNS records needed for Microsoft 365 email authentication.

---

## SPF Setup

On Vercel, I went ahead and added the SPF TXT record.

```shell
Type: TXT
Name: @
Value: v=spf1 include:spf.protection.outlook.com -all
TTL: 3600
```

This record tells other mail systems that Microsoft 365 is allowed to send email for my domain.

---

## DKIM Setup

DKIM was kind of weird because I could not find it in Exchange Online where I expected it to be.

I ended up finding it in Microsoft Defender:

```shell
https://security.microsoft.com/authentication?viewid=DKIM
```

From there, I selected my custom domain and tried to hit the **Enable** button, but I got an error saying the DKIM CNAME records did not exist yet.

The error basically said I needed to publish two CNAME records first:

```shell
selector1._domainkey
selector2._domainkey
```

So now in Vercel, I have to add the DKIM CNAME records that Microsoft gives me.

Example format:

```shell
Name: selector1._domainkey
Type: CNAME
Value: selector1-<domain-values>._domainkey.<tenant-values>.e-v1.dkim.mail.microsoft
TTL: 60
```

```shell
Name: selector2._domainkey
Type: CNAME
Value: selector2-<domain-values>._domainkey.<tenant-values>.e-v1.dkim.mail.microsoft
TTL: 60
```

---

## Waiting for DNS

Microsoft also says:

```
If you have already published the CNAME records, sync will take a few minutes to as many as 4 days based on your specific DNS. Return and retry this step later.
```


## DKIM Enabled


After adding the two DKIM CNAME records in Vercel, I waited like 10 minutes then it  I checked DNS with PowerShell periodically and after it resolved i enabled it.

```powershell
Resolve-DnsName -Name "selector1._domainkey.<domain>" -Type CNAME
Resolve-DnsName -Name "selector2._domainkey.<domain>" -Type CNAME
```




# Adding DMARC 

I verified that inbound and outbound worked but it seems that my emails were going to spam, most likely since it was a fairly new domain and mailbox. This is when I had to add a DMARC record in vercel.

```shell
Type: TXT
Name: _dmarc
Value: v=DMARC1; p=none
TTL: 3600
```

That DMARC record tells receiving mail servers check whether mail claiming to be from my domain passes SPF or DKIM alignment, but don’t block anything yet.


After I set DMARC up it went right to the inbox not junk/spam.


## DMARC Policy Update

Changed DMARC from monitor-only mode:

```shell
v=DMARC1; p=none;
```

to an enforced quarantine policy:

```shell
v=DMARC1; p=quarantine; pct=100
```


The previous `p=none` policy only monitored DMARC results and did not instruct receiving mail servers to take action when messages failed DMARC. This meant spoofed or unauthenticated email claiming to be from `monkey.place` could still be accepted normally by recipient mail systems.

The new `p=quarantine` policy tells receiving mail servers to treat messages that fail DMARC as suspicious and tend to place them in spam/junk instead of the inbox.

`pct=100` means the quarantine policy applies to 100% of messages that fail DMARC.


This change improves domain spoofing protection while avoiding the stricter `p=reject` policy for now. It provides stronger enforcement than `p=none` while still allowing failed messages to be quarantined instead of fully rejected.




# Reference

https://learn.microsoft.com/en-us/defender-office-365/email-authentication-dkim-configure

