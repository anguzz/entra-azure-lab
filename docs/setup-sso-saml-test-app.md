# Entra ID SAML SSO Test App and Certificate Rotation

This is a simple example of setting up a non-gallery SSO app in Entra ID, configuring SAML authentication, and practicing SAML certificate rotation.

For this lab, we are using:

```text
https://samlsp.com/en/
```

This is a free SAML Service Provider testing site that lets you practice SAML setup, metadata uploads, login testing, and basic SAML claim review.

## 1. Create the Entra Enterprise Application

Go to:

```text
https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AppGalleryBladeV2
```

Create a **non-gallery application**.

For this lab, I named the app:

```text
SAMLSP.com - SAML SSO Test App
```

This name makes it clear in the tenant that the app is for SAMLSP.com and is only being used for SAML SSO testing.

## 2. Configure SAML SSO

Go to:

```text
Enterprise applications
> SAMLSP.com - SAML SSO Test App
> Single sign-on
> SAML
```

Now configure SSO using the Service Provider values from SAMLSP.com.

SAMLSP.com provides these values:

```text
ACS URL: https://samlsp.com/?acs
Assertion Audience: https://samlsp.com
Response Destination: https://samlsp.com/?acs
Logout Callback URL: https://samlsp.com/?sls
```

On the SAMLSP.com side, I am leaving the authentication behavior as default. This lets the IdP, which is Entra ID, use an existing session or prompt for authentication when needed.

## 3. Configure Basic SAML Settings in Entra

In Entra, edit:

```text
Basic SAML Configuration
```

Use the following values:

```text
Identifier (Entity ID): https://samlsp.com
Reply URL (Assertion Consumer Service URL): https://samlsp.com/?acs
Sign on URL (Optional): https://samlsp.com/
Logout URL (Optional): https://samlsp.com/?sls
```

Important distinction:

```text
Identifier / Entity ID
= the application identity / audience value

Reply URL / ACS URL
= where Entra sends the SAML response after login
```

So the Identifier should be:

```text
https://samlsp.com
```

Not:

```text
https://samlsp.com/?acs
```

## 4. Download Entra Federation Metadata XML

Go to the SAML app configuration page and find:

```text
SAML Certificates
```

Download:

```text
Federation Metadata XML
```

This metadata file includes Entra’s SAML IdP information, including:

```text
Entra Entity ID
Entra SSO URL
SAML signing certificate
Logout URL, if configured
```

Upload this Federation Metadata XML into the SAMLSP.com testing tool.

On SAMLSP.com:

```text
Upload Metadata
```

Leave the **Subject NameID** field empty.

Then click **Login**.

If everything is configured correctly, login should succeed and SAMLSP.com will show the user attributes being sent from the tenant.

Example attributes may include:

```text
displayname
identityprovider
objectidentifier
tenantid
emailaddress
name
authnmethodsreferences
```

## 5. SAML Certificate Rotation

Let’s say the current SAML signing certificate is going to expire.

Example current certificate:

```text
SAML Certificates
Token signing certificate

Status: Active
Thumbprint: 47C1C9590286E6DFEAC7C215D101A1583BCBC722
Expiration: 6/11/2029, 10:44:15 PM
```

In this lab, the cert expires in 2029, but we can pretend we are near expiration and need to rotate it.

Go to:

```text
Enterprise applications
> SAMLSP.com - SAML SSO Test App
> Single sign-on
> SAML
> SAML Certificates
> Edit
```

## 6. Review Signing Options

Under the SAML signing certificate settings, Entra gives a few signing options:

```text
Sign SAML response
Sign SAML assertion
Sign SAML response and assertion
```

Which one you use depends on the Service Provider requirements.

For this lab SP, signing the assertion may be enough, but in a production environment, it is better to verify what the application currently expects before changing anything.

Ways to check include:

```text
Vendor documentation
Service Provider SAML settings
SAML-tracer browser extension
Existing SAML response captures
```

## 7. Response vs Assertion Signing

A SAML response is the outer message sent from Entra to the app.

A SAML assertion is the identity payload inside the response. The assertion contains the user identity, NameID, and claims.

Example structure:

```xml
<samlp:Response>
  <saml:Assertion>
    ...
  </saml:Assertion>
</samlp:Response>
```

If both the response and assertion are signed, the SAML response may look like this:

```xml
<samlp:Response>
  <ds:Signature>...</ds:Signature>

  <saml:Assertion>
    <ds:Signature>...</ds:Signature>
    ...
  </saml:Assertion>
</samlp:Response>
```

If only the response is signed, the signature appears under the outer response.

If only the assertion is signed, the signature appears inside the assertion.

The metadata XML tells the SP which certificate to use to validate signatures, but it does not clearly tell you whether Entra is signing the response, assertion, or both. To confirm that, check the Entra signing option or capture a login with SAML-tracer.

## 8. Create the New SAML Certificate

For the signing algorithm, use:

```text
SHA-256
```

Then click:

```text
New Certificate
```

After creating the new certificate, click:

```text
Save
```

The new certificate may initially show as inactive.

Activate the new certificate so it becomes the active token signing certificate. Once the new certificate is active, the previous certificate becomes inactive.

## 9. Download the Updated Certificate or Metadata

After activating the new certificate, refresh the Entra page before downloading anything.

This matters because the Entra blade can sometimes show stale certificate state during rotation.

After refreshing, confirm the correct certificate is marked:

```text
Active
```

Then download one of the following:

```text
Base64 certificate
PEM certificate
Raw certificate
Federation Metadata XML
```

For this lab, downloading the updated **Federation Metadata XML** is the easiest option.

Upload the new metadata XML into SAMLSP.com and test login again.

## 10. Cert Rotation Validation

A successful cert rotation means:

```text
Entra signs the SAML response/assertion with the new active certificate
SAMLSP.com trusts the new certificate from the updated metadata
SAML login succeeds
```

If the SP has the wrong certificate, login may fail with an error like:

```text
Signature validation failed. SAML Response rejected
```

This usually means:

```text
Entra is signing with one certificate
The SP is validating with a different certificate
```

## 11. Rotation Gotcha

During testing, I saw an issue where the old PEM/certificate still appeared to be referenced until I refreshed the Entra page and confirmed the correct active certificate was being downloaded.

Good checklist:

```text
1. Activate the new SAML signing certificate.
2. Refresh the Entra SAML certificate page.
3. Confirm the new certificate is marked Active.
4. Download the certificate or Federation Metadata XML after refreshing.
5. Upload the updated metadata/cert to the SP.
6. Test SAML login again.
```

## 12. Cleanup

After confirming the new certificate works, the old inactive certificate can eventually be removed.

In production, do not remove the old certificate immediately unless you are sure the Service Provider has been updated and SSO is confirmed working. Keeping the old certificate during the transition gives you a rollback option.

For this lab, once the new cert is active and SSO works, the old inactive cert can be removed if no longer needed.
