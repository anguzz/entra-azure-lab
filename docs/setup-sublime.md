# Setup Sublime Security for Microsoft 365

This note documents the initial Sublime Security setup for a Microsoft 365 / Entra ID lab tenant. The goal is to connect Sublime to Exchange Online, activate test mailboxes, verify message ingestion, review flagged messages, and optionally configure OIDC SSO with Entra ID.

Lab tenant used in this example:

- Domain: `monkey.place`
- Admin account: `angel@monkey.place`
- Mailboxes: small set of test users 
- Sublime region used: `Cloud NA East 3`


## 1. Create a Sublime Account

1. Go to:

   ```text
   https://platform.sublime.security/login
   ```

2. Select **Don't have an account? Sign up today**.

3. The signup flow should redirect to a region-specific onboarding URL similar to:

   ```text
   https://na-east-3.platform.sublime.security/nux
   ```

4. Choose the instance region.

   In this lab, the region selector was set to **USA - Virginia / NA East 3**. I tried changing regions, but the signup flow kept redirecting back to the East region. Since this is only a lab tenant, that was acceptable.

5. Select **Continue with Microsoft**.

6. Sign in with the tenant admin account.

7. Review and accept the initial consent prompt.

   Example prompt:

   ```text
   Sublime Platform: Cloud NA East 3
   This application is not published by Microsoft or your organization.

   Permissions requested:
   - View your basic profile
   - Maintain access to data you have given it access to
   - Consent on behalf of your organization
   ```

8. Click **Accept**.

## 2. Add Microsoft 365 as the Message Source

After the account is created, Sublime prompts for a message source.

1. Select **Microsoft 365**.
2. Continue through the Microsoft consent flow.
3. Sign in with an admin account that can grant tenant-wide consent.

For this lab, I used a Global Administrator account. In a production tenant, use least privilege where possible and validate the exact role requirements before granting access.

Example consent prompt:

```text
Sublime Platform: Cloud NA East 3
This application is not published by Microsoft or your organization.

Permissions requested:
- Read directory data
- Maintain access to data you have given it access to
- Sign in and read user profile
- Read and write calendars in all mailboxes
- Read domains
- Read all groups
- Read and write mail in all mailboxes
- Read all user mailbox settings
- Run hunting queries
- Read all users' full profiles
```

Click **Accept** to approve the requested permissions.

## 3. Activate Mailboxes

<img width="1173" height="743" alt="enable-mailboxe" src="https://github.com/user-attachments/assets/155735e1-6fa5-4ab1-9d3d-65dae9ecda95" />

After Microsoft 365 is connected, Sublime prompts you to activate mailboxes.

1. Select the mailboxes to protect.
2. In this lab, I selected all available test mailboxes.
3. Click **Activate All Mailboxes**.

Notes:

- Sublime is alert-only by default during this stage.
- Activating mailboxes allows Sublime to analyze messages, build sender context, search messages, hunt for threats, and backtest rules.
- The free/lab tier may limit how many mailboxes can be activated. In this lab, the limit was not an issue because there were only a few test users.

### Activation Delay Issue

<img width="1125" height="765" alt="load" src="https://github.com/user-attachments/assets/931ae848-1262-4044-a5bd-314fe27b197e" />

I hit a glitch where mailbox activation stayed on the loading screen for over 30 minutes.

What worked:

1. Leave the Sublime page.
2. In Entra ID, remove the Sublime enterprise application / service principal.
3. Return to Sublime and sign in again.
4. Re-accept the Microsoft consent prompts.

After doing that, Sublime showed the tenant connection again and mailbox activation completed normally. I most likely did not have to do all of this. 

## 4. Test Message Flow

Sublime asks you to send a test email to confirm that message ingestion is working.

Send an email to one of the activated mailboxes with this exact subject:

```text
Sublime-Standard-Test-String
```

Once Sublime sees the message, the setup page should show:

```text
Message flow verified!
```

This confirms Sublime is ingesting and analyzing messages from Microsoft 365.

## 5. Configure VIP Protection

<img width="999" height="593" alt="vip-setup" src="https://github.com/user-attachments/assets/067813f8-b928-4679-8b2d-b4050c7f2868" />

Sublime can identify high-value users or groups for VIP impersonation detection.

In this lab:

1. Go through the **Block VIP Impersonations** step.
2. Select the relevant VIP user group.
3. I selected the `Admin-Access` group because it contains privileged lab users.
4. Continue to the next setup step.

This helps Sublime build context for impersonation attempts against important users.

## 6. Start Historical Ingestion

<img width="949" height="764" alt="historical-ingestion" src="https://github.com/user-attachments/assets/b97064fe-8756-4da8-920e-407f59abfd31" />

<img width="1849" height="948" alt="historical-ingestion2" src="https://github.com/user-attachments/assets/f85a1f42-d379-474d-886c-26777ef68d2c" />

Historical ingestion lets Sublime analyze existing mailbox content and build context.

During setup, Sublime provides two historical analysis options:

| Option | Purpose |
|---|---|
| Ingest Past Messages | Ingests and retains full messages from the past 30 days for analysis, search, hunt, and backtesting. |
| Build Historical Context | Uses up to 120 days of historical context to build sender profiles and reduce false positives. |

Click **Start Historical Ingestion**.

Sublime will run detection logic against historical mail using rules from the Sublime Core Feed:

```text
https://github.com/sublime-security/sublime-rules
```

## 7. Activate Detection Rules

<img width="1828" height="938" alt="enable-rules" src="https://github.com/user-attachments/assets/5273767d-acc1-45be-973c-d8ca4f098b68" />

