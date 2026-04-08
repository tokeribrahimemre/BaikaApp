//
//  CreateAIStoryViewController.swift
//  BaikaApp
//

import UIKit

// MARK: - Step Data Models

struct StepOption {
    let emoji: String
    let title: String
    var isSelected: Bool = false
}

struct Step {
    let title: String
    let subtitle: String
    let type: StepType
    var options: [StepOption]
}

enum StepType {
    case textInput
    case gridSelection
    case listSelection
}

// MARK: - CreateAIStoryViewController

class CreateAIStoryViewController: UIViewController {

    // MARK: - UI Elements

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Hikaye Oluştur"
        label.textColor = .white
        label.font = UIFont(name: "Nunito-Bold", size: 20) ?? .boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private var progressSegments: [UIView] = []

    private let pageIndicatorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont(name: "Nunito-Regular", size: 13) ?? .systemFont(ofSize: 13)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stepsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.isScrollEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TextInputStepCell.self, forCellWithReuseIdentifier: TextInputStepCell.identifier)
        cv.register(GridSelectionStepCell.self, forCellWithReuseIdentifier: GridSelectionStepCell.identifier)
        cv.register(ListSelectionStepCell.self, forCellWithReuseIdentifier: ListSelectionStepCell.identifier)
        return cv
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        return button
    }()

    // MARK: - Properties

    private var currentStep = 0
    private var childName: String = ""
    private var nextButtonBottomConstraint: NSLayoutConstraint!

    private var steps: [Step] = [
        Step(title: "Çocuğun Adı", subtitle: "Hikayedeki çocuğun adını girin", type: .textInput, options: []),
        Step(title: "Ana Karakter", subtitle: "Ana karakteri seçin", type: .gridSelection, options: [
            StepOption(emoji: "🐻", title: "Ayı"),
            StepOption(emoji: "🐰", title: "Tavşan"),
            StepOption(emoji: "🐱", title: "Kedi"),
            StepOption(emoji: "🐶", title: "Köpek"),
            StepOption(emoji: "🦊", title: "Tilki"),
            StepOption(emoji: "🐟", title: "Balık")
        ]),
        Step(title: "Hikaye Yeri", subtitle: "Hikayenin geçtiği yeri seçin", type: .gridSelection, options: [
            StepOption(emoji: "🌳", title: "Orman"),
            StepOption(emoji: "🌊", title: "Deniz"),
            StepOption(emoji: "🏰", title: "Şato"),
            StepOption(emoji: "🌌", title: "Uzay"),
            StepOption(emoji: "🌸", title: "Bahçe"),
            StepOption(emoji: "🏔", title: "Dağ")
        ]),
        Step(title: "Tema", subtitle: "Hikayenin temasını seçin", type: .listSelection, options: [
            StepOption(emoji: "❤️", title: "Işıklık"),
            StepOption(emoji: "😊", title: "Pozitifma"),
            StepOption(emoji: "🌙", title: "Uyku"),
            StepOption(emoji: "🤝", title: "Arkadaşlık"),
            StepOption(emoji: "🌍", title: "Cesaret")
        ]),
        Step(title: "Yaş Grubu", subtitle: "Yaş grubunu seçin", type: .listSelection, options: [
            StepOption(emoji: "👶", title: "0-2 Yaş"),
            StepOption(emoji: "🧒", title: "3-4 Yaş"),
            StepOption(emoji: "👦", title: "5-8 Yaş")
        ])
    ]

    // MARK: - Computed Property

    private var isCurrentStepValid: Bool {
        let step = steps[currentStep]
        switch step.type {
        case .textInput:
            return !childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .gridSelection, .listSelection:
            return step.options.contains(where: { $0.isSelected })
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProgressBar()
        updatePageIndicator()
        updateNextButton()
        updateProgressBar()
        setupKeyboardObservers()
        setupTapToDismissKeyboard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateNextButtonGradient()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 35/255, alpha: 1.0)
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(backButton)
        view.addSubview(headerLabel)
        view.addSubview(progressStackView)
        view.addSubview(pageIndicatorLabel)
        view.addSubview(stepsCollectionView)
        view.addSubview(nextButton)

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        nextButtonBottomConstraint = nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            headerLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            headerLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            progressStackView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            progressStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            progressStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            progressStackView.heightAnchor.constraint(equalToConstant: 4),

            pageIndicatorLabel.topAnchor.constraint(equalTo: progressStackView.bottomAnchor, constant: 8),
            pageIndicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            stepsCollectionView.topAnchor.constraint(equalTo: pageIndicatorLabel.bottomAnchor, constant: 8),
            stepsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stepsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -86),

            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButtonBottomConstraint
        ])
    }

    // MARK: - Progress Bar

    private func setupProgressBar() {
        for _ in 0..<steps.count {
            let segment = UIView()
            segment.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            segment.layer.cornerRadius = 2
            segment.clipsToBounds = true
            progressSegments.append(segment)
            progressStackView.addArrangedSubview(segment)
        }
    }

    private func updateProgressBar() {
        let activeColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
        let inactiveColor = UIColor.white.withAlphaComponent(0.15)

        for (index, segment) in progressSegments.enumerated() {
            UIView.animate(withDuration: 0.3) {
                segment.backgroundColor = index <= self.currentStep ? activeColor : inactiveColor
            }
        }
    }

    private func updatePageIndicator() {
        pageIndicatorLabel.text = "Adım \(currentStep + 1)/\(steps.count)"
    }

    // MARK: - Next Button

    private func updateNextButton() {
        let isLastStep = currentStep == steps.count - 1
        let title = isLastStep ? "Hikaye Oluştur 🪄" : "Devam →"
        let valid = isCurrentStepValid

        nextButton.setTitle(title, for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "Nunito-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
        nextButton.isEnabled = valid

        if valid {
            nextButton.setTitleColor(.white, for: .normal)
            nextButton.alpha = 1.0
        } else {
            nextButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .normal)
            nextButton.alpha = 0.45
        }

        updateNextButtonGradient()
    }

    private func updateNextButtonGradient() {
        nextButton.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

        let gradientLayer = CAGradientLayer()

        if isCurrentStepValid {
            gradientLayer.colors = [
                UIColor(red: 100/255, green: 60/255, blue: 200/255, alpha: 1.0).cgColor,
                UIColor(red: 150/255, green: 80/255, blue: 220/255, alpha: 1.0).cgColor
            ]
        } else {
            gradientLayer.colors = [
                UIColor.white.withAlphaComponent(0.08).cgColor,
                UIColor.white.withAlphaComponent(0.08).cgColor
            ]
        }

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = nextButton.bounds
        gradientLayer.cornerRadius = 25
        nextButton.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - Actions

    @objc private func backTapped() {
        if currentStep > 0 {
            currentStep -= 1
            scrollToCurrentStep()
            updatePageIndicator()
            updateNextButton()
            updateProgressBar()
        } else {
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true)
            }
        }
    }

    @objc private func nextTapped() {
        guard isCurrentStepValid else { return }

        if currentStep == steps.count - 1 {
            createStory()
            return
        }
        currentStep += 1
        scrollToCurrentStep()
        updatePageIndicator()
        updateNextButton()
        updateProgressBar()
    }

    private func scrollToCurrentStep() {
        let indexPath = IndexPath(item: currentStep, section: 0)
        stepsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    private func createStory() {
        let selectedCharacter = steps[1].options.first(where: { $0.isSelected })?.title ?? ""
        let selectedPlace = steps[2].options.first(where: { $0.isSelected })?.title ?? ""
        let selectedTheme = steps[3].options.first(where: { $0.isSelected })?.title ?? ""
        let selectedAge = steps[4].options.first(where: { $0.isSelected })?.title ?? ""

        let params = StoryParameters(
            childName: childName,
            character: selectedCharacter,
            place: selectedPlace,
            theme: selectedTheme,
            ageGroup: selectedAge
        )
            
        let storyboard = UIStoryboard(name: "StoryLoading", bundle: nil)
        let loadingVC = storyboard.instantiateViewController(withIdentifier: "StoryLoadingVC") as! StoryLoadingViewController
        loadingVC.storyParameters = params
        loadingVC.modalPresentationStyle = .fullScreen
        present(loadingVC, animated: true)
    }

    // MARK: - Keyboard Handling

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setupTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        nextButtonBottomConstraint.constant = -(keyboardHeight + 16)

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16)) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        nextButtonBottomConstraint.constant = -16

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16)) {
            self.view.layoutIfNeeded()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension CreateAIStoryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return steps.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let step = steps[indexPath.item]

        switch step.type {
        case .textInput:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextInputStepCell.identifier, for: indexPath) as! TextInputStepCell
            cell.configure(with: step)
            cell.onTextChanged = { [weak self] text in
                guard let self = self else { return }
                self.childName = text
                self.updateNextButton()
            }
            return cell

        case .gridSelection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridSelectionStepCell.identifier, for: indexPath) as! GridSelectionStepCell
            cell.configure(with: step)
            cell.onOptionSelected = { [weak self] selectedIndex in
                guard let self = self else { return }
                for i in 0..<self.steps[indexPath.item].options.count {
                    self.steps[indexPath.item].options[i].isSelected = (i == selectedIndex)
                }
                self.updateNextButton()
            }
            return cell

        case .listSelection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListSelectionStepCell.identifier, for: indexPath) as! ListSelectionStepCell
            cell.configure(with: step)
            cell.onOptionSelected = { [weak self] selectedIndex in
                guard let self = self else { return }
                for i in 0..<self.steps[indexPath.item].options.count {
                    self.steps[indexPath.item].options[i].isSelected = (i == selectedIndex)
                }
                self.updateNextButton()
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}
