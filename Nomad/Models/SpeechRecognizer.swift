//
//  SpeechRecognizer.swift
//  Nomad
//
//  Created by Ganden Fung on 10/3/24.
//

import Foundation
import AVFoundation
import Speech
import SwiftUI

private var silenceTimer: Timer?
//private var shouldTranscribe = true



/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
actor SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    @Published @MainActor var transcript: String = ""
    
    private var audioEngine: AVAudioEngine?
    private var silenceTimer: Timer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    

    
    /**
     Initializes a new speech recognizer. If this is the first time you've used the class, it
     requests access to the speech recognizer and the microphone.
     */
    init() {
        recognizer = SFSpeechRecognizer()
        guard recognizer != nil else {
            transcribe(RecognizerError.nilRecognizer)
            return
        }
        
        Task {
            do {
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                transcribe(error)
            }
        }
    }
    
    @MainActor func startTranscribing() {
        Task {
            await transcribe()
        }
    }
    
    @MainActor func resetTranscript() {
        Task {
            await reset()
        }
    }
    
    @MainActor func stopTranscribing() {
        Task {
            print("in the main actor Stop Transcribing")
            await reset()
        }
    }
    
    /**
     Begin transcribing audio.
     
     Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
     The resulting transcription is continuously written to the published `transcript` property.
     */
    private func transcribe() {
        guard let recognizer, recognizer.isAvailable else {
            self.transcribe(RecognizerError.recognizerIsUnavailable)
            return
        }
        
        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            self.task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                self?.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
            })
        } catch {
            self.reset()
            self.transcribe(error)
        }
    }
    
    /// Reset the speech recognizer.
    private func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    nonisolated private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) {
        
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil

        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        if let result {
            let transcription = result.bestTranscription.formattedString.lowercased()

            // Transcribe the result
            transcribe(transcription)
            //print("Have transcribed")
            
            //send to the view model
            
            //start monitoring for silence
            Task { @MainActor in
                //print("New transcription received: \(transcription)")
                // self.silenceTimer?.invalidate()  // Invalidate any previous timer
                //await self.startSilenceTimer()         // Start a new silence timer
            }
            
            // Check if the word "done" was spoken
            if transcription.contains("done") {
                print("Detected the word 'done', stopping transcription.")
                
                // Stop transcription by calling stopTranscribing()
                Task { @MainActor in
                    await stopTranscribing()  // Stop the transcription process
                }
            }
        }
    }

    
    
    nonisolated private func transcribe(_ message: String) {
        Task { @MainActor in
            //print("In nonisolaed private func transcribe")
            transcript = message
            print(transcript)
        }
    }
    nonisolated private func transcribe(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        Task { @MainActor [errorMessage] in
            transcript = "<< \(errorMessage) >>"
        }
    }
    
    // This function should be part of the audio setup
//    private func startMonitoringForSilence() {
//        let inputNode = audioEngine?.inputNode
//        let recordingFormat = inputNode?.outputFormat(forBus: 0)
//
//        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//            let level = self.averagePower(forBuffer: buffer)
//            if level < -30.0 {
//                print("Silence detected starting silence timer")
//                self.startSilenceTimer()
//            } else {
//                self.silenceTimer?.invalidate()
//            }
//        }
//    }
//
//    private func averagePower(forBuffer buffer: AVAudioPCMBuffer) -> Float {
//        let channelData = buffer.floatChannelData![0]
//        let channelDataValueArray = stride(from: 0,
//                                           to: Int(buffer.frameLength),
//                                           by: buffer.stride).map { channelData[$0] }
//
//        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
//        let avgPower = 20 * log10(rms)
//        return avgPower
//    }

    private func startSilenceTimer() {
        silenceTimer?.invalidate()
        print("silence timer is invalidated")
        DispatchQueue.main.async {
            self.silenceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                Task { @MainActor in
//                    print("Changing shouldTranscribe to false.")
//                    shouldTranscribe = false

                    // Stop recognition, but don't reset the transcript
                    self?.stopTranscribing()
                }
                print("Speech recognition stopped after 2 seconds of silence.")
            }
        }
    }
    
    private func stopAudioEngine() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        // Do not call reset() to preserve the transcript
    }
    
    
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
