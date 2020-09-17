//
//  BackupEncryption.swift
//  VivoPayEncryption
//
//  Created by Ronald Mannak on 9/14/20.
//

import Foundation
import CryptoKit

struct BackupEncryption {
    
    /// Encrypts string using ChaChaPoly and a password chosen by the user
    /// - Parameters:
    ///   - clearText: the string to be encrypted
    ///   - password: password chosen by user
    /// - Throws: CryptoKit error if clearText cannot be encrypted
    /// - Returns: cipherText as Data
    func encrypt(_ clearText: String, with password: String) throws -> Data {
        
        let key = SymmetricKey(password: password)
        let data = clearText.data(using: .utf8)!
        return try ChaChaPoly.seal(data, using: key).combined
    }
    
    
    /// Decrypts cipherText using ChaChaPoly and a password chosen by the user
    /// - Parameters:
    ///   - cipherText: encrypted data
    ///   - password: password chose by user
    /// - Throws: CryptoKit error if cipherText cannot be decrypted
    /// - Returns: clear text decrypted string
    func decrypt(_ cipherText: Data, with password: String) throws -> String? {

        let key = SymmetricKey(password: password)
        let sealedBox = try ChaChaPoly.SealedBox(combined: cipherText)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: key)
        return String(data: decryptedData, encoding: .utf8)
    }
}

extension SymmetricKey {
    
    /// Creates a symmetric key based on a password
    /// Source: https://fred.appelman.net/?p=119
    /// - Parameter password: password chosen by user
    init(password: String) {
        
        let hash = SHA256.hash(data: password.data(using: .utf8)!)
        // Convert the SHA256 to a string. This will be a 64 byte string
        let hashString = hash.map { String(format: "%02hhx", $0) }.joined()
        // Convert to 32 bytes / 256 bits
        let subString = String(hashString.prefix(32))
        // Convert the substring to data
        let keyData = subString.data(using: .utf8)!
        
        self.init(data: keyData)
    }
}
