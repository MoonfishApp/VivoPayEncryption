//
//  WalletView.swift
//  VivoPayEncryption
//
//  Created by Ronald Mannak on 9/14/20.
//

import SwiftUI

struct WalletView: View {
    
    @Binding var mnemonic: String
    
    @State var ciphertext: Data? = nil
    @State var cleartext: String? = nil
    
    @State var error: Error?

    var encryptButtonColor: Color {
        return mnemonic.count > 0 ? .white : .gray
    }
    
    var decryptButtonColor: Color {
        return ciphertext == nil ? .gray : .white
    }
    
    var body: some View {
                
        ZStack {
            
            #if targetEnvironment(simulator)
            VStack {
                Spacer()
                Text("The wallet demo uses the Secure Enclave which isn't available in the simulator. Run the app on a device.")
                Spacer()
            }
            .padding()
            #else
        
            VStack {

                Text("Encrypt a wallet using a key stored in the Secure Enclave. An encrypted wallet can only be decrypted on this device, as it is impossible to extract the private key from the Secure Enclave")
                    .font(.footnote)
                
                Text("Seed phrase:")
                    .padding(.top)
                TextField("", text: $mnemonic)
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
                            self.ciphertext = try WalletEncryption().encrypt(self.mnemonic)
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
                    .disabled(mnemonic.count == 0)

                    // FaceID or TouchID is required to decrypt the data. This is automatically
                    // handled by the OS if the key is generated using access control, see WalletEncryption.swift
                    // Note that in order to use FaceID, a NSFaceIDUsageDescription key in info.plist is required.
                    Button(action: {
                        self.cleartext = nil
                        self.error = nil
                        do {
                            self.cleartext = try WalletEncryption().decrypt(self.ciphertext!)
                        } catch {
                            self.error = error
                        }
                    }) {
                        Text("Decrypt")
                            .foregroundColor(decryptButtonColor)
                    }
                    .disabled(self.ciphertext == nil)
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
            #endif
        }
        .frame(maxWidth: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [Color("Harmony.MintGreen"), Color("Harmony.ElectricBlue")]), startPoint: .topTrailing, endPoint: .bottomLeading))
        .edgesIgnoringSafeArea(.top)
    }
}

struct WalletView_Previews: PreviewProvider {
    @State static var plaintext = "dove lumber quote board young robust kit invite plastic regular skull history"
    static var previews: some View {
        WalletView(mnemonic: $plaintext)
    }
}
