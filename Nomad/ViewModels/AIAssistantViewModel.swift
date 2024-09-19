//
//  AIAssistantViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import ChatGPTSwift

class AIAssistantViewModel: ObservableObject {
    
    
//    func getYelpBusinesses() async {
//
//        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.timeoutInterval = 11
//        request.allHTTPHeaderFields = [
//          "accept": "application/json",
//          "Authorization": "hpQdyXearQyP-ahpSeW2wDZvn-ljfmsGvN6RTKqo18I6R23ZB3dfbzAnEjvS8tWoPwyH9FFTGifdZ-n_qH80jbRuDbGb0dHu1qEPrLH-vqNq_d6TZdUaC_kZpwvqZnYx"
//        ]
//
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//            print(String(decoding: data, as: UTF8.self))
//            // Handle the data and response here
//        } catch {
//            // Handle the error here
//            print("Error fetching data: \(error.localizedDescription)")
//        }
//    }
    
//    func getChatGPT(completion: @escaping (String) -> ()) async {
//        let apiKey = ChatGPTAPI(apiKey: "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")
//        
//        let question:String = "where is Atlanta?"
//        var result = ""
//        Task {
//            do {
//                let stream = try await apiKey.sendMessageStream(text: question)
//                for try await line in stream {
//                    //print("result: " + line)
//                    result += line
//                }
//                completion(result)
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//        
//    }
    
    func getChatGPT() async -> (String)  {
        let apiKey = ChatGPTAPI(apiKey: "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")
        
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
