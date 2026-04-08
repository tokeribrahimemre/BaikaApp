//
//  StoryLoadingViewController.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 6.04.2026.
//

import UIKit

protocol StoryLoadingDelegate: AnyObject {
    func storyLoadingDidFinish(with story: GeneratedStory)
    func storyLoadingDidFail(with error: Error)
}

struct GeneratedStory {
    let title: String
    let subtitle: String
    let emojis: String
    let content: String
    let childName: String
    let character: String
    let characterEmoji: String
    let place: String
    let theme: String
    let ageGroup: String
}

class StoryLoadingViewController: UIViewController {

    weak var delegate: StoryLoadingDelegate?

    var storyParameters: StoryParameters!

    // MARK: - UI Elements

    private let starImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        iv.image = UIImage(systemName: "sparkles", withConfiguration: config)
        iv.tintColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Masal hazırlanıyor..."
        label.textColor = .white
        label.font = UIFont(name: "Nunito-Bold", size: 20) ?? .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Yapay zeka hikayenizi yazıyor"
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont(name: "Nunito-Regular", size: 14) ?? .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dotsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private var dotViews: [UIView] = []
    private var rotationTimer: Timer?
    private var dotsTimer: Timer?
    private var currentDotIndex = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startAnimations()
        generateStory()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 35/255, alpha: 1.0)
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(starImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(dotsStackView)

        // Dots
        let purpleColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
        for i in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = i == 0 ? purpleColor : purpleColor.withAlphaComponent(0.3)
            dot.layer.cornerRadius = 6
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 12).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 12).isActive = true
            dotViews.append(dot)
            dotsStackView.addArrangedSubview(dot)
        }

        NSLayoutConstraint.activate([
            starImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            starImageView.widthAnchor.constraint(equalToConstant: 80),
            starImageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            dotsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            dotsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Animations

    private func startAnimations() {
        // Yıldız dönme animasyonu
        startRotation()
        // Nokta animasyonu
        dotsTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            self?.animateDots()
        }
    }

    private func startRotation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 2.0
        rotation.repeatCount = .infinity
        rotation.isRemovedOnCompletion = false
        starImageView.layer.add(rotation, forKey: "rotationAnimation")
    }

    private func animateDots() {
        let purpleColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
        currentDotIndex = (currentDotIndex + 1) % dotViews.count

        UIView.animate(withDuration: 0.3) {
            for (i, dot) in self.dotViews.enumerated() {
                dot.backgroundColor = i == self.currentDotIndex ? purpleColor : purpleColor.withAlphaComponent(0.3)
                dot.transform = i == self.currentDotIndex ? CGAffineTransform(scaleX: 1.3, y: 1.3) : .identity
            }
        }
    }

    private func stopAnimations() {
        starImageView.layer.removeAllAnimations()
        dotsTimer?.invalidate()
        dotsTimer = nil
    }

    // MARK: - Generate Story

    private func generateStory() {
        let service = StoryService()

        Task {
            do {
                let text = try await service.generateStory(parameters: storyParameters)
                // Dinamik başlık: "Ev ve Ayıcık'ın Masalı" veya fallback
                let dynamicTitle: String
                let name = self.storyParameters.childName.trimmingCharacters(in: .whitespacesAndNewlines)
                let character = self.storyParameters.character.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !name.isEmpty && !character.isEmpty {
                    dynamicTitle = "\(name) ve \(character)'ın Masalı"
                } else if !name.isEmpty {
                    dynamicTitle = "\(name)'ın Masalı"
                } else if !character.isEmpty {
                    dynamicTitle = "\(character)'ın Masalı"
                } else {
                    dynamicTitle = "Yapay Zeka Masalı"
                }

                let generated = GeneratedStory(
                    title: dynamicTitle,
                    subtitle: "\(self.storyParameters.ageGroup) yaş grubu",
                    emojis: extractEmojis(from: text),
                    content: text,
                    childName: self.storyParameters.childName,
                    character: self.storyParameters.character,
                    characterEmoji: EmojiImageHelper.characterEmoji(for: self.storyParameters.character),
                    place: self.storyParameters.place,
                    theme: self.storyParameters.theme,
                    ageGroup: self.storyParameters.ageGroup
                )

                await MainActor.run {
                    self.stopAnimations()
                    
                    let storyboard = UIStoryboard(name: "StoryRead", bundle: nil)
                    let readVC = storyboard.instantiateViewController(withIdentifier: "StoryReadVC") as! StoryReadViewController
                    readVC.story = generated
                    readVC.modalPresentationStyle = .fullScreen
                    present(readVC, animated: true)
                    
                }
            } catch {
                await MainActor.run {
                    self.stopAnimations()
                    self.showError(error)
                }
            }
        }
    }

    private func extractEmojis(from text: String) -> String {
        let firstLine = text.components(separatedBy: "\n").first ?? ""
        let emojis = firstLine.unicodeScalars.filter { $0.properties.isEmoji && !$0.properties.isEmojiPresentation || $0.properties.isEmojiPresentation }.map { String($0) }.joined()
        return emojis.isEmpty ? "✨📖" : emojis
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Hata", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Geri Dön", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
