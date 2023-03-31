//
//  IntentHandler.swift
//  SiriIntent
//
//  Created by JSANCAGU on 31/3/23.
//

import Intents

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

class IntentHandler: INExtension, INSendMessageIntentHandling, INSearchForMessagesIntentHandling, INSetMessageAttributeIntentHandling {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    var intent: INIntent?
    
    // MARK: - INSendMessageIntentHandling
    
    // Implement resolution methods to provide additional information about your intent (optional).
    func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INSendMessageRecipientResolutionResult]) -> Void) {
        if let recipients = intent.recipients {
            
            // If no recipients were provided we'll need to prompt for a value.
            if recipients.count == 0 {
                completion([INSendMessageRecipientResolutionResult.needsValue()])
                return
            }
            
            var resolutionResults = [INSendMessageRecipientResolutionResult]()
            for recipient in recipients {
                let matchingContacts = [recipient] // Implement your contact matching logic here to create an array of matching contacts
                switch matchingContacts.count {
                case 2  ... Int.max:
                    // We need Siri's help to ask user to pick one from the matches.
                    resolutionResults += [INSendMessageRecipientResolutionResult.disambiguation(with: matchingContacts)]
                    
                case 1:
                    // We have exactly one matching contact
                    resolutionResults += [INSendMessageRecipientResolutionResult.success(with: recipient)]
                    
                case 0:
                    // We have no contacts matching the description provided
                    resolutionResults += [INSendMessageRecipientResolutionResult.unsupported()]
                    
                default:
                    break
                    
                }
            }
            completion(resolutionResults)
        } else {
            completion([INSendMessageRecipientResolutionResult.needsValue()])
        }
    }
    
    func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(INStringResolutionResult.success(with: text))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
    
    func confirm(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Verify user is authenticated and your app is ready to send a message.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
        completion(response)
    }
    
    // Handle the completed intent (required)

    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        
        let chatGPTRecipient = INPerson(personHandle: INPersonHandle(value: "ClonGPT", type: .unknown), nameComponents: nil, displayName: "Chat GPT", image: nil, contactIdentifier: nil, customIdentifier: nil)

        guard let message = intent.content else {
            completion(INSendMessageIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        sendToChatGPT(message: message) { messages in
            let userActivity = NSUserActivity(activityType: "com.example.myApp.myIntent")
            let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
            response.sentMessages = messages.map { message in
                let recipient = chatGPTRecipient
                let message = INMessage(identifier: UUID().uuidString, content: message.content, dateSent: Date(), sender: nil, recipients: [recipient])
                UserDefaults(suiteName: "group.clongpt.api")?.set(message.content, forKey: "respuesta")
                return message
            }
            
            completion(response)
        }
    }

    func sendToChatGPT(message: String, completionHandler: @escaping ([Message]) -> Void) {
        let API_KEY = UserDefaults(suiteName: "group.clongpt.api")?.string(forKey: "ChatGPTAPIKey") ?? ""
        print(API_KEY)
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData = try? JSONEncoder().encode(GPTRequest(messages: [Message(role: "user", content: message)]))

        request.httpBody = requestData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completionHandler([])
                return
            }
            
            if let requestDataString = String(data: data, encoding: .utf8) {
                print(requestDataString)
            }

            guard let gptResponse = try? JSONDecoder().decode(GPTResponse.self, from: data) else {
                print("Error: Couldn't decode GPTResponse")
                completionHandler([])
                return
            }

            if let answer = gptResponse.choices.first?.message {
                let answerMessage = Message(role: answer.role, content: answer.content.replacingOccurrences(of: "\n", with: ""))
                completionHandler([answerMessage])
            } else {
                completionHandler([])
            }
        }

        task.resume()
    }

    
//    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
//        // Implement your application logic to send a message here.
//
//        let content = intent.content
//        print(content!)
//
//        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
//        let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
//
//
//
//
//
//        completion(response)
//    }
    
    // Implement handlers for each intent you wish to handle.  As an example for messages, you may wish to also handle searchForMessages and setMessageAttributes.
    
    // MARK: - INSearchForMessagesIntentHandling
    
    func handle(intent: INSearchForMessagesIntent, completion: @escaping (INSearchForMessagesIntentResponse) -> Void) {
        // Implement your application logic to find a message that matches the information in the intent.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSearchForMessagesIntent.self))
        let response = INSearchForMessagesIntentResponse(code: .success, userActivity: userActivity)
        // Initialize with found message's attributes
        response.messages = [INMessage(
            identifier: "identifier",
            content: "I am so excited about SiriKit!",
            dateSent: Date(),
            sender: INPerson(personHandle: INPersonHandle(value: "sarah@example.com", type: .emailAddress), nameComponents: nil, displayName: "Sarah", image: nil,  contactIdentifier: nil, customIdentifier: nil),
            recipients: [INPerson(personHandle: INPersonHandle(value: "+1-415-555-5555", type: .phoneNumber), nameComponents: nil, displayName: "John", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
            )]
        completion(response)
    }
    
    // MARK: - INSetMessageAttributeIntentHandling
    
    func handle(intent: INSetMessageAttributeIntent, completion: @escaping (INSetMessageAttributeIntentResponse) -> Void) {
        // Implement your application logic to set the message attribute here.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSetMessageAttributeIntent.self))
        let response = INSetMessageAttributeIntentResponse(code: .success, userActivity: userActivity)
        completion(response)
    }
}
