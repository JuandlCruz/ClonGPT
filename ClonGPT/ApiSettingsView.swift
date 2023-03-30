//
//  ApiKeyView.swift
//  ClonGPT
//
//  Created by JSANCAGU on 30/3/23.
//

import SwiftUI

struct APISettingsView: View {
    
    @ObservedObject var vm = GPTViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Ingresa tu API de ChatGPT")
                .font(.headline)
                .padding()
            
            TextField("API de ChatGPT", text: $vm.API_KEY)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                UserDefaults.standard.set(vm.API_KEY, forKey: "ChatGPTAPIKey")
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Guardar")
            })
            .padding()
        }
    }
}

struct APISettingsView_Previews: PreviewProvider {
    static var previews: some View {
        APISettingsView()
    }
}
