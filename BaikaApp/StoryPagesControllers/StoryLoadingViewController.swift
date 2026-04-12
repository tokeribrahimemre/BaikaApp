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
    var audioStoragePath: String? = nil
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

    // MARK: - Error UI Elements

    private let errorContainerView: UIView = {
        let v = UIView()
        v.alpha = 0
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let errorIconView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        iv.image = UIImage(systemName: "exclamationmark.icloud.fill", withConfiguration: config)
        iv.tintColor = UIColor(red: 255/255, green: 100/255, blue: 100/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let errorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bir sorun oluştu"
        label.textColor = .white
        label.font = UIFont(name: "Nunito-Bold", size: 20) ?? .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Yapay zeka şu anda yoğun. Lütfen tekrar deneyin."
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont(name: "Nunito-Regular", size: 14) ?? .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tekrar Dene ✨", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Nunito-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let retryButtonGradient: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(red: 100/255, green: 60/255, blue: 200/255, alpha: 1.0).cgColor,
            UIColor(red: 150/255, green: 80/255, blue: 220/255, alpha: 1.0).cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0.5)
        gl.endPoint = CGPoint(x: 1, y: 0.5)
        gl.cornerRadius = 25
        return gl
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("İptal", for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
        button.titleLabel?.font = UIFont(name: "Nunito-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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

        // Error UI
        view.addSubview(errorContainerView)
        errorContainerView.addSubview(errorIconView)
        errorContainerView.addSubview(errorTitleLabel)
        errorContainerView.addSubview(errorMessageLabel)
        errorContainerView.addSubview(retryButton)
        errorContainerView.addSubview(cancelButton)

        retryButton.layer.insertSublayer(retryButtonGradient, at: 0)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

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
            dotsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Error container
            errorContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            errorIconView.topAnchor.constraint(equalTo: errorContainerView.topAnchor),
            errorIconView.centerXAnchor.constraint(equalTo: errorContainerView.centerXAnchor),
            errorIconView.widthAnchor.constraint(equalToConstant: 60),
            errorIconView.heightAnchor.constraint(equalToConstant: 60),

            errorTitleLabel.topAnchor.constraint(equalTo: errorIconView.bottomAnchor, constant: 20),
            errorTitleLabel.leadingAnchor.constraint(equalTo: errorContainerView.leadingAnchor),
            errorTitleLabel.trailingAnchor.constraint(equalTo: errorContainerView.trailingAnchor),

            errorMessageLabel.topAnchor.constraint(equalTo: errorTitleLabel.bottomAnchor, constant: 8),
            errorMessageLabel.leadingAnchor.constraint(equalTo: errorContainerView.leadingAnchor),
            errorMessageLabel.trailingAnchor.constraint(equalTo: errorContainerView.trailingAnchor),

            retryButton.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: 32),
            retryButton.leadingAnchor.constraint(equalTo: errorContainerView.leadingAnchor),
            retryButton.trailingAnchor.constraint(equalTo: errorContainerView.trailingAnchor),
            retryButton.heightAnchor.constraint(equalToConstant: 50),

            cancelButton.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 12),
            cancelButton.centerXAnchor.constraint(equalTo: errorContainerView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: errorContainerView.bottomAnchor)
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
                
                if text.contains("[ERROR_BAD_INPUT]") {
                    await MainActor.run {
                        self.stopAnimations()
                        let alert = UIAlertController(title: "Uyarı", message: "Yasaklı kelime kullanılamaz.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Tamam", style: .default) { _ in
                            self.dismiss(animated: true)
                        })
                        self.present(alert, animated: true)
                    }
                    return
                }
                
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

    // MARK: - Error Handling

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        retryButtonGradient.frame = retryButton.bounds
    }

    private func showError(_ error: Error) {
        // Loading elemanlarını gizle
        starImageView.isHidden = true
        titleLabel.isHidden = true
        subtitleLabel.isHidden = true
        dotsStackView.isHidden = true

        // Hata mesajını belirle
        let message: String
        if error.localizedDescription.contains("high demand") || error.localizedDescription.contains("INTERNAL") {
            message = "Yapay zeka şu anda yoğun.\nLütfen biraz bekleyip tekrar deneyin."
        } else {
            message = error.localizedDescription
        }
        errorMessageLabel.text = message

        // Error container'ı göster
        errorContainerView.isHidden = false
        UIView.animate(withDuration: 0.35) {
            self.errorContainerView.alpha = 1
        }
    }

    private func hideError() {
        errorContainerView.alpha = 0
        errorContainerView.isHidden = true

        starImageView.isHidden = false
        titleLabel.isHidden = false
        subtitleLabel.isHidden = false
        dotsStackView.isHidden = false
    }

    @objc private func retryTapped() {
        hideError()
        startAnimations()
        generateStory()
    }

    @objc private func cancelTapped() {
        // presentingViewController'ı dismiss öncesinde yakala
        let presenter = self.presentingViewController
        dismiss(animated: true) {
            // CreateAIStoryVC'yi de kapat → anasayfaya dön
            presenter?.dismiss(animated: true)
        }
    }
}
