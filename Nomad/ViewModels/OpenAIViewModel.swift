//
//  ChatGPTViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import ChatGPTSwift

class OpenAIViewModel: ObservableObject {
    let gpt_api = ChatGPTAPI(apiKey: "")
}
