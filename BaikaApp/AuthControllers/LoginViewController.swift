//
//  LoginViewController.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 08.04.2026.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    // MARK: - Properties
    private var isLoginMode = true
    private let purpleColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)

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

    // Üstteki büyük emoji / ikon
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "📖✨"
        label.font = .systemFont(ofSize: 72)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Baika"
        label.textColor = .white
        label.font = UIFont(name: "Nunito-Bold", size: 36) ?? .boldSystemFont(ofSize: 36)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Masalların büyülü dünyasına hoş geldin"
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont(name: "Nunito-Regular", size: 15) ?? .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Segment Control yerine Toggle butonlar
    private let segmentContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 14
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let loginSegmentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Giriş Yap", for: .normal)
        btn.titleLabel?.font = UIFont(name: "Nunito-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tag = 0
        return btn
    }()

    private let registerSegmentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Kayıt Ol", for: .normal)
        btn.titleLabel?.font = UIFont(name: "Nunito-SemiBold", size: 15) ?? .systemFont(ofSize: 15, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tag = 1
        return btn
    }()

    private let segmentIndicator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private var segmentIndicatorLeading: NSLayoutConstraint!

    // Form alanları
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "E-posta adresiniz"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.textColor = .white
        tf.font = UIFont(name: "Nunito-Regular", size: 16) ?? .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.attributedPlaceholder = NSAttributedString(
            string: "E-posta adresiniz",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.35)]
        )
        return tf
    }()

    private let emailContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emailIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "envelope.fill"))
        iv.tintColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Şifreniz"
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.textColor = .white
        tf.font = UIFont(name: "Nunito-Regular", size: 16) ?? .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.attributedPlaceholder = NSAttributedString(
            string: "Şifreniz",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.35)]
        )
        return tf
    }()

    private let passwordContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let passwordIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock.fill"))
        iv.tintColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let passwordToggleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.35)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // Şifre doğrulama (sadece kayıt modunda gösterilecek)
    private let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Şifrenizi tekrar girin"
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.textColor = .white
        tf.font = UIFont(name: "Nunito-Regular", size: 16) ?? .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.attributedPlaceholder = NSAttributedString(
            string: "Şifrenizi tekrar girin",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.35)]
        )
        return tf
    }()

    private let confirmPasswordContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let confirmPasswordIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock.fill"))
        iv.tintColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let confirmPasswordToggleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.35)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var confirmPasswordContainerHeight: NSLayoutConstraint!
    private var confirmPasswordContainerTop: NSLayoutConstraint!

    // Ana buton
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Giriş Yap", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Nunito-Bold", size: 17) ?? .boldSystemFont(ofSize: 17)
        btn.backgroundColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)
        btn.layer.cornerRadius = 14
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // Loading indicator
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // Hata mesajı
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 255/255, green: 100/255, blue: 100/255, alpha: 1.0)
        label.font = UIFont(name: "Nunito-Regular", size: 13) ?? .systemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Alt dekoratif yıldızlar
    private let starsLabel: UILabel = {
        let label = UILabel()
        label.text = "⭐ 🌙 ⭐"
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        label.alpha = 0.4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupKeyboardDismiss()
        updateSegmentUI()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 35/255, alpha: 1.0)
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(logoLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        // Segment
        contentView.addSubview(segmentContainer)
        segmentContainer.addSubview(segmentIndicator)
        segmentContainer.addSubview(loginSegmentButton)
        segmentContainer.addSubview(registerSegmentButton)

        // Email
        contentView.addSubview(emailContainer)
        emailContainer.addSubview(emailIconView)
        emailContainer.addSubview(emailTextField)

        // Password
        contentView.addSubview(passwordContainer)
        passwordContainer.addSubview(passwordIconView)
        passwordContainer.addSubview(passwordTextField)
        passwordContainer.addSubview(passwordToggleButton)

        // Confirm Password
        contentView.addSubview(confirmPasswordContainer)
        confirmPasswordContainer.addSubview(confirmPasswordIconView)
        confirmPasswordContainer.addSubview(confirmPasswordTextField)
        confirmPasswordContainer.addSubview(confirmPasswordToggleButton)

        // Error
        contentView.addSubview(errorLabel)

        // Action Button
        contentView.addSubview(actionButton)
        actionButton.addSubview(loadingIndicator)

        // Stars
        contentView.addSubview(starsLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        segmentIndicatorLeading = segmentIndicator.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor, constant: 4)

        confirmPasswordContainerTop = confirmPasswordContainer.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 12)
        confirmPasswordContainerHeight = confirmPasswordContainer.heightAnchor.constraint(equalToConstant: 52)

        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Logo
            logoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            logoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Title
            titleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),

            // Segment Container
            segmentContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 36),
            segmentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            segmentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            segmentContainer.heightAnchor.constraint(equalToConstant: 48),

            segmentIndicatorLeading,
            segmentIndicator.topAnchor.constraint(equalTo: segmentContainer.topAnchor, constant: 4),
            segmentIndicator.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: -4),
            segmentIndicator.widthAnchor.constraint(equalTo: segmentContainer.widthAnchor, multiplier: 0.5, constant: -8),

            loginSegmentButton.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor),
            loginSegmentButton.topAnchor.constraint(equalTo: segmentContainer.topAnchor),
            loginSegmentButton.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor),
            loginSegmentButton.widthAnchor.constraint(equalTo: segmentContainer.widthAnchor, multiplier: 0.5),

            registerSegmentButton.trailingAnchor.constraint(equalTo: segmentContainer.trailingAnchor),
            registerSegmentButton.topAnchor.constraint(equalTo: segmentContainer.topAnchor),
            registerSegmentButton.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor),
            registerSegmentButton.widthAnchor.constraint(equalTo: segmentContainer.widthAnchor, multiplier: 0.5),

            // Email Container
            emailContainer.topAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: 28),
            emailContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emailContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            emailContainer.heightAnchor.constraint(equalToConstant: 52),

            emailIconView.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 14),
            emailIconView.centerYAnchor.constraint(equalTo: emailContainer.centerYAnchor),
            emailIconView.widthAnchor.constraint(equalToConstant: 20),
            emailIconView.heightAnchor.constraint(equalToConstant: 20),

            emailTextField.leadingAnchor.constraint(equalTo: emailIconView.trailingAnchor, constant: 12),
            emailTextField.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: -14),
            emailTextField.topAnchor.constraint(equalTo: emailContainer.topAnchor),
            emailTextField.bottomAnchor.constraint(equalTo: emailContainer.bottomAnchor),

            // Password Container
            passwordContainer.topAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: 12),
            passwordContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            passwordContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            passwordContainer.heightAnchor.constraint(equalToConstant: 52),

            passwordIconView.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor, constant: 14),
            passwordIconView.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
            passwordIconView.widthAnchor.constraint(equalToConstant: 20),
            passwordIconView.heightAnchor.constraint(equalToConstant: 20),

            passwordTextField.leadingAnchor.constraint(equalTo: passwordIconView.trailingAnchor, constant: 12),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordToggleButton.leadingAnchor, constant: -8),
            passwordTextField.topAnchor.constraint(equalTo: passwordContainer.topAnchor),
            passwordTextField.bottomAnchor.constraint(equalTo: passwordContainer.bottomAnchor),

            passwordToggleButton.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor, constant: -14),
            passwordToggleButton.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
            passwordToggleButton.widthAnchor.constraint(equalToConstant: 24),
            passwordToggleButton.heightAnchor.constraint(equalToConstant: 24),

            // Confirm Password Container
            confirmPasswordContainerTop,
            confirmPasswordContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            confirmPasswordContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            confirmPasswordContainerHeight,

            confirmPasswordIconView.leadingAnchor.constraint(equalTo: confirmPasswordContainer.leadingAnchor, constant: 14),
            confirmPasswordIconView.centerYAnchor.constraint(equalTo: confirmPasswordContainer.centerYAnchor),
            confirmPasswordIconView.widthAnchor.constraint(equalToConstant: 20),
            confirmPasswordIconView.heightAnchor.constraint(equalToConstant: 20),

            confirmPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordIconView.trailingAnchor, constant: 12),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: confirmPasswordToggleButton.leadingAnchor, constant: -8),
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordContainer.topAnchor),
            confirmPasswordTextField.bottomAnchor.constraint(equalTo: confirmPasswordContainer.bottomAnchor),

            confirmPasswordToggleButton.trailingAnchor.constraint(equalTo: confirmPasswordContainer.trailingAnchor, constant: -14),
            confirmPasswordToggleButton.centerYAnchor.constraint(equalTo: confirmPasswordContainer.centerYAnchor),
            confirmPasswordToggleButton.widthAnchor.constraint(equalToConstant: 24),
            confirmPasswordToggleButton.heightAnchor.constraint(equalToConstant: 24),

            // Error label
            errorLabel.topAnchor.constraint(equalTo: confirmPasswordContainer.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),

            // Action Button
            actionButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            actionButton.heightAnchor.constraint(equalToConstant: 52),

            loadingIndicator.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),

            // Stars
            starsLabel.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 40),
            starsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            starsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
        ])
    }

    private func setupActions() {
        loginSegmentButton.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
        registerSegmentButton.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        confirmPasswordToggleButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility(_:)), for: .touchUpInside)
    }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Segment

    @objc private func segmentTapped(_ sender: UIButton) {
        isLoginMode = sender.tag == 0
        updateSegmentUI()
    }

    private func updateSegmentUI() {
        // Segment indicator animasyonu
        let halfWidth = segmentContainer.bounds.width / 2
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.segmentIndicatorLeading.constant = self.isLoginMode ? 4 : halfWidth + 4
            self.view.layoutIfNeeded()
        }

        loginSegmentButton.setTitleColor(isLoginMode ? .white : UIColor.white.withAlphaComponent(0.4), for: .normal)
        registerSegmentButton.setTitleColor(isLoginMode ? UIColor.white.withAlphaComponent(0.4) : .white, for: .normal)

        // Confirm password alanını göster/gizle
        UIView.animate(withDuration: 0.3) {
            self.confirmPasswordContainer.alpha = self.isLoginMode ? 0 : 1
            self.confirmPasswordContainerHeight.constant = self.isLoginMode ? 0 : 52
            self.confirmPasswordContainerTop.constant = self.isLoginMode ? 0 : 12
            self.view.layoutIfNeeded()
        }

        confirmPasswordContainer.isUserInteractionEnabled = !isLoginMode

        // Buton metnini güncelle
        actionButton.setTitle(isLoginMode ? "Giriş Yap" : "Kayıt Ol", for: .normal)

        // Hata mesajını temizle
        hideError()
    }

    // MARK: - Actions

    @objc private func actionButtonTapped() {
        dismissKeyboard()

        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            showError("Lütfen e-posta adresinizi girin")
            shakeField(emailContainer)
            return
        }

        guard let password = passwordTextField.text, !password.isEmpty else {
            showError("Lütfen şifrenizi girin")
            shakeField(passwordContainer)
            return
        }

        guard password.count >= 6 else {
            showError("Şifre en az 6 karakter olmalıdır")
            shakeField(passwordContainer)
            return
        }

        if !isLoginMode {
            guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
                showError("Lütfen şifrenizi tekrar girin")
                shakeField(confirmPasswordContainer)
                return
            }
            guard password == confirmPassword else {
                showError("Şifreler eşleşmiyor")
                shakeField(confirmPasswordContainer)
                return
            }
        }

        setLoading(true)

        if isLoginMode {
            loginUser(email: email, password: password)
        } else {
            registerUser(email: email, password: password)
        }
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let icon = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        sender.setImage(UIImage(systemName: icon), for: .normal)
    }

    @objc private func toggleConfirmPasswordVisibility(_ sender: UIButton) {
        confirmPasswordTextField.isSecureTextEntry.toggle()
        let icon = confirmPasswordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        sender.setImage(UIImage(systemName: icon), for: .normal)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = keyboardFrame.height
        scrollView.scrollIndicatorInsets.bottom = keyboardFrame.height
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }

    // MARK: - Firebase Auth

    private func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.setLoading(false)

                if let error = error {
                    self.showError(self.friendlyError(error))
                    return
                }

                self.navigateToApp()
            }
        }
    }

    private func registerUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.setLoading(false)

                if let error = error {
                    self.showError(self.friendlyError(error))
                    return
                }

                self.navigateToApp()
            }
        }
    }

    private func navigateToApp() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else { return }
        let tab = DashboardTabBar()
        sceneDelegate.window?.rootViewController = tab
        
        // Geçiş animasyonu
        if let window = sceneDelegate.window {
            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
        }
    }

    // MARK: - Helpers

    private func setLoading(_ loading: Bool) {
        actionButton.isEnabled = !loading
        emailTextField.isEnabled = !loading
        passwordTextField.isEnabled = !loading
        confirmPasswordTextField.isEnabled = !loading

        if loading {
            actionButton.setTitle("", for: .normal)
            loadingIndicator.startAnimating()
        } else {
            actionButton.setTitle(isLoginMode ? "Giriş Yap" : "Kayıt Ol", for: .normal)
            loadingIndicator.stopAnimating()
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        UIView.animate(withDuration: 0.3) {
            self.errorLabel.alpha = 1
        }
    }

    private func hideError() {
        UIView.animate(withDuration: 0.2) {
            self.errorLabel.alpha = 0
        }
    }

    private func shakeField(_ view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-8, 8, -6, 6, -4, 4, -2, 2, 0]
        view.layer.add(animation, forKey: "shake")

        // Kırmızı border efekti
        let originalBorder = view.layer.borderColor
        view.layer.borderColor = UIColor(red: 255/255, green: 100/255, blue: 100/255, alpha: 0.6).cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.3) {
                view.layer.borderColor = originalBorder
            }
        }
    }

    private func friendlyError(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Şifre hatalı. Lütfen tekrar deneyin."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Geçersiz e-posta adresi."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Bu e-posta adresi zaten kullanılıyor."
        case AuthErrorCode.weakPassword.rawValue:
            return "Şifre çok zayıf. En az 6 karakter olmalıdır."
        case AuthErrorCode.userNotFound.rawValue:
            return "Bu e-posta ile kayıtlı kullanıcı bulunamadı."
        case AuthErrorCode.networkError.rawValue:
            return "İnternet bağlantınızı kontrol edin."
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Çok fazla deneme yaptınız. Lütfen bir süre bekleyin."
        case AuthErrorCode.invalidCredential.rawValue:
            return "E-posta veya şifre hatalı."
        default:
            return "Bir hata oluştu: \(error.localizedDescription)"
        }
    }
}
