//
//  AIAssistantViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import ChatGPTSwift

class AIAssistantViewModel: ObservableObject {
    private let api : ChatGPTAPI;
    
    init(apiKey: String) {
            self.api = ChatGPTAPI(apiKey: apiKey)
        }
    
    func sendMessage(_ message: String) {
            Task {
                do {
                    let stream = try await api.sendMessageStream(text: message)
                    for try await response in stream {
                        print(response)
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    
    
    func testing() {
        let aiAssistant = AIAssistantViewModel(apiKey: "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")
        aiAssistant.sendMessage("How to define gratitude?")
    }

}