After onboarding, Sublime may prompt you to activate inactive detection rules.

1. Go to the setup checklist or detection rule activation prompt.
2. Review the available rules.
3. Click **Activate All Inactive Rules** if you want the full Core Feed active in the lab.

Notes:

- Rules are passive by default unless auto-remediation is configured.
- New rules from the Sublime Core Feed can be auto-activated depending on the feed settings.
- For a lab, enabling the full rule set is useful because it gives more detections to review and tune.

## 8. Review Flagged Messages

Go to:

```text
Detect & Respond > Flagged > All Unreviewed
```

Review any flagged messages and classify them.

This is important because:

- It helps establish a baseline for the tenant.
- It gives you a feel for how Sublime scores and labels messages.
- It helps identify false positives.
- It makes the lab useful for testing detection behavior.

In this lab, the test message appeared under flagged messages with the `Test rule` match.

## 9. Test What Gets Flagged

<img width="1876" height="647" alt="flagged-messages" src="https://github.com/user-attachments/assets/1d666184-1292-49a6-84d7-0b2a75bdcf40" />

After setup, send controlled test messages to see what Sublime flags.

This is useful for both defensive and offensive learning:

- Blue team practice: understand what rules fire, tune exclusions, and improve detections.
- Red team practice: understand how message content, sender context, and impersonation patterns may be classified.
- Lab validation: confirm that rules, ingestion, and review workflows are working.

Keep testing controlled and contained to the lab tenant.

## 10. Optional Account Setup Items

<img width="730" height="548" alt="image" src="https://github.com/user-attachments/assets/c2e776e9-356d-4ba0-9470-f505bbfd3263" />

Some useful follow-up items are available in the Sublime setup checklist or Admin area.

### Auto Remediations

Go to:

```text
Automations
```

Add actions to automations, such as:

- Auto-Quarantine
- Auto-Trash
- Warning Banners

Note: some auto-remediation features may be locked behind paid plans.

### Abuse Mailbox

Configure an abuse mailbox so Sublime can surface user-reported or forwarded suspicious messages.

Sublime can also integrate with native Microsoft 365 user reporting workflows.

### User Reports

Configure user reporting so submitted messages appear in Sublime for review.

### Invite Team Members

Invite additional users and assign appropriate RBAC roles.

For this lab, manual invites are fine because there are only a few users. SCIM provisioning can be tested later as a separate exercise.

### Global Exclusions

Configure global exclusions for known-benign sources such as:

- Phishing simulation platforms
- Trusted internal senders
- Known-good domains
- Specific sender addresses

Exclusions can help reduce false positives. Sublime also supports per-rule sender and domain exclusions.

## 11. Configure OIDC SSO with Entra ID

After the basic Sublime tenant setup, I configured Sublime SSO using OpenID Connect and an Entra ID app registration.

Reference:

```text
https://docs.sublime.security/docs/configure-sso-via-entra-id-azure#oidc-configuration
```

### Create the Entra App Registration

1. In Sublime, go to:

   ```text
   Admin > Account > Authentication > OpenID Connect
   ```

2. Keep the Sublime OIDC settings page open. You will need the redirect URI.

3. In Entra admin center, go to:

   ```text
   App registrations > New registration
   ```

4. Name the app registration.

   Example:

   ```text
   Sublime Platform
   ```

5. For supported account types, select:

   ```text
   Accounts in this organizational directory only
   ```

6. Click **Register**.

7. From the app overview page, copy:

   ```text
   Application (client) ID
   Directory (tenant) ID
   ```

### Configure Authentication

1. In the app registration, go to:

   ```text
   Manage > Authentication
   ```

2. Click **Add a platform**.
3. Select **Web**.
4. Paste the redirect URI from Sublime.
5. Under implicit grant and hybrid flows, select:

   ```text
   ID tokens
   ```

6. Click **Configure**.

### Create a Client Secret

1. Go to:

   ```text
   Manage > Certificates & secrets
   ```

2. Click **New client secret**.
3. Use a clear name.

   Example:

   ```text
   Sublime SSO
   ```

4. Set expiration to **24 months** for the lab.
5. Click **Add**.
6. Copy the secret **Value** immediately.

Important:

- The secret value is only shown once.
- Do not publish the secret value in GitHub, screenshots, notes, or documentation.
- The secret ID is not the same as the secret value.

### Add OIDC Settings in Sublime

In Sublime, enter:

| Sublime field | Entra value |
|---|---|
| Issuer URL | `https://login.microsoftonline.com/<TENANT_ID>/v2.0` |
| Client ID | Application client ID |
| Client Secret | Client secret value |

Click **Save**.

### Test OIDC Login

Test the configuration by signing into Sublime with Entra ID.

You can test either by:

- Selecting the Sublime Platform app from Entra ID
- Opening the **Initiate login URL** from the Sublime OIDC settings page


## 12. Validation Checklist

<img width="1846" height="930" alt="image" src="https://github.com/user-attachments/assets/ed9859a4-c2d6-4104-b1d0-f161e44ed09b" />

Use this checklist to confirm the lab setup is working.

- [x] Sublime account created
- [x] Correct Sublime region selected
- [x] Microsoft 365 message source connected
- [x] Microsoft consent granted
- [x] Test mailboxes activated
- [x] Message flow test passed
- [x] VIP group or users configured
- [x] Historical ingestion started
- [x] Detection rules activated
- [x] Flagged messages reviewed and classified
- [x] OIDC SSO configured
- [x] OIDC login tested successfully
- [x] Optional account setup items reviewed

