# GitHub EMU

Setting up GitHub EMU with Microsoft Entra ID via OIDC.

To start, I created a new GitHub account to test this. My concern was that doing this on my main account might prevent me from starting another trial later, but after testing, it appears the trial option is still available even after verification.

Account name:

`angelmonkeyplace`

Go to:


***

# EMU Trial Sign Up

You will be prompted for an enterprise name, URL slug, and username shortcode.

**Enterprise Name:** `Monkey Place`

**Enterprise URL Slug:** `monkey-place`

**Username Shortcode:** `mnkp`

**Number of Employees:** `0-50`

> "When you create an enterprise with managed users on GitHub.com, you choose a shortcode that will be used as the suffix for all your enterprise members' usernames."

This shortcode affects your setup admin username. It has an 8-character maximum, a 3-character minimum, and must be unique.

I originally tried `mp`, but it was already taken, so I used `mnkp`.

My setup admin user was created as:

`mnkp_admin`

Additional information requested during setup:

* Identity Provider: `Microsoft Entra ID`
* Industry
* Number of Employees
* Country/Region
* Primary Identity Provider
* Admin contact information
<img width="735" height="884" alt="01-github-emu-setup" src="https://github.com/user-attachments/assets/839af255-8cce-40bb-a6c1-cc5abce76c1b" />

<img width="588" height="707" alt="02-success-created" src="https://github.com/user-attachments/assets/f68651d9-de45-4c50-b464-8e21e09c0593" />

***

# Admin Login


Once you receive the emails, you should set up the admin account.

<img width="1283" height="769" alt="03email2" src="https://github.com/user-attachments/assets/409c94d3-bcfe-4124-bd8d-53f4d5c56d7f" />
<img width="1276" height="741" alt="04-email1" src="https://github.com/user-attachments/assets/80493bf6-a77e-49a4-bbdd-30a217db79e1" />


Trying to log in with the account that created the enterprise will not work and will result in a 404.

Instead:

1. Log in with the setup admin account.
2. Set the password.
3. Sign in to GitHub using the admin account.

After logging in as `mnkp_admin`, I could see the GitHub Enterprise and start configuring the identity provider.

***

# IDP Setup

<img width="1914" height="754" alt="05github-in-1" src="https://github.com/user-attachments/assets/2c15d1a7-8ccd-492b-9a72-67f8431ac8a2" />

## SCIM Setup

When generating the SCIM token, GitHub uses a Personal Access Token (PAT) with the `scim:enterprise` scope enabled.

I left the defaults and selected **Create Token**.

Example:

