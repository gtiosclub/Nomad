//
//  AIAssistantViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import ChatGPTSwift

class AIAssistantViewModel: ObservableObject {
    
    
    func getChatGPT() async -> (String)  {
        let apiKey = ChatGPTAPI(apiKey: "*Put api key*")
        
        let question:String = "where is Atlanta?"
        var result = ""
        do {
            let response = try await apiKey.sendMessage(text: question)
            return response
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
}
