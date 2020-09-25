//
//  WalletEncryption.swift
//  VivoPayEncryption
//
//  Created by Ronald Mannak on 9/14/20.
//

import Foundation
import LocalAuthentication
import CryptoKit


/// WalletEncryption shows how VivoPay stores the wallet file on disk.
/// VivoPay uses the most secure way to encrypt the wallet on a device: the Secure Enclave found in iOS and Mac laptops.
/// The Secure Enclave is not able to produce key stets for Harmony, Ethereum or any other blockchain. The curves don't match.
///
/// The issue VivoPay solved is that wallet files
/// VivoPay uses the SecureEnclave for
struct WalletEncryption {
    
    /// Public key
    fileprivate var publicKey: SecKey!
    
    /// Reference to the private key stored in the Secure Enclave
    fileprivate var privateKey: SecKey?
    
    fileprivate static let encryptionAlgorithm = SecKeyAlgorithm.eciesEncryptionCofactorX963SHA256AESGCM
    fileprivate static let tag = "com.starlingprotocol.vivopayencryptiondemo"
        
    /// Initialized keys
    /// - Throws: CryptoKit error
    init() throws {
        
        try restoreKey()
    }
}

// MARK: - Encryption and decryption
extension WalletEncryption {

    /// Encrypts string using the Secure Enclave
    /// - Parameter string: clear text to be encrypted
    /// - Throws: CryptoKit error
    /// - Returns: cipherText encrypted string
    func encrypt(_ string: String) throws -> Data {
        
        let data = string.data(using: .utf8)!
        
        // 1.   Verify public key can be used to encrypt
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, WalletEncryption.encryptionAlgorithm) else {
            throw VivoError.encryption("Error verifying public key")
        }
        
        // 2.   Encrypt
        var error: Unmanaged<CFError>?
        guard let cipherText = SecKeyCreateEncryptedData(publicKey, WalletEncryption.encryptionAlgorithm, data as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }

        // 3.   Return encrypted data
        return cipherText
    }
    
    /// Decrypts cipher text using the Secure Enclave
    /// - Parameter cipherText: encrypted cipher text
    /// - Throws: CryptoKit error
    /// - Returns: cleartext string
    func decrypt(_ cipherText: Data) throws -> String {
        
        // 1.   Verify private key can be used to decrypt
        guard let privateKey = privateKey, SecKeyIsAlgorithmSupported(privateKey, .decrypt, WalletEncryption.encryptionAlgorithm) else {
            throw VivoError.encryption("Error fetching private key")
        }
        
        // 2.   Decrypt data
        var error: Unmanaged<CFError>?
        guard let clearText = SecKeyCreateDecryptedData(privateKey, WalletEncryption.encryptionAlgorithm, cipherText as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        // 3.   Return clear text
        return String(data: clearText, encoding: .utf8)!
    }
    
    /// Removes existing key.
    /// Method is not used in VivoEncryption and added for those who want to experiment
    /// - Throws: CryptoKit error message
    func deleteKey() throws {
        
        // 1.   Create deletion query
        let query = [kSecClass: kSecClassKey,
                     kSecUseDataProtectionKeychain: true,
                     kSecAttrApplicationLabel: WalletEncryption.tag] as [String: Any]
        
        // 2.   Delete key
        let result = SecItemDelete(query as CFDictionary)
        
        // 3.   Thros error if deletion wasn't successful
        if result != errSecSuccess {
            throw VivoError.encryption("Unexpected error deleting key: \(result)")
        }
    }
    
}

// MARK: - Key
extension WalletEncryption {
    
    /// Fetches key pair. If no key pair is found, a new keypair is created
    /// - Throws: CryptoKit error
    fileprivate mutating func restoreKey() throws {
        
        // 1.   Try to find existing key in the Secure Enclave
        if let key = try loadKey() {
            privateKey = key
            publicKey = SecKeyCopyPublicKey(key)
        
        } else {
        
            // 2.   if no key is found, create a new pair
            let keyTuple = try createKeys()
            self.publicKey = keyTuple.public
            self.privateKey = keyTuple.private
        }
    }
    
    /// Attempt to find and load existing key for VIvoEncrypt from the Secure Enclave
    /// If no secure enclave is available (e.g. iPod Touch), the method falls back to the iOS Keychain
    /// - Throws: CryptoKit error
    /// - Returns: Private key if found, nil if no existing key pair was found
    fileprivate func loadKey() throws -> SecKey? {

        // 1.   Create query
        var query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: WalletEncryption.tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]
        
        // 2.   Search for the key in Secure Enclave if possible (otherwise
        //      search will fall back to the iOS Keychain
        if SecureEnclave.isAvailable {
            query[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
        }
        
        // 3.   Copy reference to private key from the Secure Enclave
        var key: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &key) == errSecSuccess {
            return (key as! SecKey)
        }
        
        // 4.   Return nil if no key was found
        return nil
    }
    
    /// Creates a new private key in the Secure Enclave. If no Secure Enclave is available,
    /// the method falls back to the iOS Keychain
    /// - Throws: CryptoKit error
    /// - Returns: Tuple of public and private key
    fileprivate func createKeys() throws  -> (public: SecKey, private: SecKey?) {
        
        var error: Unmanaged<CFError>?
        
        // 1.   Private key access control
        //      .privateKeyUsage makes the key accessible for signing and verification
        //      See https://developer.apple.com/documentation/security/secaccesscontrolcreateflags
        let privateKeyAccessControl: SecAccessControlCreateFlags = SecureEnclave.isAvailable ?  [.userPresence, .privateKeyUsage] : [.userPresence]
        guard let privateKeyAccess = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, privateKeyAccessControl, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        var privateKeyAttributes: [String: Any] = [
            kSecAttrApplicationTag as String:       WalletEncryption.tag,
            kSecAttrIsPermanent as String:          true,
            kSecUseAuthenticationUI as String:      kSecUseAuthenticationUIAllow,
            kSecUseAuthenticationContext as String: LAContext(),
            kSecUseOperationPrompt as String:       "VivoPay needs access to private key",
            kSecAttrAccessControl as String:        privateKeyAccess,
        ]
        var commonKeyAttributes: [String: Any] = [
            kSecAttrKeyType as String:              kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String:        256,
            kSecPrivateKeyAttrs as String:          privateKeyAttributes,
        ]
                
        // 2.   Set secure enclave specific attributes
        if SecureEnclave.isAvailable {
            commonKeyAttributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
            commonKeyAttributes[kSecPrivateKeyAttrs as String] = privateKeyAttributes
            privateKeyAttributes[kSecAttrAccessControl as String] = privateKeyAccessControl
        }
        
        // 3.   Create a new random private key
        guard let privateKey = SecKeyCreateRandomKey(commonKeyAttributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        
        // 4.   Obtain the public key
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw VivoError.encryption("Error creating public key")
        }
        
        return (public: publicKey, private: privateKey)
    }
}

// MARK: - Error
enum VivoError: Error {
    
    case encryption(String)
    
    var errorDescription: String? {
        switch self {
        case .encryption(let message):
            return message
        }
    }
}
