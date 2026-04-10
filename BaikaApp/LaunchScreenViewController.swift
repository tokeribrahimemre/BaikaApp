//
//  LaunchScreenViewController.swift
//  BaikaApp
//
//  Animated launch screen — moon, stars, floating book, sparkles
//

import UIKit

final class LaunchScreenViewController: UIViewController {

    // MARK: - Callback

    /// Animasyon bittiğinde çağrılır; SceneDelegate buradan asıl ekrana geçer.
    var onAnimationFinished: (() -> Void)?

    // MARK: - Colors

    private let bgTop    = UIColor(red: 8/255, green: 6/255, blue: 28/255, alpha: 1)
    private let bgBottom = UIColor(red: 22/255, green: 15/255, blue: 55/255, alpha: 1)
    private let purple   = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1)
    private let gold     = UIColor(red: 255/255, green: 215/255, blue: 80/255, alpha: 1)

    // MARK: - UI Elements

    private let gradientLayer = CAGradientLayer()

    /// 🌙 Ay
    private let moonView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 255/255, green: 235/255, blue: 150/255, alpha: 1)
        v.alpha = 0
        return v
    }()

    /// Ay ışığı glow
    private let moonGlow: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 255/255, green: 235/255, blue: 150/255, alpha: 0.15)
        v.alpha = 0
        return v
    }()

    /// ✨ Yıldız emoji'leri
    private var starLabels: [UILabel] = []

    /// 📖 Kitap emoji
    private let bookLabel: UILabel = {
        let l = UILabel()
        l.text = "📖"
        l.font = .systemFont(ofSize: 64)
        l.textAlignment = .center
        l.alpha = 0
        return l
    }()

    /// Parıltı parçacıkları
    private var sparkleViews: [UIView] = []

    /// "Baika" yazısı
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Baika"
        l.font = UIFont(name: "Nunito-Bold", size: 42) ?? .boldSystemFont(ofSize: 42)
        l.textColor = .white
        l.textAlignment = .center
        l.alpha = 0
        return l
    }()

    /// Alt yazı
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Masalların Büyülü Dünyası ✨"
        l.font = UIFont(name: "Nunito-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        l.textAlignment = .center
        l.alpha = 0
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupMoon()
        setupStars()
        setupBook()
        setupSparkles()
        setupTitle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runAnimationSequence()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup

    private func setupBackground() {
        gradientLayer.colors = [bgTop.cgColor, bgBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupMoon() {
        let moonSize: CGFloat = 80
        let glowSize: CGFloat = 160

        moonGlow.frame = CGRect(x: 0, y: 0, width: glowSize, height: glowSize)
        moonGlow.center = CGPoint(x: view.bounds.width * 0.75, y: 100)
        moonGlow.layer.cornerRadius = glowSize / 2
        view.addSubview(moonGlow)

        moonView.frame = CGRect(x: 0, y: 0, width: moonSize, height: moonSize)
        moonView.center = moonGlow.center
        moonView.layer.cornerRadius = moonSize / 2

        // Ay üzerindeki "hilal" efekti — küçük bir koyu daire
        let crescent = UIView(frame: CGRect(x: 15, y: 10, width: moonSize * 0.7, height: moonSize * 0.7))
        crescent.backgroundColor = bgTop
        crescent.layer.cornerRadius = moonSize * 0.35
        moonView.addSubview(crescent)

        view.addSubview(moonView)
    }

    private func setupStars() {
        let starEmojis = ["⭐", "✨", "💫", "⭐", "✨", "⭐", "💫", "✨", "⭐", "✨", "⭐", "💫"]
        let positions: [(CGFloat, CGFloat)] = [
            (0.15, 0.08), (0.35, 0.05), (0.55, 0.12), (0.85, 0.06),
            (0.1, 0.18),  (0.45, 0.15), (0.7, 0.2),   (0.9, 0.14),
            (0.25, 0.22), (0.6, 0.25),  (0.08, 0.28),  (0.78, 0.28)
        ]
        let sizes: [CGFloat] = [14, 10, 12, 16, 11, 13, 10, 15, 12, 11, 14, 10]

        for (i, emoji) in starEmojis.enumerated() {
            let label = UILabel()
            label.text = emoji
            label.font = .systemFont(ofSize: sizes[i])
            label.alpha = 0
            label.sizeToFit()

            let w = view.bounds.width
            let h = view.bounds.height
            label.center = CGPoint(x: w * positions[i].0, y: h * positions[i].1)
            view.addSubview(label)
            starLabels.append(label)
        }
    }

    private func setupBook() {
        bookLabel.sizeToFit()
        bookLabel.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 20)
        bookLabel.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        view.addSubview(bookLabel)
    }

    private func setupSparkles() {
        let sparkleCount = 20
        for _ in 0..<sparkleCount {
            let size: CGFloat = CGFloat.random(in: 4...10)
            let sparkle = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            sparkle.backgroundColor = [gold, purple, .white, gold][Int.random(in: 0...3)]
            sparkle.layer.cornerRadius = size / 2
            sparkle.alpha = 0

            let cx = view.bounds.midX + CGFloat.random(in: -120...120)
            let cy = view.bounds.midY + CGFloat.random(in: -80...80)
            sparkle.center = CGPoint(x: cx, y: cy)
            view.addSubview(sparkle)
            sparkleViews.append(sparkle)
        }
    }

    private func setupTitle() {
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY + 60)
        view.addSubview(titleLabel)

        subtitleLabel.sizeToFit()
        subtitleLabel.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY + 100)
        view.addSubview(subtitleLabel)
    }

    // MARK: - Animation Sequence

    private func runAnimationSequence() {

        // 1️⃣ Ay belirsin + parlasın (0.0s)
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut) {
            self.moonView.alpha = 1
            self.moonGlow.alpha = 1
        }

        // Ay hafif yukarı kayar
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut, .repeat, .autoreverse]) {
            self.moonView.transform = CGAffineTransform(translationX: 0, y: -8)
            self.moonGlow.transform = CGAffineTransform(translationX: 0, y: -8)
        }

        // 2️⃣ Yıldızlar teker teker yanıp söner (0.1s aralıklarla)
        for (i, star) in starLabels.enumerated() {
            let delay = 0.15 + Double(i) * 0.08
            UIView.animate(withDuration: 0.4, delay: delay, options: .curveEaseOut) {
                star.alpha = 1
                star.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                // Yıldız kırpışma efekti
                UIView.animate(withDuration: Double.random(in: 0.8...1.5),
                               delay: 0,
                               options: [.repeat, .autoreverse, .curveEaseInOut]) {
                    star.alpha = CGFloat.random(in: 0.3...0.8)
                    star.transform = .identity
                }
            }
        }

        // 3️⃣ Kitap büyüyerek belirsin (0.8s)
        UIView.animate(withDuration: 0.7, delay: 0.8,
                       usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.bookLabel.alpha = 1
            self.bookLabel.transform = .identity
        }

        // Kitap hafif süzülme
        UIView.animate(withDuration: 2.0, delay: 1.0,
                       options: [.curveEaseInOut, .repeat, .autoreverse]) {
            self.bookLabel.transform = CGAffineTransform(translationX: 0, y: -12)
        }

        // 4️⃣ Parıltılar yayılsın (1.2s)
        for (i, sparkle) in sparkleViews.enumerated() {
            let delay = 1.2 + Double(i) * 0.04
            let dx = CGFloat.random(in: -60...60)
            let dy = CGFloat.random(in: -60...60)

            UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseOut) {
                sparkle.alpha = CGFloat.random(in: 0.5...1.0)
            }

            UIView.animate(withDuration: 1.2, delay: delay, options: .curveEaseOut) {
                sparkle.transform = CGAffineTransform(translationX: dx, y: dy)
            } completion: { _ in
                UIView.animate(withDuration: 0.6) {
                    sparkle.alpha = 0
                }
            }
        }

        // 5️⃣ Başlık belirsin (1.5s)
        UIView.animate(withDuration: 0.6, delay: 1.5, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = CGAffineTransform(translationX: 0, y: -5)
        }

        // 6️⃣ Alt yazı belirsin (1.8s)
        UIView.animate(withDuration: 0.5, delay: 1.8, options: .curveEaseOut) {
            self.subtitleLabel.alpha = 1
        }

        // 7️⃣ Tüm ekran fade-out ve geçiş (3.2s)
        UIView.animate(withDuration: 0.5, delay: 3.2, options: .curveEaseIn, animations: {
            self.view.alpha = 0
        }) { _ in
            self.onAnimationFinished?()
        }
    }
}
