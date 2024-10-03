//
//  SampleView.swift
//  Nomad
//
//  Created by Ethan Ignatius on 2024-10-03.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let speechSynthesizer = AVSpeechSynthesizer()
    var speakButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the button programmatically
        speakButton = UIButton(type: .system)
        speakButton.setTitle("Speak", for: .normal)
        speakButton.backgroundColor = .systemBlue
        speakButton.setTitleColor(.white, for: .normal)
        speakButton.layer.cornerRadius = 10
        speakButton.translatesAutoresizingMaskIntoConstraints = false

        // Add the button to the view
        view.addSubview(speakButton)
        
        // Set constraints for the button
        NSLayoutConstraint.activate([
            speakButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speakButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            speakButton.widthAnchor.constraint(equalToConstant: 200),
            speakButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Link button action to the function
        speakButton.addTarget(self, action: #selector(onSpeakButtonPressed), for: .touchUpInside)
    }

    // Function to trigger Text-to-Speech
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5

        speechSynthesizer.speak(utterance)
    }

    // Action for button press
    @objc func onSpeakButtonPressed() {
        speak(text: "Hello! This is a Text-to-Speech example.")
    }
}

