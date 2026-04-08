import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    // MARK: - UI Elements

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: config), for: .normal)
        button.tintColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Ayarlar"
        label.textColor = .white
        label.font = UIFont(name: "Nunito-Bold", size: 20) ?? .boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let voiceSwitch = UISwitch()
    private var voiceSubtitleLabel: UILabel?

    // MARK: - Colors

    private let bgColor = UIColor(red: 15/255, green: 14/255, blue: 42/255, alpha: 1.0)
    private let cardColor = UIColor(red: 22/255, green: 21/255, blue: 50/255, alpha: 1.0)
    private let purpleColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Kaydedilmiş ses ayarını yükle (varsayılan: true/açık)
        let isSoundOn = UserDefaults.standard.object(forKey: "isSoundEnabled") as? Bool ?? true
        voiceSwitch.isOn = isSoundOn
        voiceSwitch.addTarget(self, action: #selector(voiceSwitchChanged(_:)), for: .valueChanged)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = bgColor
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(backButton)
        view.addSubview(headerLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            headerLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            headerLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        buildSettingsContent()
    }

    // MARK: - Build Content

    private func buildSettingsContent() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])

        // 1) Ebeveyn Alanı kartı (highlight)
        stackView.addArrangedSubview(makeParentCard())
        stackView.setCustomSpacing(20, after: stackView.arrangedSubviews.last!)

        // 2) Ses satırı (toggle)
        stackView.addArrangedSubview(makeToggleRow(
            icon: "speaker.wave.2.fill",
            title: "Ses",
            subtitle: "Açık",
            toggle: voiceSwitch
        ))

        // 3) Karanlık Mod
        stackView.addArrangedSubview(makeInfoRow(
            icon: "moon.fill",
            iconColor: UIColor(red: 1, green: 0.85, blue: 0.35, alpha: 1),
            title: "Karanlık Mod",
            badgeText: "Varsayılan"
        ))

        // 4) Dil
        stackView.addArrangedSubview(makeInfoRow(
            icon: "globe",
            iconColor: UIColor.white.withAlphaComponent(0.5),
            title: "Dil",
            subtitle: "Türkçe",
            badgeText: "Yakında"
        ))

        // 5) Gizlilik
        stackView.addArrangedSubview(makeInfoRow(
            icon: "lock.shield.fill",
            iconColor: .white,
            title: "Gizlilik",
            subtitle: "Veri toplanmaz, giriş gerektirmez"
        ))

        // 6) Hakkında
        stackView.addArrangedSubview(makeInfoRow(
            icon: "info.circle.fill",
            iconColor: .white,
            title: "Hakkında",
            subtitle: "Masal Dünyası v1.0"
        ))

        stackView.setCustomSpacing(32, after: stackView.arrangedSubviews.last!)

        // 7) Footer
        stackView.addArrangedSubview(makeFooterView())
        stackView.setCustomSpacing(24, after: stackView.arrangedSubviews.last!)

        // 8) Çıkış Yap butonu
        stackView.addArrangedSubview(makeSignOutButton())
    }

    // MARK: - Ebeveyn Alanı Kartı

    private func makeParentCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 16
        card.clipsToBounds = true

        // Gradient arka plan
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 60/255, green: 30/255, blue: 120/255, alpha: 1.0).cgColor,
            UIColor(red: 30/255, green: 20/255, blue: 70/255, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 400, height: 80)
        card.layer.insertSublayer(gradientLayer, at: 0)

        // Border glow
        card.layer.borderWidth = 1
        card.layer.borderColor = purpleColor.withAlphaComponent(0.4).cgColor

        let iconBg = UIView()
        iconBg.backgroundColor = purpleColor.withAlphaComponent(0.3)
        iconBg.layer.cornerRadius = 20
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let iconImage = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        iconImage.image = UIImage(systemName: "person.2.fill", withConfiguration: config)
        iconImage.tintColor = .white
        iconImage.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Ebeveyn Alanı"
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Nunito-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Çocuğunuz için güvenli ayarlar"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.font = UIFont(name: "Nunito-Regular", size: 12) ?? .systemFont(ofSize: 12)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView()
        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = UIColor.white.withAlphaComponent(0.5)
        chevron.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconBg)
        iconBg.addSubview(iconImage)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(chevron)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 80),

            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconBg.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 40),
            iconBg.heightAnchor.constraint(equalToConstant: 40),

            iconImage.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 14),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])

        // Gradient'i layout sonrası boyutlandır
        card.layoutIfNeeded()
        DispatchQueue.main.async {
            gradientLayer.frame = card.bounds
        }

        return card
    }

    // MARK: - Toggle Row (Ses)

    private func makeToggleRow(icon: String, title: String, subtitle: String, toggle: UISwitch) -> UIView {
        let card = makeCardContainer()

        let iconView = makeIconView(systemName: icon, color: .white)
        
        // Kaydedilmiş duruma göre subtitle belirle
        let isSoundOn = UserDefaults.standard.object(forKey: "isSoundEnabled") as? Bool ?? true
        let labelsStack = makeLabelsStack(title: title, subtitle: isSoundOn ? "Açık" : "Kapalı")
        
        // Subtitle label referansını sakla
        if let subLabel = labelsStack.arrangedSubviews.last as? UILabel, labelsStack.arrangedSubviews.count > 1 {
            voiceSubtitleLabel = subLabel
        }

        toggle.onTintColor = purpleColor
        toggle.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconView)
        card.addSubview(labelsStack)
        card.addSubview(toggle)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 64),

            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 36),

            labelsStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            labelsStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -12),

            toggle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])

        return card
    }

    // MARK: - Info Row (subtitle veya badge)

    private func makeInfoRow(icon: String, iconColor: UIColor = .white, title: String, subtitle: String? = nil, badgeText: String? = nil) -> UIView {
        let card = makeCardContainer()

        let iconView = makeIconView(systemName: icon, color: iconColor)
        let labelsStack = makeLabelsStack(title: title, subtitle: subtitle)

        card.addSubview(iconView)
        card.addSubview(labelsStack)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 64),

            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 36),

            labelsStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            labelsStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])

        // Badge (Varsayılan / Yakında)
        if let badge = badgeText {
            let badgeLabel = UILabel()
            badgeLabel.text = badge
            badgeLabel.textColor = purpleColor
            badgeLabel.font = UIFont(name: "Nunito-SemiBold", size: 11) ?? .systemFont(ofSize: 11, weight: .semibold)
            badgeLabel.backgroundColor = purpleColor.withAlphaComponent(0.15)
            badgeLabel.textAlignment = .center
            badgeLabel.layer.cornerRadius = 10
            badgeLabel.clipsToBounds = true
            badgeLabel.translatesAutoresizingMaskIntoConstraints = false

            card.addSubview(badgeLabel)
            NSLayoutConstraint.activate([
                badgeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                badgeLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
                badgeLabel.heightAnchor.constraint(equalToConstant: 24),
            ])
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: badgeLabel.leadingAnchor, constant: -8).isActive = true
        } else {
            let chevron = UIImageView()
            chevron.image = UIImage(systemName: "chevron.right")
            chevron.tintColor = UIColor.white.withAlphaComponent(0.3)
            chevron.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(chevron)

            NSLayoutConstraint.activate([
                chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            ])
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8).isActive = true
        }

        return card
    }

    // MARK: - Footer

    private func makeFooterView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Masal Dünyası"
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.35)
        titleLabel.font = UIFont(name: "Nunito-SemiBold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Çocuklar için güvenli masal uygulaması"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.2)
        subtitleLabel.font = UIFont(name: "Nunito-Regular", size: 12) ?? .systemFont(ofSize: 12)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let emojisLabel = UILabel()
        emojisLabel.text = "🌙 ⭐ ✨"
        emojisLabel.font = .systemFont(ofSize: 28)
        emojisLabel.textAlignment = .center
        emojisLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(emojisLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            emojisLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            emojisLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        ])

        return container
    }

    // MARK: - Çıkış Yap Butonu

    private func makeSignOutButton() -> UIView {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.plain()
        config.title = "Çıkış Yap"
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
        config.baseForegroundColor = UIColor(red: 1, green: 0.35, blue: 0.35, alpha: 1)
        config.background.backgroundColor = UIColor(red: 1, green: 0.35, blue: 0.35, alpha: 0.1)
        config.background.cornerRadius = 14
        config.background.strokeColor = UIColor(red: 1, green: 0.35, blue: 0.35, alpha: 0.25)
        config.background.strokeWidth = 1
        config.imagePadding = 8
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont(name: "Nunito-Bold", size: 16) ?? .boldSystemFont(ofSize: 16)
            return outgoing
        }
        button.configuration = config
        button.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)

        button.heightAnchor.constraint(equalToConstant: 50).isActive = true

        return button
    }

    // MARK: - Helpers

    private func makeCardContainer() -> UIView {
        let card = UIView()
        card.backgroundColor = cardColor
        card.layer.cornerRadius = 14
        card.layer.borderWidth = 0.5
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.06).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }

    private func makeIconView(systemName: String, color: UIColor) -> UIView {
        let bg = UIView()
        bg.backgroundColor = color.withAlphaComponent(0.1)
        bg.layer.cornerRadius = 18
        bg.translatesAutoresizingMaskIntoConstraints = false

        let imgView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        imgView.image = UIImage(systemName: systemName, withConfiguration: config)
        imgView.tintColor = color
        imgView.translatesAutoresizingMaskIntoConstraints = false

        bg.addSubview(imgView)
        NSLayoutConstraint.activate([
            imgView.centerXAnchor.constraint(equalTo: bg.centerXAnchor),
            imgView.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
        ])

        return bg
    }

    private func makeLabelsStack(title: String, subtitle: String?) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Nunito-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        stack.addArrangedSubview(titleLabel)

        if let sub = subtitle {
            let subLabel = UILabel()
            subLabel.text = sub
            subLabel.textColor = UIColor.white.withAlphaComponent(0.4)
            subLabel.font = UIFont(name: "Nunito-Regular", size: 12) ?? .systemFont(ofSize: 12)
            stack.addArrangedSubview(subLabel)
        }

        return stack
    }

    // MARK: - Actions

    @objc private func voiceSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isSoundEnabled")
        voiceSubtitleLabel?.text = sender.isOn ? "Açık" : "Kapalı"
    }

    @objc private func signOutTapped() {
        let alert = UIAlertController(
            title: "Çıkış Yap",
            message: "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Çıkış Yap", style: .destructive) { [weak self] _ in
            self?.performSignOut()
        })
        present(alert, animated: true)
    }

    private func performSignOut() {
        do {
            try Auth.auth().signOut()

            // Cache'leri temizle
            FavoriteManager.shared.clearCache()
            CreatedStoriesManager.shared.clearCache()

            // Login ekranına yönlendir
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }

            let loginVC = LoginViewController()
            window.rootViewController = loginVC
            UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
        } catch {
            let alert = UIAlertController(title: "Hata", message: "Çıkış yapılırken bir hata oluştu.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
        }
    }
}
