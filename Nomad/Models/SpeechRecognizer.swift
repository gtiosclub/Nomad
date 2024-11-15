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
    
    static let shared = SpeechRecognizer()  // Singleton instance

    @Published var audioLevel: CGFloat = 0.0
    
    @Published @MainActor var hasTimerRun: Bool = false
    @Published @MainActor var isListening: Bool = false
    @Published @MainActor var atlasSaid: Bool = false
    
    @Published @MainActor var voiceRecordingTranscript: String = ""

    
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
        //pollForAtlas()
    }
    
    @MainActor func startTranscribing() {
        Task {
            await reset()
            isListening = true
            await transcribe()
            hasTimerRun = false
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
            isListening = false
            hasTimerRun = false
            await pollForAtlas()
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
    
    func pollForAtlas() {
        guard let recognizer, recognizer.isAvailable else {
            self.transcribe(RecognizerError.recognizerIsUnavailable)
            return
        }
        
        do {
            let (audioEngine, request) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            self.task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                self?.pollAtlasHandler(audioEngine: audioEngine, result: result, error: error)
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
            SpeechRecognizer.processAudioBuffer(buffer: buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    static func processAudioBuffer(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        
        // Calculate RMS (Root Mean Square) for the audio levels
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let level = max(0, CGFloat(rms) * 20)  // Scale the value for display
        
        DispatchQueue.main.async {
            SpeechRecognizer.shared.audioLevel = level
        }
    }
    
    nonisolated private func pollAtlasHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil

        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        if let result {
            let transcription = result.bestTranscription.formattedString.lowercased()
            print(transcription)
            
            if transcription.contains("atlas") {
                print("lalalalala")
                Task { @MainActor in
                    atlasSaid = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.atlasSaid = false
                    }
                }
            }
        }
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
            
            Task { @MainActor in
                guard isListening else { return }
            }

            // Transcribe the result
            transcribe(transcription)

            //print("Have transcribed")
            
            //send to the view model
            
            //start monitoring for silence
            Task { @MainActor in
                print("New transcription received: \(transcription)")
                // self.silenceTimer?.invalidate()  // Invalidate any previous timer
                await self.startSilenceTimer()         // Start a new silence timer
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

    private func startSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        print("silence timer is invalidated")
        DispatchQueue.main.async {
            self.silenceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    print("Sending Transcript: \(self?.voiceRecordingTranscript)")
                    if(self?.hasTimerRun == false && self?.transcript != "")
                    {
                        self?.voiceRecordingTranscript = self?.transcript ?? ""
                        print("Voice Recording Transcript: \(self?.voiceRecordingTranscript)")
                        self?.stopTranscribing()
                        print("we have stopped transcribing because of silence")

                    }
                    self?.hasTimerRun = true
                    
                    
                    //self?.updateTranscriptAfterSilence(with: capturedTranscript)
                    print("Speech recognition stopped after 2 seconds of silence.")
                }
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
