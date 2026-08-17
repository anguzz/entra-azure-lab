Setup acl tailscale · MD
# Setting up an ACL in Tailscale
 
After setting up Tailscale in `setup-tailscale.md`, I realized that anyone in my tailnet with a member role (or similar) could connect to any machine in my tailnet. Since the users in my tailnet are currently trusted, it's mostly fine, but I realized what if I had a machine on my tailnet that I only wanted myself or privileged users to be able to connect to?
 
After messing around in the settings I saw ACLs, but was unsure how to set these up. This guide goes over how to set up an ACL in Tailscale, and testing it with my test user.
 
By default, Tailscale does not expose the admin console to users with the member role. So there is less risk of a user who gets invited accessing unintended machines, but it's not impossible.

 <img width="1638" height="754" alt="forbidden" src="https://github.com/user-attachments/assets/b832aaed-8982-4c46-ab04-c79083393e95" />

Without an ACL, if a user is part of the tailnet, they can in theory access any other device on it. For example, the Proxmox virtual environment, or other machines on the tailnet leaving you with only security by obscurity, plus whatever secondary platform controls exist (like passwords, for my Proxmox environment).
 
You can assume that in a worst case scenario a user on your tailnet is compromised, and now an attacker would have access to your remote machines.
 
## Policy design
 
Initially I thought I would tag my personal machines on the tailnet, and allow my admin role to be the only one with access essentially creating a whitelist for who could access them but after reading the documentation I realized I was mistaken.
 
Instead, we create a tag for our Proxmox hosts, and allow a specific group of members to only access hosts tagged with that tag.
 
Tailscale's grants are deny by default, and they're deny by default *per source*. Once you write even one grant with a group as the `src`, that group loses access to everything except what's listed as `dst` in grants that include them your personal laptop, NAS, whatever else, all become unreachable to them automatically, with zero tags or config changes needed on those devices.
 
The one thing you still need is a separate grant (or the leftover default "allow all" rule) covering your own admin account, so you don't accidentally lock yourself out of your own machines something like:
 
```json
{
	"src": ["autogroup:admin"],
	"dst": ["*"],
	"ip":  ["*"]
}
```
 
## Creating the policy
 
### 1. Create tag

 
Under `Access controls > Tags > Create tag`.
 
I created a tag called `pve-cluster` for my Proxmox cluster environment.
 
The tag owner for this tag was set to `autogroup:admin` but I changed it to `autogroup:owner`.
<img width="909" height="599" alt="image" src="https://github.com/user-attachments/assets/9e4e87b3-85f7-4541-9820-19f5343a9469" />

 
### 2. Tag machines
 
Under the machine, I tagged it by clicking the three dots, then "Edit ACL tags."
 
I applied my tag.

 <img width="513" height="381" alt="tag-machines" src="https://github.com/user-attachments/assets/9d161ee4-9053-40e8-a332-3c11e2d823dc" />

### 3. Create group
 
`Access controls > Definitions > Groups > Create group`
 
Named it `pve-members`, then added members.

<img width="702" height="597" alt="pve-members" src="https://github.com/user-attachments/assets/fcd8d793-47f4-4b07-a5b6-9fa350562d0a" />

 <img width="1111" height="431" alt="image" src="https://github.com/user-attachments/assets/e55b572b-79fa-48ef-9501-6439a9923c38" />

### 4. Add policy
 
`Access controls > Policy > General access rules > Add rule`
 
- source: `group:pve-members`
- destination: `tag:pve-cluster`
- port and protocol: all ports and protocols
For now I allowed all traffic, but I'm thinking it would be best to somehow limit this to just the web UI / HTTPS port. Come back to this later.
 <img width="1586" height="577" alt="add-rule" src="https://github.com/user-attachments/assets/e5c70ee1-1e4a-4634-bf17-8ee65d84ea69" />

I also noticed there are a few other options you can add, like device posture, and app level options like domains and capabilities, allowing finer grained control.

### 5. Remove default rules
 
I noticed that by default there's a rule that allows all users and devices to connect to all users and devices.
  <img width="1838" height="643" alt="all-to-all" src="https://github.com/user-attachments/assets/398a9bb5-09ae-426a-a436-e8e7957a8bb4" />

I went ahead and edited/removed that rule so only my account could reach all users and devices for now, and members or other roles would need their own ACL rules set up in the meantime.

<img width="1820" height="573" alt="image" src="https://github.com/user-attachments/assets/3bc40c06-e4e8-45bc-89df-13a8837336cf" />
 

### 6. Testing
 
Before the ACL:
```shell
C:\Users\Angel>ping angusmintdev.your-tailnet.ts.net
 
Pinging angusmintdev.your-tailnet.ts.net. [100.100.100.10] with 32 bytes of data:
Reply from 100.100.100.10: bytes=32 time=9ms TTL=64
Reply from 100.100.100.10: bytes=32 time=1ms TTL=64
 
Ping statistics for 100.100.100.10:
    Packets: Sent = 2, Received = 2, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 1ms, Maximum = 9ms, Average = 5ms
```
 
