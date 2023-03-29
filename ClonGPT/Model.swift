//
//  Model.swift
//  ClonGPT
//
//  Created by JSANCAGU on 29/3/23.
//

import Foundation

/*
 {
  "model": "gpt-3.5-turbo",
  "messages": [{"role": "user", "content": "Hello!"}]
 }
 */

struct GPTRequest: Codable {
    var model = "gpt-3.5-turbo"
    let messages: [Message]
}

struct Message: Codable, Identifiable, Hashable {
    let id = UUID()
    let role: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case role, content
    }
}

/*
 {
   "id": "chatcmpl-123",
   "object": "chat.completion",
   "created": 1677652288,
   "choices": [{
     "index": 0,
     "message": {
       "role": "assistant",
       "content": "\n\nHello there, how may I assist you today?",
     },
     "finish_reason": "stop"
   }],
   "usage": {
     "prompt_tokens": 9,
     "completion_tokens": 12,
     "total_tokens": 21
   }
 }

 */

struct GPTResponse: Codable {
    let id: String
    let created: Int
    let choices: [Choice]
    let usage: Usage
}

struct Choice: Codable {
    let index: Int
    let message: Message
    let finishReason: String
    
    enum Codingkeys: String, CodingKey {
        case index, message
        case finisReason = "finish_reason"
    }
}

struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum Codingkeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
