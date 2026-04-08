//
//  StoryDetailsViewModel.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 8.04.2026.
//

//
//  StoryDetailsViewModel.swift
//  BaikaApp
//

import Foundation

enum SpeechState {
    case idle
    case loading
    case paused
    case playing
}
    

class StoryDetailsViewModel {

    // MARK: - Properties

    let story: Story
    private let speechService: SpeechService

    // MARK: - Bindings

    var onSpeechStateChanged: ((SpeechState) -> Void)?
    var onHighlight: ((_ fullText: String, _ sentenceRange: NSRange, _ characterRange: NSRange) -> Void)?
    var onResetText: ((String) -> Void)?

    private(set) var speechState: SpeechState = .idle {
        didSet { onSpeechStateChanged?(speechState) }
    }

    // MARK: - Computed

    var title: String { story.title }
    var ageCategory: String { story.ageCategory }
    var time: String { story.time }
    var themeCategory: String { story.themeCategory }
    var imageURL: String { story.imageURL }
    var descriptionText: String { story.description }

    // MARK: - Init

    init(story: Story, speechService: SpeechService = SpeechService()) {
        self.story = story
        self.speechService = speechService
        self.speechService.delegate = self
    }

    // MARK: - Actions

    func togglePlayback() {
        switch speechState {
        case .idle:
            speechState = .loading
            speechService.startSpeaking(text: story.description)
        case .playing:
            speechService.pause()
            speechState = .paused
        case .paused:
            speechService.resume()
            speechState = .playing
        case .loading:
            break
        }
    }

    func stopPlayback() {
        speechService.stop()
        speechState = .idle
        onResetText?(story.description)
    }
}

// MARK: - SpeechServiceDelegate

extension StoryDetailsViewModel: SpeechServiceDelegate {

    func speechDidStart() {
        speechState = .playing
    }

    func speechDidHighlight(characterRange: NSRange, sentenceRange: NSRange) {
        onHighlight?(story.description, sentenceRange, characterRange)
    }

    func speechDidFinish() {
        speechState = .idle
        onResetText?(story.description)
    }
}
