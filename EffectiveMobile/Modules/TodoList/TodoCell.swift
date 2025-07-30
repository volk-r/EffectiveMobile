//
//  TodoCell.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import UIKit

protocol TodoCellDelegate: AnyObject {
	func didTapCheckbox(for cell: TodoCell)
}

final class TodoCell: UITableViewCell {

	// MARK: - Public Properties

	static let identifier = "TodoCell"

	var delegate: TodoCellDelegate?

	// MARK: - Private Properties

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = AppColor.Text.primary
		return label
	}()

	private lazy var descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .regular)
		label.textColor = AppColor.Text.primary
		label.numberOfLines = 2
		return label
	}()

	private lazy var dateLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .regular)
		label.textColor = AppColor.Text.secondary
		return label
	}()

	private lazy var doneButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "circle"), for: .normal)
		button.tintColor = AppColor.Todo.uncompleted
		return button
	}()

	// MARK: - Initializers

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupDoneButton()
		setupTitleLabel()
		setupDescriptionLabel()
		setupDateLabel()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Public Methods

	func configure(with viewModel: TodoModel) {
		titleLabel.text = viewModel.title
		descriptionLabel.text = viewModel.description
		dateLabel.text = viewModel.date
		doneButton.setImage(
			UIImage(systemName: viewModel.completed ? "checkmark.circle" : "circle"),
			for: .normal
		)
		doneButton.tintColor = viewModel.completed ? AppColor.Todo.completed : AppColor.Todo.uncompleted
		titleLabel.animateStrikethrough(isStrikethrough: viewModel.completed)
	}

	// MARK: - Private Methods

	private func setupDoneButton() {
		doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)

		contentView.addSubviews(doneButton)
		NSLayoutConstraint.activate([
			doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			doneButton.widthAnchor.constraint(equalToConstant: 24),
			doneButton.heightAnchor.constraint(equalToConstant: 24),
			doneButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12)
		])
	}

	@objc private func didTapDoneButton(sender: UIButton) {
		delegate?.didTapCheckbox(for: self)
	}

	private func setupTitleLabel() {
		contentView.addSubviews(titleLabel)
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor, constant: 8),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12)
		])
	}

	private func setupDescriptionLabel() {
		contentView.addSubviews(descriptionLabel)
		NSLayoutConstraint.activate([
			descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
			descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			descriptionLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 32)
		])
	}

	private func setupDateLabel() {
		contentView.addSubviews(dateLabel)
		NSLayoutConstraint.activate([
			dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
			dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
		])
	}
}
