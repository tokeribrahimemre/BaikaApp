//
//  FavoritesViewController.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 15.03.2026.
//

import UIKit
import FirebaseAILogic

class FavoritesViewController: UIViewController {

    let storyTextView = UITextView()
        let generateButton = UIButton(type: .system)
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        
        // ViewModel Entegrasyonu
        private let viewModel = StoryViewModel()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            bindViewModel() // ViewModel'i dinlemeye başla
        }
        
        // MARK: - Data Binding
        private func bindViewModel() {
            viewModel.onStateChange = { [weak self] state in
                self?.updateUI(for: state)
            }
        }
        
        // State'e göre UI'ın nasıl davranacağı
        private func updateUI(for state: StoryViewState) {
            switch state {
            case .idle:
                storyTextView.text = "Masal oluşturmak için butona tıklayın."
                activityIndicator.stopAnimating()
                generateButton.isEnabled = true
                
            case .loading:
                storyTextView.text = "Baika masalı yazıyor...\nLütfen bekleyin."
                activityIndicator.startAnimating()
                generateButton.isEnabled = false
                
            case .success(let storyText):
                storyTextView.text = storyText
                activityIndicator.stopAnimating()
                generateButton.isEnabled = true
                generateButton.setTitle("Yeni Masal Oluştur", for: .normal)
                
            case .error(let errorMessage):
                storyTextView.text = "Bir hata oluştu:\n\(errorMessage)"
                activityIndicator.stopAnimating()
                generateButton.isEnabled = true
            }
        }
        
        // MARK: - User Actions
        @objc func generateStoryTapped() {
            // Gerçek uygulamada buradaki değerleri TextFiel'lardan (örn: nameTextField.text) alacaksın
            viewModel.fetchStory(
                childName: "Adam",
                character: "Tilki",
                setting: "Bahçe",
                theme: "Arkadaşlık",
                ageGroup: "5-8 Yaş"
            )
        }
        
        // MARK: - UI Setup (Basit Tasarım Kurulumu)
        private func setupUI() {
            view.backgroundColor = .white
            
            generateButton.setTitle("Masal Oluştur", for: .normal)
            generateButton.addTarget(self, action: #selector(generateStoryTapped), for: .touchUpInside)
            generateButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(generateButton)
            
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.hidesWhenStopped = true
            view.addSubview(activityIndicator)
            
            storyTextView.isEditable = false
            storyTextView.font = .systemFont(ofSize: 16)
            storyTextView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(storyTextView)
            
            NSLayoutConstraint.activate([
                generateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                generateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                activityIndicator.centerYAnchor.constraint(equalTo: generateButton.centerYAnchor),
                activityIndicator.leadingAnchor.constraint(equalTo: generateButton.trailingAnchor, constant: 10),
                
                storyTextView.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 20),
                storyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                storyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                storyTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ])
            
            // Başlangıç state'ini ayarla
            updateUI(for: .idle)
        }
    }
