//
//  BackupView.swift
//  VivoPayEncryption
//
//  Created by Ronald Mannak on 9/14/20.
//

import SwiftUI

struct BackupView: View {
    
    @Binding var mnemonic: String
    
    @State var password: String = ""
    @State var ciphertext: Data?
    @State var cleartext: String?
    @State var error: Error?

    var encryptButtonDisabled: Bool { mnemonic.count == 0 || password.count == 0 }
    var encryptButtonColor: Color {
        return encryptButtonDisabled == true ? .gray : .white
    }
    
    var decryptButtonDisabled: Bool { ciphertext == nil }
    var decryptButtonColor: Color {
        return decryptButtonDisabled == true ? .gray : .white
    }
    
    var body: some View {
        
        ZStack {
        
            VStack {

                Text("Create a backup using ChaChaPoly and a user defined password. The encrypted data can be decrypted with the right password on any device.")
                    .font(.footnote)
                
                Text("Seed phrase:")
                    .padding(.top)
                TextField("", text: $mnemonic)
                    .autocapitalization(.none)

                TextField("Enter password", text: $password)
                    .padding(.top)
                    .autocapitalization(.none)
                
                Spacer()
                
                // MARK: - encryption results
    
                HStack(alignment: .top) {
                    Text("Ciphertext:")
                    
                    if let ciphertext = self.ciphertext {
                        if let cipherString = String(data: ciphertext, encoding: .utf8) {
                            Text("\(cipherString)")
                        }
                        Text("(\(ciphertext.count) bytes)")
                    }
                }
                
                HStack(alignment: .top) {
                    Text("Cleartext:")
                    if let cleartext = self.cleartext {
                        Text(cleartext)
                    }
                }
                
                if let error = error {
                    Text(error.localizedDescription)
                        .font(.title)
                }
                
                Spacer()
                
                // MARK: - Buttons
                
                HStack {
                    Button(action: {
                        self.ciphertext = nil
                        self.cleartext = nil
                        self.error = nil
                        do {
                            self.ciphertext = try BackupEncryption().encrypt(self.mnemonic, with: self.password)
                        } catch {
                            self.error = error
                        }

                    }) {
                        Text("Encrypt")
                            .foregroundColor(encryptButtonColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(encryptButtonColor, lineWidth: 2)
                            )
                    .padding()
                    .disabled(encryptButtonDisabled)

                    Button(action: {
                        self.cleartext = nil
                        self.error = nil
                        do {
                            self.cleartext = try BackupEncryption().decrypt(self.ciphertext!, with: self.password)
                        } catch {
                            self.error = error
                        }
                    }) {
                        Text("Decrypt")
                            .foregroundColor(decryptButtonColor)
                    }
                    .disabled(decryptButtonDisabled)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(decryptButtonColor, lineWidth: 2)
                            )
                    .padding()
                }
                .frame(maxWidth: .infinity)
                
            }
            .padding()
            .padding(.top, 50)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .buttonStyle(DefaultButtonStyle())            
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color("Harmony.MintGreen"), Color("Harmony.ElectricBlue")]), startPoint: .topTrailing, endPoint: .bottomLeading))
        .edgesIgnoringSafeArea(.top)
    }
}

struct BackupView_Previews: PreviewProvider {
    @State static var plaintext = "dove lumber quote board young robust kit invite plastic regular skull history"
    static var previews: some View {
        BackupView(mnemonic: $plaintext)
    }
}