```text
tokenxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
<img width="1237" height="899" alt="06-SCIM" src="https://github.com/user-attachments/assets/e3852489-410f-4802-acb4-f72e9bf5cd3f" />

After that, I enabled Single Sign-On.

Navigate to:

**Single Sign-On > OIDC**
<img width="1901" height="628" alt="07-SSO-OIDC" src="https://github.com/user-attachments/assets/24b962a5-4b07-4c83-b4e2-8ce0d49478d1" />

Since the gallery application we imported is specifically for OIDC, this is the option we want.

When enabling OIDC, GitHub asks for a consent flow on behalf of the organization. During this process, recovery codes are generated and should be downloaded and saved.

<img width="553" height="691" alt="08-consent" src="https://github.com/user-attachments/assets/a1878644-a15a-4c0e-aa65-0c3ac8b37ab7" />

Afterward, you should see the Enterprise Application created in Entra ID.

<img width="1366" height="596" alt="09-github-oidc" src="https://github.com/user-attachments/assets/4ed2b670-55b2-4bcf-a137-def8ad6ac2dd" />

At this point, continue with the Microsoft documentation:

[GitHub Enterprise Managed User OIDC Provisioning Tutorial](https://learn.microsoft.com/en-gb/entra/identity/saas-apps/github-enterprise-managed-user-oidc-provisioning-tutorial#step-5-configure-automatic-user-provisioning-to-github-enterprise-managed-user-oidc)

Navigate to the newly imported Entra application and select:

**Provisioning**

Configure:

**Tenant URL**

```text
https://api.github.com/scim/v2/enterprises/monkey-place
```

**Secret Token**

Use the SCIM token generated earlier.

Select **Test Connection** and verify it succeeds before saving.

<img width="1616" height="887" alt="10-provision-setup" src="https://github.com/user-attachments/assets/3ed29308-a1e1-45d3-bcde-8c0bd21668e6" />

***

# Provisioning

After provisioning is configured, you can either:

* Provision users on demand
* Assign groups and provision users through application assignments

In my lab environment I do not have Entra P1/P2 licensing, so I used direct user assignments and provisioned users individually.

I added a few users with different roles, provisioned them, and verified the changes in the GitHub Enterprise portal.

<img width="1906" height="902" alt="12-users-added" src="https://github.com/user-attachments/assets/f159f28d-329b-4173-bc56-96a8b5636857" />


<img width="1853" height="874" alt="14image" src="https://github.com/user-attachments/assets/b8886333-2490-438e-8522-339a9b4d401f" />

Once you provision a few users via SCIM, the setup should be completed, all that's left is to switch to your new owner account. 

<img width="1913" height="872" alt="15-completed-setup" src="https://github.com/user-attachments/assets/965f3ff7-1b56-42e6-a9f5-bbf0ee907467" />

***

# Exploring Options in GitHub Enterprise

## Teams

Navigate to:

**People > Enterprise Teams**
<img width="954" height="804" alt="16-teams" src="https://github.com/user-attachments/assets/b5bf7dd8-5714-42c6-95c8-33defadac218" />


You can create a test team and associate it with one or more organizations.

When creating a team, you can configure:

* Team Name
* Description
* Team Access (Organization)
* Direct Members or IdP Group
* Notification Settings

***

## Enterprise Roles

Enterprise roles provide access to enterprise-wide settings and functionality.

GitHub includes several predefined roles, and you can also create custom roles.

***

## Organization Roles

Organization roles grant permissions within individual organizations and repositories.

Repository permissions apply across repositories within that organization.

***

## Differences

Enterprise roles apply to the entire enterprise and control enterprise-wide administration.

Organization roles apply only within a specific organization and its repositories.

Think of the enterprise as the outer container that contains one or more organizations.

***

## Identity Provider

The Identity Provider section contains:

* OIDC settings
* Enable SSO login
* Enforce SSO for all users except enterprise owners

***

## Policies

The Policies section contains a large number of controls including:

* Code
* Code Insights
* Actions
* Member Privileges
* Codespaces
* Sandboxes
* Hosted Compute Networking
* Projects
* Advanced Security
* Code Quality
* License Compliance
* Personal Access Tokens

This is where you can restrict things such as:

* Repository creation
* Forking repositories
* Adding external collaborators
* Hosted compute networking configuration

It is definitely worth reviewing once your EMU environment is running.

Many of these policies determine what organization owners are allowed to configure versus what remains controlled at the enterprise level.

***

## Billing and Licensing

Navigate to:

**Billing & Licensing > Payment Information**

After adding your billing and shipping information, you can add:

* Payment Method
* Azure Subscription

<img width="1916" height="897" alt="18-azure-sub" src="https://github.com/user-attachments/assets/77b4bd17-0e1d-42db-8404-8f769ca1c169" />

Selecting **Add Azure Subscription** starts a consent flow and prompts you to select:

<img width="527" height="621" alt="19-azure-sub2" src="https://github.com/user-attachments/assets/718b7bab-064d-480f-9aaa-4fa6af98a9d0" />


your Azure Tenant and Azure Subscription

<img width="516" height="304" alt="20-azure-sub" src="https://github.com/user-attachments/assets/3b4a801c-209a-4db9-9e95-d41d21fa04ce" />


This all links GitHub billing to the Azure subscription.

Once configured, you can manage Copilot licensing under:

**Billing & Licensing > Licensing > Copilot > Manage**

This allows you to:

* Sync Entra groups to Enterprise Teams
* Assign Copilot licenses to teams
* Control Copilot features across organizations

***

# References

* [GitHub Enterprise Server SSO Tutorial](https://learn.microsoft.com/en-us/entra/identity/saas-apps/github-enterprise-server-tutorial#adding-github-enterprise-server-from-the-gallery)
* [GitHub Enterprise Managed User SCIM Provisioning Tutorial](https://learn.microsoft.com/en-us/entra/identity/saas-apps/github-enterprise-managed-user-provisioning-tutorial)
* [GitHub Enterprise Managed User OIDC Provisioning Tutorial](https://learn.microsoft.com/en-gb/entra/identity/saas-apps/github-enterprise-managed-user-oidc-provisioning-tutorial#step-5-configure-automatic-user-provisioning-to-github-enterprise-managed-user-oidc)

***

# Additional Documentation

### Username Considerations for Managed Users

[GitHub Documentation](https://docs.github.com/en/enterprise-cloud@latest/admin/managing-iam/iam-configuration-reference/username-considerations-for-external-authentication#about-usernames-for-managed-user-accounts)

### SCIM Provisioning Configuration

[GitHub Documentation](https://docs.github.com/en/enterprise-cloud@latest/admin/managing-iam/provisioning-user-accounts-with-scim/configuring-scim-provisioning-for-users)

### Microsoft Entra OIDC Provisioning Guide

[Microsoft Documentation](https://learn.microsoft.com/en-us/entra/identity/saas-apps/github-enterprise-managed-user-oidc-provisioning-tutorial)

