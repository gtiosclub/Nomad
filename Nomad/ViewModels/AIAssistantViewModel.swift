//
//  AIAssistantViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

class AIAssistantViewModel: ObservableObject {
    
    
    func getYelpBusinesses() async {

        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 11
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": "hpQdyXearQyP-ahpSeW2wDZvn-ljfmsGvN6RTKqo18I6R23ZB3dfbzAnEjvS8tWoPwyH9FFTGifdZ-n_qH80jbRuDbGb0dHu1qEPrLH-vqNq_d6TZdUaC_kZpwvqZnYx"
        ]

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print(String(decoding: data, as: UTF8.self))
            // Handle the data and response here
        } catch {
            // Handle the error here
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}
