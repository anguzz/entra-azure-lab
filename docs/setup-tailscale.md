# Tailscale Setup for Homelab Remote Access

Setting up Tailscale with Microsoft Entra ID as the identity provider to enable secure remote access to your Proxmox homelab infrastructure.

## Overview

Tailscale creates an encrypted overlay network (tailnet) that connects your devices and lab infrastructure. By integrating it with Entra ID, I enabled multiple homelabber admins from my tenant to securely access Proxmox without exposing management interfaces to the internet.

---

## Step 1: Entra Global/Cloud admin creates a Tailscale Account with Entra ID Integration

1. Go to [tailscale.com](https://tailscale.com) and sign up for a new account
2. During signup, select **Microsoft Entra ID** as your identity provider
3. You'll be prompted to grant Tailscale permission to your Entra ID tenant
4. Log in with your global admin account and accept the Graph API permissions
   - Tailscale requires read access to your Entra ID user directory
5. Once authenticated, you're logged into the Tailscale admin console

**Result:** You now have a tailnet (your personal Tailscale network) connected to your Entra ID tenant.

<img width="1829" height="922" alt="image" src="https://github.com/user-attachments/assets/f2fbafa3-32c6-48d5-93c7-34b1075c0dcc" />


<img width="1583" height="701" alt="image" src="https://github.com/user-attachments/assets/c03d6874-b867-49e9-b611-4e79e89bb062" />

---

## Step 2: Tailscale admin Invite Users to the Tailnet

1. In the Tailscale admin console, navigate to **Users**
2. Click **Invite users** → **Send invites**
3. Enter the co-admin's Entra ID email address
4. Select role: **Member** (default; they can manage their own devices)
5. Send the invite

The user receives an email invitation with a link. When they click it and authenticate with their Entra ID credentials, they're added to your tailnet.

<img width="521" height="446" alt="image" src="https://github.com/user-attachments/assets/e39db222-1a30-40f9-a96b-c5910a38551c" />

<img width="1547" height="742" alt="image" src="https://github.com/user-attachments/assets/1316f453-66fe-4382-b531-fd8724ac8021" />

---

## Step 3: Proxmox admin installs Tailscale on Proxmox Host

### On your target Proxmox node:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

Then start the Tailscale agent:

```bash
sudo tailscale up
```
This opens a login URL. Visit it and authenticate with your Entra ID credentials. Once authenticated, the host joins your tailnet and is assigned a Tailscale IP and DNS name.

<img width="1295" height="636" alt="image" src="https://github.com/user-attachments/assets/332c3d2c-0df1-4fd7-80a8-736d988a0cbc" />

<img width="1012" height="647" alt="image" src="https://github.com/user-attachments/assets/14e6cd14-70cf-4a9d-aa51-884f4a2372e4" />

<img width="705" height="587" alt="image" src="https://github.com/user-attachments/assets/135ef2a9-4cc5-4371-befe-00f73e8b1aab" />

<img width="692" height="577" alt="image" src="https://github.com/user-attachments/assets/2cae3527-4e2f-4dea-84e4-f30b2bfa8f03" />

<img width="816" height="259" alt="image" src="https://github.com/user-attachments/assets/47ab356e-3ac3-4107-a74c-1b66a6be66fd" />


**Note:** Tailscale auto exposes services running on the host via its DNS name. The Proxmox Web UI on port 8006 is immediately accessible through the Tailscale tunnel.

---

## Step 4: User can now access Proxmox Over Tailscale

### From any machine with Tailscale installed:


1. User/2nd admin installs Tailscale on your local machine for windows, linux, etc (desktop, laptop, phone)

   `tailscale.com/download`
 
   <img width="1544" height="795" alt="image" src="https://github.com/user-attachments/assets/b92c39d6-3fb3-4409-a18b-e02c23759107" />


2.  User/2nd admin authenticates with your Entra ID credentials, connects their machine.

<img width="655" height="507" alt="image" src="https://github.com/user-attachments/assets/c1e5acde-e0db-4fb0-9316-8bff983b5746" />

3. In the browser, navigate to the Proxmox Web UI using the Tailscale DNS name:

You could copy it from the portal directly 
<img width="1818" height="902" alt="image" src="https://github.com/user-attachments/assets/265b3b3d-1dbe-4dc9-9c78-97e12dbf9f2c" />

   ```
   https://<proxmox-hostname>.ts.net:8006
   ```
   (Find your Tailscale DNS name in the admin console → Machines → look for the hostname assigned to your Proxmox node)

5. You'll see the Proxmox login page. Log in with Proxmox credentials (see Step 5).
<img width="1864" height="742" alt="image" src="https://github.com/user-attachments/assets/5da7697a-1c7a-42c6-8113-5562cad67869" />

---

## Step 5: Proxmix admin creates Proxmox Users for 2nd admin with Scoped Access

To grant your co-admin access to Proxmox with limited permissions:

### Via Web UI:

1. Log into the Proxmox Web UI (as the admin account)
2. Navigate to **Datacenter** (top left) → **Permissions** (left sidebar)
3. Click **Users** tab
4. Click **Add** button
5. Fill in:
   - **Username:** Enter a username (e.g., `admin2`)
   - **Realm:** Select `pve` (local Proxmox realm)
   - **Password:** Set a strong password
   - **Expire:** Leave as `never` or set an expiry date if desired
6. Click **Add** to create the user

### Assign Role/Permissions:

1. Still in **Datacenter** → **Permissions**
2. Click the **Permissions** tab (not Users)
3. Click **Add** button
4. Set:
   - **Path:** Select `/nodes/<nodename>` to restrict access to one Proxmox node (e.g., the node hosting your lab VMs)
   - **User:** Select the user you just created
   - **Role:** Select `Administrator` (full permissions on that node)
5. Click **Add**

**Login credentials for the co-admin:**
- **Username:** Whatever you created
- **Realm:** `pve` (important — **must select from dropdown**)
- **Password:** The one you set during user creation

---

## Step 6: Verify End-to-End Access

### For the co-admin:

1. Install Tailscale on their machine
2. Authenticate with their Entra ID account
3. Navigate to the Proxmox Web UI using the Tailscale DNS name: `https://<proxmox-hostname>.ts.net:8006`
4. Log in with:
   - **Username:** The one you created in Step 5
   - **Realm:** `pve` (select from dropdown)
   - **Password:** The one you set
5. They should see the Proxmox datacenter, but can only manage resources on the node you restricted them to

---

## How It Works (Architecture)

```
Your Machine (Tailscale)
        ↓
   Encrypted Tunnel
        ↓
   PVE3 (Tailscale installed)
        ↓
   Proxmox Web UI (port 8006)
        ↓
   Proxmox user admin2@pve with scoped role
```

- **Tailscale** encrypts all traffic between your machine and PVE3
- **DNS resolution** is handled by Tailscale's MagicDNS feature (eg: `<hostname>.<tailnet-id>.ts.net`)
- **Proxmox roles** limit what admin2 can see/modify (PVE3 node only in this case)

---

## Accessing Additional Machines

If you want to add more Proxmox nodes or other services to the tailnet:

1. Install Tailscale on each host: `curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up`
2. Authenticate with Entra ID
3. Each will get its own Tailscale DNS name automatically
4. Access them the same way: `https://<hostname>.ts.net:8006`

For a subnet router approach (to advertise internal lab subnets), create a dedicated LXC container instead — that's a separate setup for broader network access.

---

## Troubleshooting

**Can't access the Proxmox UI:**
- Verify Tailscale is running on the Proxmox host: `systemctl status tailscaled`
- Check the Tailscale admin console → Machines to see if your Proxmox node is listed and connected
- Ensure your local machine has Tailscale running and authenticated

**DNS name not resolving:**
- Tailscale's MagicDNS feature must be enabled (usually on by default)
- Check Tailscale admin console → Settings → MagicDNS

**User can't log in to Proxmox:**
- Verify the realm dropdown is set to `pve` (not `pam`)
- In Proxmox, check the user exists: Datacenter → Permissions → Users tab
- Check the user has the role assigned: Datacenter → Permissions → Permissions tab, look for the user's entry

---

## Security Notes

- Tailscale uses WireGuard under the hood — all traffic is encrypted end-to-end
- No firewall port forwarding needed; the connection is outbound-only
- Entra ID controls who can join the tailnet (no anonymous access)
- Proxmox roles limit what each user can do (defense in depth)
- Keep Tailscale updated: `sudo apt update && sudo apt upgrade tailscale`

---

## References

- [Tailscale Documentation](https://tailscale.com/docs)
- [Tailscale on Proxmox](https://tailscale.com/docs/integrations/proxmox)
- [Tailscale Entra ID Integration](https://tailscale.com/docs/integrations/identity)
- [Proxmox User Management](https://proxmox.com/en/proxmox-ve/documentation)
