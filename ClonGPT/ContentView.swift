//
//  ContentView.swift
//  ClonGPT
//
//  Created by JSANCAGU on 29/3/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var vm = GPTViewModel()
    @State private var showingAPISettings = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack() {
                    Spacer()
                    Button(action: {
                        self.showingAPISettings = true
                    }) {
                        Image(systemName: "key.fill")
                            .renderingMode(.template)
                            .foregroundColor(Color.blue)
                            .padding(.trailing, 30)
                    }
                    .sheet(isPresented: $showingAPISettings) {
                        APISettingsView()
                    }
                }
                
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
                .scrollDismissesKeyboard(.immediately)
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    Color.black.opacity(0.1)
                }
                
                HStack(alignment: .bottom) {
                    TextField("Escriba un mensaje", text: $vm.newLine, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                    Button(action: {
                        hideKeyboard()
                        if vm.newLine != "" {
                            Task {
                                await vm.postLine()
                            }
                        }
                    }, label: {
                        Image(systemName: "paperplane.fill")
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

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
