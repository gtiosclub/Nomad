//
//  VoiceInput.swift
//  Nomad
//
//  Created by Ganden Fung on 10/3/24.
//

import Foundation

struct VoiceInput: Identifiable, Codable {
    let id: UUID
    var transcript: String?
    
    init(id: UUID = UUID(), transcript: String? = nil) {
        self.id = id
        self.transcript = transcript
    }
}
