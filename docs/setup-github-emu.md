# GitHub EMU

Setting up GitHub EMU with Microsoft Entra ID via OIDC.

To start, I created a new GitHub account to test this. My concern was that doing this on my main account might prevent me from starting another trial later, but after testing, it appears the trial option is still available even after verification.

Account name:

`angelmonkeyplace`

Go to:

[Create GitHub EMU Enterprise Trial](https://github.com/account/enterprises/new?users_type=enterprise_managed)

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

***

# Admin Login

Once you receive the emails, you should set up the admin account.

Trying to log in with the account that created the enterprise will not work and will result in a 404.

Instead:

1. Log in with the setup admin account.
2. Set the password.
3. Sign in to GitHub using the admin account.

After logging in as `mnkp_admin`, I could see the GitHub Enterprise and start configuring the identity provider.

***

# IDP Setup

## SCIM Setup

When generating the SCIM token, GitHub uses a Personal Access Token (PAT) with the `scim:enterprise` scope enabled.

I left the defaults and selected **Create Token**.

Example:

```text
tokenxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

After that, I enabled Single Sign-On.

Navigate to:

**Single Sign-On > OIDC**

Since the gallery application we imported is specifically for OIDC, this is the option we want.

When enabling OIDC, GitHub asks for a consent flow on behalf of the organization. During this process, recovery codes are generated and should be downloaded and saved.

Afterward, you should see the Enterprise Application created in Entra ID.

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

***

# Provisioning

After provisioning is configured, you can either:

* Provision users on demand
* Assign groups and provision users through application assignments

In my lab environment I do not have Entra P1/P2 licensing, so I used direct user assignments and provisioned users individually.

I added several users with different roles, provisioned them, and verified the changes in the GitHub Enterprise portal.

***

# Exploring Options in GitHub Enterprise

## Teams

Navigate to:

**People > Enterprise Teams**

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

Selecting **Add Azure Subscription** starts a consent flow and prompts you to select:

* Azure Tenant
* Azure Subscription

This links GitHub billing to the Azure subscription.

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

