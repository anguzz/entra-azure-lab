# Action1 Community Tenant Setup
 
Setting up Action1 community edition with Microsoft Entra ID SSO for shared endpoint management across the PKI lab environment.
 
## Account Creation
 
Navigate to [action1.com/signup](https://www.action1.com/signup-continue) to create your Action1 account.
 
**Account Details:**
- **Email:** angel@monkey.place
- **Tenant:** Monkey Place (configured during signup)
- **Region:** Global: North America
---
 
## Single Sign-On Configuration with Entra ID
 
### Initial Setup
 
To enable SSO with Entra ID:
 
1. Log in to Action1 using your initial non-SSO credentials
2. Navigate to **Advanced** → **Identity Provider**
3. Specify **Entra ID** as the identity provider
4. Keep the scope set to **Enterprise**
This establishes the tenant-level connection to your Entra ID tenant.
 
**Reference:** [Action1 SSO Authentication with Entra ID](https://www.action1.com/documentation/sso-authentication-with-entra-id/)
 
### Enterprise App Registration
 
When an invited user attempts to log in via SSO, they will be prompted to accept Graph API permissions. This creates an enterprise application registration in your Entra ID tenant.
 
**Permissions Requested:**
 
```
Sign in and read user profile
 
Allows users to sign-in to the app, and allows the app to read the profile of 
signed-in users. It also allows the app to read basic company information of 
signed-in users.
 
This is a permission requested to access your data in Monkey Place.
```
 
**Important:** Only users with Entra ID admin privileges can grant these permissions. If a standard user attempts to accept the permissions, they will receive an access denied error. Have an Entra ID admin accept the permissions on behalf of the organization.
 
---
 
## User Invitation & SSO Login
 
### Inviting Users
 
Navigate to the **Users** section and select **+ Invite**:
 
1. **Identity Provider:** Select **Entra ID**
2. **Email:** Enter the user's **primary email address** from Entra ID (copy from Properties → Email, not aliases)
3. **Scope:** Link to **"My enterprise"** (tenant-wide access)
4. **Role:** Assign appropriate role (e.g., **Enterprise admin** for co-admins)
**Critical:** The user's UPN (User Principal Name) in Entra ID must match the primary email used in the Action1 invitation; if they differ, update the UPN in Entra ID to match before inviting.
 
### Mailbox Requirement
 
Users must have an active Entra ID mailbox (Exchange Online) in order to authenticate via SSO. Without a mailbox, SSO authentication will fail because Action1 looks up user metadata via Exchange.
 
**Resolution:** Assign a Microsoft 365 license to the user account in the Entra admin center. The mailbox typically provisions within a few minutes to an hour.
 
### First Login Flow
 
1. User receives invitation email
2. User sets their password on first login
3. User returns to Action1 and selects **Login with Entra ID**
4. User is redirected to Microsoft login
5. User may be prompted to accept app permissions (admin consent required)
6. User is logged in to Action1
---
 
## Agent Installation
 
Deploy the Action1 agent to Windows and Linux endpoints for unattended endpoint management.
 
### Windows (Silent Installation)
 
```batch
curl -o "action1_agent(Monkey_Place).msi" "https://app.na-2.action1.com/agent/{tenantID}/Windows/agent(Monkey_Place).msi" && msiexec /i "action1_agent(Monkey_Place).msi" /quiet /qn
```
 
**Parameters:**
- `/quiet` – Run silently
- `/qn` – No UI displayed
### Linux (RPM-based systems)
 
```bash
p="/tmp" && curl -o "${p}/action1_agent(Monkey_Place).rpm" "https://app.na-2.action1.com/agent/{tenantID}/Linux/agent(Monkey_Place).rpm" && sudo dnf -y install "${p}/action1_agent(Monkey_Place).rpm"
```
 
**Steps:**
1. Download RPM to `/tmp`
2. Install using DNF
3. Agent starts automatically post-install
---
 
## Next Steps
 
- [ ] Verify SSO login works for all invited users
- [ ] Deploy agents to AD DC and NDES VMs once provisioned
- [ ] Configure patch management policies
- [ ] Set up endpoint monitoring and alerting
- [ ] Link to Tailscale for remote management access
---
 
## References
 
- [Action1 SSO Authentication Documentation](https://www.action1.com/documentation/sso-authentication-with-entra-id/)
- [Action1 Free Edition](https://www.action1.com/free-edition/)
- [Action1 Users and Roles](https://www.action1.com/documentation/users-and-roles/)
 

## Screenshots.
I installed it on two of my virtual machines, one that desperately needs patches deployed against it through action1.
(windows 10 LTSC don't hate)


<img width="1823" height="922" alt="image" src="https://github.com/user-attachments/assets/b5021223-dbf0-4468-b2e4-1babf6e0aaf2" />

