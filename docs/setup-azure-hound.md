## AzureHound + BloodHound CE

AzureHound collects Entra ID and Azure Resource Manager relationship data so it can be imported into BloodHound CE and viewed as a graph.

In this lab, I used it to pull data from `monkey.place` and generate:

```text
monkey-place-azurehound.json
```

That JSON is the collector output. BloodHound CE is the local web UI that serves and explores the graph.

### What I Learned

The first attempt was the obvious username/password command:

```powershell
.\azurehound.exe list `
    -u "angel@monkey.place" `
    -p "<password>" `
    -t "monkey.place" `
    -o "monkey-place-azurehound.json"
```

That failed because MFA / Conditional Access blocks simple username and password authentication in most real tenants.

The useful error looked like:

```text
AADSTS50076: ... you must use multi-factor authentication ...
```

AzureHound supports refresh-token auth, so the better path was:

1. Start a Microsoft device code flow.
2. Open the browser login page.
3. Complete MFA.
4. Receive a refresh token.
5. Pass that token directly into AzureHound.

Do not print or save refresh tokens in docs. If one gets pasted publicly, revoke sessions or reset the lab account password.


### Automated AzureHound Collection

I consolidated the process into:

```text
scripts/azure-hound/Invoke-AzureHoundDeviceCodeCollection.ps1
```

The script:

- Downloads the latest AzureHound Windows AMD64 release if it is missing.
- Opens the Microsoft device login page.
- Copies the device code to the clipboard.
- Waits while browser authentication completes.
- Passes the refresh token directly into AzureHound.
- Saves the collector output as `monkey-place-azurehound.json`.

Run it:

```powershell
cd .\scripts\azure-hound
.\Invoke-AzureHoundDeviceCodeCollection.ps1
```

Expected flow:

```text
Go to: https://login.microsoft.com/device
Enter code: <device-code>
Device code copied to clipboard.
Waiting for browser login...

Got refresh token. Running AzureHound...
AzureHound v2.12.2
...
collection completed

AzureHound output saved to:
...\monkey-place-azurehound.json
```

Some warnings during collection can be normal in a lab tenant:

- Missing premium license can affect sign-in activity data.
- Missing `RoleManagement.Read.Directory` can affect some role / PIM collection.
- Missing reader access at the tenant root management group can affect management group collection.

The important part is whether the JSON output is created successfully.

### BloodHound CE Viewer

One thing I overlooked at first: AzureHound only collects the data. To actually see the graph, BloodHound CE needs to be running.

BloodHound CE uses Docker, so Docker Desktop has to be installed and running first. I used the BloodHound CLI installer instead of manually writing a Docker Compose file.

Basic setup:

```powershell
mkdir C:\BloodHoundCE
cd C:\BloodHoundCE

Invoke-WebRequest `
    -Uri "https://github.com/SpecterOps/bloodhound-cli/releases/latest/download/bloodhound-cli-windows-amd64.zip" `
    -OutFile ".\bloodhound-cli.zip"

Expand-Archive .\bloodhound-cli.zip -DestinationPath . -Force

.\bloodhound-cli.exe install
```

The important thing is that Docker and the Compose plugin pass the pre-check:

```text
C:\AzureHound_v2.12.2_windows_amd64>.\bloodhound-cli install
[+] Checking the status of Docker and the Compose plugin...
[+] Docker and the Compose plugin checks have passed
[+] Starting BloodHound environment installation
[+] Downloading the production YAML file...
```

When the install finishes, BloodHound prints the generated admin password:

```text
[+] BloodHound is ready to go!
[+] You can log in as `admin` with this password: <generated-password>
```


Open BloodHound CE in a browser:

```text
http://localhost:8080/ui/login
```

Log in with:

```text
Username: admin
Password: <generated-password>
```

Note: if you lose or forget the password it can be reset with `.\bloodhound-cli resetpwd`


### Importing the AzureHound Data

After BloodHound CE is running:

1. Log in to `http://localhost:8080/ui/login`.
2. Go to the upload / file ingest area.
3. Upload `monkey-place-azurehound.json`.
4. Wait for ingestion to finish.
5. Use Search, Pathfinding, or Cypher to explore the tenant graph.

Useful starter Cypher query for Azure / Entra role assignments:

```cypher
MATCH (principal)-[r:AZHasRole]->(role:AZRole)
OPTIONAL MATCH (u:AZUser {objectid: principal.objectid})
OPTIONAL MATCH (g:AZGroup {objectid: principal.objectid})
OPTIONAL MATCH (sp:AZServicePrincipal {objectid: principal.objectid})
WITH coalesce(u, g, sp, principal) AS resolvedPrincipal, r, role
MATCH p=(resolvedPrincipal)-[r]->(role)
RETURN p
LIMIT 100
```

This helped clean up the graph view by resolving Azure base objects back to users, groups, or service principals when BloodHound had the richer object available. It made role assignments easier to read than the default object-ID-heavy view.

### Notes

- Keep BloodHound CE local unless there is a reason to expose it.
- The default local URL is `http://localhost:8080`.
- The graph can expose users, apps, service principals, role assignments, and privilege paths.
- Only run AzureHound against tenants you own or have permission to assess.
- If a refresh token is exposed, revoke user sessions or reset the lab account password.


### Hardening Note: Block Device Code Flow

Device code flow is useful for tools like AzureHound, Azure PowerShell, Azure CLI, TVs, printers, and other devices that cannot easily open a browser locally.

However, it is also abused in phishing because the victim can be tricked into entering a real Microsoft device code, completing MFA, and granting tokens to the attacker-controlled session.

A stronger tenant can reduce this risk by using Conditional Access to block device code flow:

Protection > Conditional Access > Policies > New policy

- Users: All users
- Target resources: All cloud apps
- Conditions: Authentication flows
- Transfer method: Device code flow
- Grant: Block access
- Enable policy: Report-only first, then On after testing

This should be tested before enforcement because some legitimate tools and devices may rely on device code authentication.