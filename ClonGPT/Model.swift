//
//  Model.swift
//  ClonGPT
//
//  Created by JSANCAGU on 29/3/23.
//

import Foundation

struct GPTRequest: Codable {
    var model = "gpt-3.5-turbo"
    let messages: [Message]
    //var max_tokens =
}

struct Message: Codable, Identifiable, Hashable {
    let id = UUID()
    let role: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case role, content
    }
}
struct GPTResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let choices: [Choice]
    let usage: Usage
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, choices, usage
    }
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let finishReason: String
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}


struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

