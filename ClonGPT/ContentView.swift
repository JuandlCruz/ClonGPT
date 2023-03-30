//
//  ContentView.swift
//  ClonGPT
//
//  Created by JSANCAGU on 29/3/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var vm = GPTViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    ScrollViewReader { reader in
                        ForEach(vm.chat) { message in
                            if message.role == "user" {
                                HStack {
                                    Spacer()
                                    Text(message.content)
                                        .padding(10)
                                        .frame(width: 250)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(.blue.opacity(0.2))
                                        }
                                }
                                .id(message.id)
                            } else {
                                HStack {
                                    Text(message.content)
                                        .padding(10)
                                        .frame(width: 250)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(.gray.opacity(0.2))
                                        }
                                    Spacer()
                                }
                            }
                            
                        }
                        .onChange(of: vm.chat) { newValue in
                            if let last = newValue.last {
                                reader.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    Color.black.opacity(0.1)
                }
                
                HStack(alignment: .bottom) {
                    TextField("Escriba un mensaje", text: $vm.newLine)
                    Button(action: {
                        Task {
                            await vm.postLine()
                        }
                    }, label: {
                        Text("Enviar")
                    })
                }
                .padding()
            }
            .alert(isPresented: $vm.showError) {
                Alert(title: Text("Error"), message: Text(vm.errorMsg), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
