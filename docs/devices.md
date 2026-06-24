# Devices

## Microsoft Entra Join and Registration Settings

I noticed this briefly messing around in Entra and made a quick change, so documetning for my future self. 

Set **Users may join devices to Microsoft Entra** to: `None`

Reason: this lab tenant is not meant to accidentally enroll or join personal/home devices. Setting this to **None** helps prevent test accounts from adding personal devices to Entra ID, and avoids those devices later becoming in scope for Intune or other device management policies.

