//
//  ContentView.swift
//  Shared
//
//  Created by Ronald Mannak on 9/14/20.
//

import SwiftUI

struct ContentView: View {
    
    @State var plaintext = "dove lumber quote board young robust kit invite plastic regular skull history"
    
    @State var chachaPassword: String = ""
    @State var chachaCiphertext: Data?
    @State var AESGCMChiphertext: Data?
    
    @State var chachaCleartext: String?
    @State var AESGCMCleartext: String?
    
    init() {
        
    }
    
    var body: some View {
        
        TabView {
            WalletView(mnemonic: $plaintext)
                .tabItem {
                    Image(systemName: "wallet.pass")
                    Text("Wallet")
                }
            BackupView(mnemonic: $plaintext)
                .tabItem {
                    Image(systemName: "dollarsign.square")
                    Text("Backup")
                }            
            DownloadAppView()
                .tabItem {
                    Image(systemName: "square.and.arrow.down")
                    Text("VivoPay")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
