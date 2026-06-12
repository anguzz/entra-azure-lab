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
<img width="1636" height="500" alt="01-IDP-create-app" src="https://github.com/user-attachments/assets/54a45190-e3d5-43ac-90da-9fad0fab0784" />

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


<img width="1645" height="893" alt="02-IDP-saml-config" src="https://github.com/user-attachments/assets/8db124d2-aaa2-4213-b390-0c3fc09380c8" />

## 4. Download Entra Federation Metadata XML

Go to the SAML app configuration page and find:

```text
SAML Certificates
```

Download:

```text
Federation Metadata XML
```
<img width="1252" height="571" alt="03-IDP-download-fed-xml" src="https://github.com/user-attachments/assets/370346ce-2c08-4e57-883b-6f22c5609b15" />

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
<img width="878" height="831" alt="04-sp-upload-xml" src="https://github.com/user-attachments/assets/b59e680d-0326-4e20-a36a-904207de8449" />

<img width="1247" height="823" alt="05-sp-upload-xml2" src="https://github.com/user-attachments/assets/f4d035a2-5343-402e-87d0-ccff8f03092f" />

Now scroll down and Leave the **Subject NameID** field empty.

<img width="1207" height="709" alt="image" src="https://github.com/user-attachments/assets/88dd55c5-8759-4d4b-8b22-af3be0c2fe80" />


Then click **Login**.

If everything is configured correctly, login should succeed and SAMLSP.com will show the user attributes being sent from the tenant.

<img width="1153" height="877" alt="06-SP-logged-in" src="https://github.com/user-attachments/assets/6008918e-28c4-4947-a5d3-76637a51a84e" />


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
<img width="1166" height="806" alt="08-IDP-Edit-saml-cert" src="https://github.com/user-attachments/assets/ba20de68-23a2-4298-9d92-667221009084" />


## 6. Review Signing Options

Under the SAML signing certificate settings dropdown, Entra gives a few signing options:

<img width="1621" height="742" alt="09-new-saml-cert" src="https://github.com/user-attachments/assets/a3aabc04-176e-42c4-9500-9bb711c95ae8" />


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

<img width="843" height="465" alt="10-download-options" src="https://github.com/user-attachments/assets/365e886f-8550-4a52-b8fa-f1ac9c3d57d4" />

Activate and download the new cert 

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

## 12. Cleanup

After confirming the new certificate works, the old inactive certificate can eventually be removed.

In production, do not remove the old certificate immediately unless you are sure the Service Provider has been updated and SSO is confirmed working. Keeping the old certificate during the transition gives you a rollback option.

For this lab, once the new cert is active and SSO works, the old inactive cert can be removed if no longer needed.
