$Tenant = "monkey.place"
$OutputFile = "monkey-place-azurehound.json"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolDir = Join-Path $ScriptDir "AzureHound"
$AzureHoundPath = Join-Path $ToolDir "azurehound.exe"
$OutputPath = Join-Path $ScriptDir $OutputFile

if (-not (Test-Path $AzureHoundPath)) {
    Write-Host "AzureHound not found. Downloading latest release..."

    New-Item -ItemType Directory -Path $ToolDir -Force | Out-Null

    $Release = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/SpecterOps/AzureHound/releases/latest" `
        -Headers @{ "User-Agent" = "PowerShell" }

    $Asset = $Release.assets |
        Where-Object {
            $_.name -match "windows" -and
            $_.name -match "amd64" -and
            $_.name -match "\.zip$"
        } |
        Select-Object -First 1

    if (-not $Asset) {
        $Release.assets | Select-Object name, browser_download_url | Format-Table -AutoSize
        throw "Could not find a Windows AMD64 ZIP asset in the latest AzureHound release."
    }

    $ZipPath = Join-Path $ToolDir $Asset.name

    Invoke-WebRequest `
        -Uri $Asset.browser_download_url `
        -OutFile $ZipPath `
        -Headers @{ "User-Agent" = "PowerShell" }

    Expand-Archive -Path $ZipPath -DestinationPath $ToolDir -Force

    $FoundExe = Get-ChildItem -Path $ToolDir -Recurse -Filter "azurehound.exe" |
        Select-Object -First 1

    if (-not $FoundExe) {
        throw "Downloaded AzureHound, but could not find azurehound.exe after extraction."
    }

    if ($FoundExe.FullName -ne $AzureHoundPath) {
        Copy-Item $FoundExe.FullName $AzureHoundPath -Force
    }

    Write-Host "AzureHound downloaded to: $AzureHoundPath"
}

$Headers = @{
    "User-Agent" = "Mozilla/5.0"
}

$DeviceCodeBody = @{
    "client_id" = "1950a258-227b-4e31-a9cf-717495945fc2"
    "resource"  = "https://graph.microsoft.com"
}

$authResponse = Invoke-RestMethod `
    -UseBasicParsing `
    -Method Post `
    -Uri "https://login.microsoftonline.com/common/oauth2/devicecode?api-version=1.0" `
    -Headers $Headers `
    -Body $DeviceCodeBody

Write-Host ""
Write-Host "Go to: $($authResponse.verification_url)"
Write-Host "Enter code: $($authResponse.user_code)"
Write-Host ""

$authResponse.user_code | Set-Clipboard
Write-Host "Device code copied to clipboard."

Start-Process $authResponse.verification_url

$TokenBody = @{
    "client_id"  = "1950a258-227b-4e31-a9cf-717495945fc2" # Azure PowerShell client ID
    "grant_type" = "urn:ietf:params:oauth:grant-type:device_code"
    "code"       = $authResponse.device_code
}

$Deadline = (Get-Date).AddSeconds($authResponse.expires_in)

while ((Get-Date) -lt $Deadline) {
    Start-Sleep -Seconds $authResponse.interval

    try {
        $Tokens = Invoke-RestMethod `
            -UseBasicParsing `
            -Method Post `
            -Uri "https://login.microsoftonline.com/Common/oauth2/token?api-version=1.0" `
            -Headers $Headers `
            -Body $TokenBody

        break
    }
    catch {
        if ($_.ErrorDetails.Message -like "*authorization_pending*") {
            Write-Host "Waiting for browser login..."
            continue
        }

        throw
    }
}

if (-not $Tokens -or [string]::IsNullOrWhiteSpace($Tokens.refresh_token)) {
    throw "No refresh token was returned. Re-run the script and complete browser login."
}

Write-Host ""
Write-Host "Got refresh token. Running AzureHound..."
Write-Host ""

& $AzureHoundPath `
    -r $Tokens.refresh_token `
    -t $Tenant `
    list `
    -o $OutputPath

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "AzureHound output saved to:"
    Write-Host $OutputPath
}
else {
    throw "AzureHound exited with code $LASTEXITCODE"
}