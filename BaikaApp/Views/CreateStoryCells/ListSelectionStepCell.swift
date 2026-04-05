//
//  ListSelectionStepCell.swift
//  BaikaApp
//

import UIKit

class ListSelectionStepCell: UICollectionViewCell {

    static let identifier = "ListSelectionStepCell"

    var onOptionSelected: ((Int) -> Void)?

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

    private let optionsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private var options: [StepOption] = []
    private var optionButtons: [UIView] = []

    private let activeColor = UIColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 1.0)

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
        contentView.addSubview(optionsStackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            optionsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }

    func configure(with step: Step) {
        titleLabel.text = step.title
        subtitleLabel.text = step.subtitle
        options = step.options

        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        optionButtons.removeAll()

        for (index, option) in options.enumerated() {
            let row = createOptionRow(option: option, index: index)
            optionsStackView.addArrangedSubview(row)
            optionButtons.append(row)

            row.heightAnchor.constraint(equalToConstant: 52).isActive = true

            // Restore selection state from data model
            if option.isSelected {
                row.layer.borderColor = activeColor.cgColor
                row.backgroundColor = activeColor.withAlphaComponent(0.15)
            }
        }
    }

    private func createOptionRow(option: StepOption, index: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1.5
        container.layer.borderColor = UIColor.clear.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        container.tag = index

        let tap = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
        container.addGestureRecognizer(tap)

        let emojiLabel = UILabel()
        emojiLabel.text = option.emoji
        emojiLabel.font = .systemFont(ofSize: 24)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.setContentHuggingPriority(.required, for: .horizontal)
        emojiLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let titleLabel = UILabel()
        titleLabel.text = option.title
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Nunito-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let hStack = UIStackView(arrangedSubviews: [emojiLabel, titleLabel])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.distribution = .fill
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.isUserInteractionEnabled = false

        container.addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
            hStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    @objc private func optionTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }
        let index = tappedView.tag

        for button in optionButtons {
            UIView.animate(withDuration: 0.2) {
                button.layer.borderColor = UIColor.clear.cgColor
                button.backgroundColor = UIColor.white.withAlphaComponent(0.06)
            }
        }

        UIView.animate(withDuration: 0.2) {
            tappedView.layer.borderColor = self.activeColor.cgColor
            tappedView.backgroundColor = self.activeColor.withAlphaComponent(0.15)
        }

        onOptionSelected?(index)
    }
}
