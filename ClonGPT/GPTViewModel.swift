//
//  GPTViewMode.swift
//  ClonGPT
//
//  Created by JSANCAGU on 30/3/23.
//

import Foundation

final class GPTViewModel: ObservableObject {
    
    @Published var API_KEY = UserDefaults.standard.string(forKey: "ChatGPTAPIKey") ?? ""
    @Published var chat: [Message] = []
    @Published var newLine = ""
    @Published var showError = false
    @Published var errorMsg = ""
    
    @MainActor func postLine() async {
        do {
            chat.append(Message(role: "user", content: newLine))
            chat = try await postChat(conversation: chat)
            newLine = ""
        } catch let error {
            errorMsg = error.localizedDescription
            showError.toggle()
        }
    }
    
    func postChat(conversation: [Message]) async throws -> [Message] {
        print(API_KEY)
        let url = URL(string: "https://api.openai.com/v1/chat/completions")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData = try? JSONEncoder().encode(GPTRequest(messages: conversation))
        
        print("Salida: " + String(data: requestData!, encoding: .utf8)!)
        
        request.httpBody = requestData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
            let gptResponse = try JSONDecoder().decode(GPTResponse.self, from: data)
            if var answer = gptResponse.choices.first?.message {
                answer = Message(role: answer.role, content: answer.content.replacingOccurrences(of: "\n", with: ""))
                print("Entrada: \(answer)")
                return conversation + [answer]
            } else {
                return conversation
            }
        } catch let error {
            print(error)
        }
        return []
    }
    
}
