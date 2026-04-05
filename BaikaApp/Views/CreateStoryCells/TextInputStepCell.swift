//
//  TextInputCell.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 6.04.2026.
//

// MARK: - TextInputStepCell (Adım 1: Çocuğun Adı)
import UIKit
import Foundation

class TextInputStepCell: UICollectionViewCell, UITextFieldDelegate {

    static let identifier = "TextInputStepCell"

    var onTextChanged: ((String) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Nunito-Bold", size: 22) ?? .boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont(name: "Nunito-Regular", size: 14) ?? .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tf.layer.cornerRadius = 14
        tf.textColor = .white
        tf.font = UIFont(name: "Nunito-Regular", size: 16) ?? .systemFont(ofSize: 16)
        tf.attributedPlaceholder = NSAttributedString(
            string: "İsim giriniz...",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.3)]
        )
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(textField)

        textField.delegate = self
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            textField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            textField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func configure(with step: Step) {
        titleLabel.text = step.title
        subtitleLabel.text = step.subtitle
    }

    @objc private func textChanged() {
        onTextChanged?(textField.text ?? "")
    }
}
