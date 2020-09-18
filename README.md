# VivoPayEncryption
Source code and demo of the encryption used in VivoPay to store and backup wallets.

![screenshot of VivoEncryption](readme/screenshot.png | width=400)

## Features 
- Demonstrates how VivoPay encrypts the wallet on disk using the Secure Enclave (AES-GCM). 
- Demonstrates how VivoPay encrypts the backup in the cloud using a password-protected ChaChaPoly encryption. (A cloud backup is an alternative to writing down the recovery phrase and only advised for wallets with small amounts)
 
## Read more
(To be added: links to medium posts)

## Download
Download latest version in [releases section](https://github.com/vivopay/VivoEncryption/releases).

## Requirements
- iOS 14.0 or higher
- Xcode 12.0 or higher

## Secure Enclave Resources
- [Ethereum Secure Enclave signing: A tale of two curves](https://blog.enuma.io/update/2016/11/01/a-tale-of-two-curves-hardware-signing-for-ethereum.html)

## Notes
VivoPay is made possible by a [Harmony One grant](https://docs.harmony.one/home/developers/grant-proposals)
Download VivoPay at [vivopay.me](https://vivopay.me/)
