//
//  DownloadAppView.swift
//  VivoPayEncryption
//
//  Created by Ronald Mannak on 9/15/20.
//

import SwiftUI

struct DownloadAppView: View {
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        
        VStack {
            Spacer()
            
            Text("VivoPay for Harmony One will be out soon for iOS, iPadOS and MacOS.")
            Text("Subscribe to the VivoPay email list and be the first to be notified when")
                .padding()
            
            Button(action: {
                openURL(URL(string: "https://vivopay.me")!)
            }) {
                Text("Open in browser")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.heavy)
                    .padding(.top)
            }
            .buttonStyle(DefaultButtonStyle())
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [Color("Harmony.MintGreen"), Color("Harmony.ElectricBlue")]), startPoint: .topTrailing, endPoint: .bottomLeading))
        .edgesIgnoringSafeArea(.top)
    }
}

struct DownloadAppView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadAppView()
    }
}