After the ACL:
 
```shell
C:\Users\Angel>ping angusmintdev.your-tailnet.ts.net
 
Pinging angusmintdev.your-tailnet.ts.net. [100.100.100.10] with 32 bytes of data:
Request timed out.
 
Ping statistics for 100.100.100.10:
    Packets: Sent = 1, Received = 0, Lost = 1 (100% loss),
 
C:\Users\Angel>ping pve3.your-tailnet.ts.net
 
Pinging pve3.your-tailnet.ts.net. [100.100.100.23] with 32 bytes of data:
Reply from 100.100.100.23: bytes=32 time=2ms TTL=64
Reply from 100.100.100.23: bytes=32 time=1ms TTL=64
Reply from 100.100.100.23: bytes=32 time=1ms TTL=64
 
Ping statistics for 100.100.100.23:
    Packets: Sent = 3, Received = 3, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 1ms, Maximum = 2ms, Average = 1ms
C:\Users\Angel>
```
As you can see, my secondary test account (member role) with the Tailscale client installed wasn't able to connect to my Mint machine on the tailnet, but could still reach one of my Proxmox cluster nodes.
 
## Adding port and protocol restrictions
 
Earlier I thought about restricting members to only reach my Proxmox host on one specific port the one used by the web UI.
 
I figured this would just be TCP 8006, since the Proxmox web UI runs on that port by default, so I limited the rule for tagged machines to `tcp:8006` traffic.
 
So I went ahead and tested this by editing my policy:
 
```json
// Allow pve-members to pve-cluster
{
	"src": ["group:pve-members"],
	"dst": ["tag:pve-cluster"],
	"ip":  ["tcp:8006"],
}
```
 
After testing this, it appeared to be working:
 
```powershell
PS C:\Users\Angel> Test-NetConnection -ComputerName pve3.your-tailnet.ts.net -Port 8006
 
ComputerName     : pve3.your-tailnet.ts.net
RemoteAddress    : 100.100.100.23
RemotePort       : 8006
InterfaceAlias   : Tailscale
SourceAddress    : 100.100.100.5
TcpTestSucceeded : True
 
PS C:\Users\Angel> Test-NetConnection -ComputerName pve3.your-tailnet.ts.net -Port 22
WARNING: TCP connect to (100.100.100.23 : 22) failed
 
ComputerName           : pve3.your-tailnet.ts.net
RemoteAddress          : 100.100.100.23
RemotePort             : 22
InterfaceAlias         : Tailscale
SourceAddress          : 100.100.100.5
PingSucceeded          : True
PingReplyDetails (RTT) : 0 ms
TcpTestSucceeded       : False
```
 
Port 8006 (the web UI) succeeded, and port 22 (SSH, which I know is open on the host but never granted in the rule) correctly failed a good sign the restriction is scoped to just the one port I intended, not just blocking everything randomly.
 
## More security thoughts
 
While giving my owner account access to everything would be bad practice in a production environment, this is a lab environment, so having my owner account act as a superadmin is fine for simplicity's sake. My goal was to let other users, like friends and secondary admins, onto my tailnet without letting them hit any devices besides my Proxmox nodes. I think my current configuration also covers the case where I have multiple separate networks on my tailnet I don't want different admins connecting into each other's networks and devices.
 
Where I originally thought this might fall apart is if a device I didn't want members reaching was already sitting on the same internal LAN as my Proxmox cluster. My concern was that once someone was "inside" the cluster, they'd be able to see and reach other devices on that internal network directly.
 
After looking into it more, I don't think that's actually a gap in the ACL itself. If a Proxmox node ever advertises that LAN as a subnet route over Tailscale, that route only becomes reachable to a group if it's explicitly listed as a `dst` in a grant for that group. So as long as I never add my LAN's subnet as a `dst` for `pve-members`, that path stays closed under the same default-deny setup I already have.
 
The real risk in this scenario is different, a member logging into the Proxmox web UI itself and pivoting from inside it for example, opening a VM's console and reaching whatever network that VM is bridged to. That isn't something Tailscale's ACL can control, since it happens after the connection to `tag:pve-cluster` has already been allowed. That part would need to be locked down inside Proxmox itself, using its own user/permission system (`Datacenter > Permissions`), which is a separate access control layer from Tailscale. I'd want to look into that separately if I want to fully lock this down.
 

### Quick note

> Note: IPs and the tailnet suffix in this doc are redacted/replaced with placeholders. In practice this info isn't that sensitive since you can't actually connect to a device just by knowing its Tailscale IP (WireGuard requires a key the coordination server has already authorized as a peer), so this is mainly just good hygiene rather than a real fix for anything, it costs nothing to swap out and avoids handing out a free map of my infra for recon purposes.
